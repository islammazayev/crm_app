// Tester av kontant betalning på kontoret och kassörens bekräftelse.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection, doc, getDocs, query, serverTimestamp, setDoc, updateDoc, where,
} from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-crm-rules-cash',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});

after(async () => {
  await env?.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users', 'M'), { role: 'manager', officeId: 'O1' });
    await setDoc(doc(db, 'users', 'C'), { role: 'customer' });
    await setDoc(doc(db, 'customers', 'C'), { userId: 'C', clientId: 1 });
    await setDoc(doc(db, 'users', 'K'), { role: 'cashier' });
    await setDoc(doc(db, 'cashiers', 'K'), { managerId: 'M', balances: {} });
    await setDoc(doc(db, 'users', 'K2'), { role: 'cashier' });
    await setDoc(doc(db, 'cashiers', 'K2'), { officeId: 'O2', balances: {} });
    await setDoc(doc(db, 'officeListings', 'O1'), { currencies: ['SEK', 'EUR'] });
    await setDoc(doc(db, 'transactions', 'cash'), {
      status: 'customer_accepted', officeId: 'O1', customerId: 'C', payMethod: 'cash',
    });
    await setDoc(doc(db, 'transactions', 'bank'), {
      status: 'customer_accepted', officeId: 'O1', customerId: 'C',
    });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

const confirm = (uid) => ({
  status: 'payment_confirmed', pickupCode: '261030-1234-5678',
  pickupToken: 'a'.repeat(32), paymentConfirmedAt: serverTimestamp(),
  paymentConfirmedBy: uid,
});

describe('kundens val', () => {
  const request = (extra) => ({
    customerId: 'C', clientId: '1', customerName: 'K', customerPhone: '1',
    officeId: 'O1', fromCurrency: 'SEK', toCurrency: 'EUR', amountFrom: 100,
    amountTo: null, feePercent: null, feeAmount: null, paymentMethod: null,
    status: 'customer_requested', createAt: serverTimestamp(), ...extra,
  });

  test('kunden väljer kontant eller bank', async () => {
    await assertSucceeds(setDoc(doc(as('C'), 'transactions', 't1'), request({ payMethod: 'cash' })));
    await assertSucceeds(setDoc(doc(as('C'), 'transactions', 't2'), request({ payMethod: 'bank' })));
    await assertSucceeds(setDoc(doc(as('C'), 'transactions', 't3'), request({})));
    await assertFails(setDoc(doc(as('C'), 'transactions', 't4'), request({ payMethod: 'crypto' })));
  });
});

describe('kassören och kontanta inbetalningar', () => {
  test('kassören via managern ser kontorets transaktioner', async () => {
    await assertSucceeds(getDocs(query(collection(as('K'), 'transactions'), where('officeId', '==', 'O1'))));
    await assertFails(getDocs(query(collection(as('K2'), 'transactions'), where('officeId', '==', 'O1'))));
  });

  test('kassören bekräftar en kontant inbetalning', async () => {
    await assertSucceeds(updateDoc(doc(as('K'), 'transactions', 'cash'), confirm('K')));
  });

  test('inte en bankbetalning och inte på ett annat kontor', async () => {
    await assertFails(updateDoc(doc(as('K'), 'transactions', 'bank'), confirm('K')));
    await assertFails(updateDoc(doc(as('K2'), 'transactions', 'cash'), confirm('K2')));
  });

  test('kassören kan inte genomföra eller ändra beloppet', async () => {
    await assertFails(updateDoc(doc(as('K'), 'transactions', 'cash'), { ...confirm('K'), amountFrom: 1 }));
    await assertFails(updateDoc(doc(as('K'), 'transactions', 'cash'), { status: 'completed' }));
  });

  test('managern bekräftar som förut', async () => {
    await assertSucceeds(updateDoc(doc(as('M'), 'transactions', 'cash'), {
      status: 'payment_confirmed', pickupCode: '261030-1234-5678',
      pickupToken: 'a'.repeat(32), paymentConfirmedAt: serverTimestamp(),
    }));
  });
});
