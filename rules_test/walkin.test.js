// Tester av kunder på kontoret: managern väljer eller skapar kund och
// bjuder in den, och kunden registrerar sig via länken.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection, deleteDoc, doc, getDoc, getDocs, query, serverTimestamp, setDoc,
  updateDoc, where, writeBatch,
} from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-crm-rules-walkin',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});

after(async () => {
  await env?.cleanup();
});

const CODE = 'abcdefghijklmnopqrstuvwxyz012345';

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users', 'M'), { role: 'manager', officeId: 'O1' });
    await setDoc(doc(db, 'users', 'NEW'), { role: 'customer' });
    await setDoc(doc(db, 'users', 'OTHER'), { role: 'customer' });
    await setDoc(doc(db, 'customers', 'OTHER'), { userId: 'OTHER', clientId: 3 });
    await setDoc(doc(db, 'meta', 'customers'), { lastClientId: 10 });
    await setDoc(doc(db, 'officeListings', 'O1'), { currencies: ['RUB', 'USDT'] });
    // Kund som admin registrerat, utan konto, med nivå och inbjudan.
    await setDoc(doc(db, 'customers', 'old'), {
      clientId: 7, firstName: 'Islam', lastName: 'M', phone: '070', tier: 'gold', inviteCode: CODE,
    });
    await setDoc(doc(db, 'customers', 'plain'), { clientId: 8, firstName: 'Ali' });
    await setDoc(doc(db, 'transactions', 'walkin'), {
      customerId: '', clientId: '7', customerDocId: 'old', officeId: 'O1', status: 'completed',
    });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

describe('managern och kundregistret', () => {
  test('managern läser alla kunder', async () => {
    await assertSucceeds(getDocs(collection(as('M'), 'customers')));
  });

  test('managern bjuder in en kund utan konto, inte en med konto', async () => {
    await assertSucceeds(updateDoc(doc(as('M'), 'customers', 'plain'), { inviteCode: CODE }));
    await assertFails(updateDoc(doc(as('M'), 'customers', 'OTHER'), { inviteCode: CODE }));
    await assertFails(updateDoc(doc(as('M'), 'customers', 'plain'), { firstName: 'X' }));
  });

  test('managern skapar ny kund med nästa klient-ID', async () => {
    const db = as('M');
    const batch = writeBatch(db);
    batch.update(doc(db, 'meta', 'customers'), { lastClientId: 11 });
    batch.set(doc(db, 'customers', 'n1'), {
      clientId: 11, firstName: 'Ny', lastName: '', phone: '070', createAt: serverTimestamp(),
      inviteCode: CODE, invitedAt: serverTimestamp(), createdByManagerId: 'M',
    });
    await assertSucceeds(batch.commit());
  });

  test('fel klient-ID nekas', async () => {
    const db = as('M');
    const batch = writeBatch(db);
    batch.update(doc(db, 'meta', 'customers'), { lastClientId: 11 });
    batch.set(doc(db, 'customers', 'n1'), {
      clientId: 3, firstName: 'Ny', lastName: '', phone: '070', createAt: serverTimestamp(),
      inviteCode: CODE, invitedAt: serverTimestamp(), createdByManagerId: 'M',
    });
    await assertFails(batch.commit());
  });

  const walkIn = (extra) => ({
    customerId: '', customerName: 'Islam', customerPhone: '070', officeId: 'O1',
    fromCurrency: 'RUB', toCurrency: 'USDT', amountFrom: 50000, feePercent: 5,
    feeAmountFrom: 2500, rateFromTo: 0.0124, amountToGross: 620, amountToNet: 589,
    feeAmountTo: 31, status: 'customer_accepted', createAt: serverTimestamp(),
    createdByManager: true, ...extra,
  });

  test('transaktion för vald kund måste ha kundens klient-ID', async () => {
    await assertSucceeds(setDoc(doc(as('M'), 'transactions', 't1'),
      walkIn({ clientId: '7', customerDocId: 'old' })));
    await assertFails(setDoc(doc(as('M'), 'transactions', 't2'),
      walkIn({ clientId: '3', customerDocId: 'old' })));
  });
});

describe('registrering via inbjudan', () => {
  test('den inbjudna posten kan läsas med sitt ID, men inte listas', async () => {
    const anon = env.unauthenticatedContext().firestore();
    await assertSucceeds(getDoc(doc(anon, 'customers', 'old')));
    await assertFails(getDoc(doc(anon, 'customers', 'plain')));
    await assertFails(getDocs(collection(anon, 'customers')));
  });

  const claim = (overrides = {}) => {
    const db = as('NEW');
    const batch = writeBatch(db);
    batch.set(doc(db, 'customers', 'NEW'), {
      clientId: 7, firstName: 'Islam', lastName: 'M', email: 'a@b.se', phone: '070',
      userId: 'NEW', createAt: serverTimestamp(), inviteDocId: 'old', inviteCode: CODE,
      tier: 'gold', ...overrides,
    });
    batch.delete(doc(db, 'customers', 'old'));
    return batch.commit();
  };

  test('kunden tar över posten med rätt kod och behåller klient-ID och nivå', async () => {
    await assertSucceeds(claim());
  });

  test('fel kod, annat klient-ID eller annan nivå nekas', async () => {
    await assertFails(claim({ inviteCode: 'x'.repeat(32) }));
    await assertFails(claim({ clientId: 99 }));
    await assertFails(claim({ tier: 'diamond' }));
  });

  test('den gamla posten kan inte tas bort utan att tas över', async () => {
    await assertFails(deleteDoc(doc(as('NEW'), 'customers', 'old')));
  });

  test('kunden ser transaktioner som managern skapat med klient-ID:t', async () => {
    await claim();
    const q = query(collection(as('NEW'), 'transactions'),
      where('customerId', '==', ''), where('clientId', '==', '7'));
    await assertSucceeds(getDocs(q));
    const other = query(collection(as('OTHER'), 'transactions'),
      where('customerId', '==', ''), where('clientId', '==', '7'));
    await assertFails(getDocs(other));
  });
});
