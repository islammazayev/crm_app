// Tester av Firestore-reglerna för kassörer (saldo och överföringar).
// Körs mot emulatorn: från projektroten, `npm --prefix rules_test test`.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  doc,
  getDoc,
  getDocs,
  increment,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-crm-rules',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});

after(async () => {
  await env?.cleanup();
});

// A: kopplad till manager M, har 1000 EUR.  B: kopplad till kontor O1.
// C: separat kassör.  M: manager för kontor O1.  X: manager för kontor O2.
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    const users = {
      admin: { role: 'admin' },
      A: { role: 'cashier', firstName: 'Anna' },
      B: { role: 'cashier', firstName: 'Bertil' },
      C: { role: 'cashier', firstName: 'Cecilia' },
      M: { role: 'manager', officeId: 'O1' },
      X: { role: 'manager', officeId: 'O2' },
      K: { role: 'customer' },
    };
    for (const [id, data] of Object.entries(users)) {
      await setDoc(doc(db, 'users', id), data);
    }
    await setDoc(doc(db, 'cashiers', 'A'), { firstName: 'Anna', managerId: 'M', balances: { EUR: 1000 } });
    await setDoc(doc(db, 'cashiers', 'B'), { firstName: 'Bertil', officeId: 'O1', balances: {} });
    await setDoc(doc(db, 'cashiers', 'C'), { firstName: 'Cecilia', balances: { USD: 50 } });
    await setDoc(doc(db, 'cashierDirectory', 'A'), { name: 'Anna', officeId: null, managerId: 'M' });
    await setDoc(doc(db, 'cashierDirectory', 'B'), { name: 'Bertil', officeId: 'O1', managerId: null });
    await setDoc(doc(db, 'cashierDirectory', 'C'), { name: 'Cecilia', officeId: null, managerId: null });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

async function balance(uid, currency) {
  let value;
  await env.withSecurityRulesDisabled(async (ctx) => {
    const snap = await getDoc(doc(ctx.firestore(), 'cashiers', uid));
    value = snap.data().balances[currency] ?? 0;
  });
  return value;
}

function transferData(overrides = {}) {
  return {
    fromId: 'A',
    fromName: 'Anna',
    toId: 'B',
    toName: 'Bertil',
    currency: 'EUR',
    amount: 100,
    note: '',
    status: 'pending',
    createdAt: serverTimestamp(),
    fromOfficeId: null,
    fromManagerId: 'M',
    toOfficeId: 'O1',
    toManagerId: null,
    ...overrides,
  };
}

/** Skickar som appen gör: överföring + reservation i samma batch. */
function send(db, id, { data = {}, debit = 100, debitCurrency = 'EUR', from = 'A' } = {}) {
  const batch = writeBatch(db);
  batch.set(doc(db, 'cashierTransfers', id), transferData(data));
  batch.update(doc(db, 'cashiers', from), {
    [`balances.${debitCurrency}`]: increment(-debit),
    lastTransferId: id,
  });
  return batch.commit();
}

/** Ändrar status och krediterar ett saldo i samma batch. */
function decide(db, id, status, creditTo, amount = 100, currency = 'EUR') {
  const batch = writeBatch(db);
  batch.update(doc(db, 'cashierTransfers', id), { status, decidedAt: serverTimestamp() });
  batch.update(doc(db, 'cashiers', creditTo), {
    [`balances.${currency}`]: increment(amount),
    lastTransferId: id,
  });
  return batch.commit();
}

async function seedPending(id = 't1') {
  await assertSucceeds(send(as('A'), id));
}

describe('skicka', () => {
  test('kassören skickar och beloppet reserveras', async () => {
    await assertSucceeds(send(as('A'), 't1'));
    assert.equal(await balance('A', 'EUR'), 900);
    assert.equal(await balance('B', 'EUR'), 0);
  });

  test('kan inte skicka mer än saldot', async () => {
    await assertFails(send(as('A'), 't1', { data: { amount: 2000 }, debit: 2000 }));
  });

  test('måste reservera exakt beloppet', async () => {
    await assertFails(send(as('A'), 't1', { debit: 50 }));
    await assertFails(send(as('A'), 't1', { debit: 0 }));
  });

  test('måste reservera i rätt valuta', async () => {
    await assertFails(send(as('A'), 't1', { debitCurrency: 'USD' }));
  });

  test('kan inte skapa överföring utan att röra saldot', async () => {
    await assertFails(setDoc(doc(as('A'), 'cashierTransfers', 't1'), transferData()));
  });

  test('kan inte skicka i någon annans namn', async () => {
    await assertFails(send(as('A'), 't1', { data: { fromId: 'C' } }));
  });

  test('kan inte skicka till sig själv', async () => {
    await assertFails(send(as('A'), 't1', { data: { toId: 'A' } }));
  });

  test('kan inte skicka till någon som inte är kassör', async () => {
    await assertFails(send(as('A'), 't1', { data: { toId: 'K' } }));
  });

  test('negativt eller noll belopp avvisas', async () => {
    await assertFails(send(as('A'), 't1', { data: { amount: -100 }, debit: -100 }));
    await assertFails(send(as('A'), 't1', { data: { amount: 0 }, debit: 0 }));
  });

  test('koppling till kontor/manager måste stämma med katalogen', async () => {
    await assertFails(send(as('A'), 't1', { data: { toOfficeId: 'O2' } }));
    await assertFails(send(as('A'), 't1', { data: { fromManagerId: 'X' } }));
  });

  test('överföringen måste börja som pending', async () => {
    await assertFails(send(as('A'), 't1', { data: { status: 'accepted' } }));
  });

  test('andra roller kan inte skicka', async () => {
    await assertFails(send(as('M'), 't1'));
    await assertFails(send(as('K'), 't1'));
  });
});

describe('ta emot, neka, avbryta', () => {
  test('mottagaren tar emot och får beloppet', async () => {
    await seedPending();
    await assertSucceeds(decide(as('B'), 't1', 'accepted', 'B'));
    assert.equal(await balance('B', 'EUR'), 100);
    assert.equal(await balance('A', 'EUR'), 900);
  });

  test('kan inte ta emot två gånger', async () => {
    await seedPending();
    await assertSucceeds(decide(as('B'), 't1', 'accepted', 'B'));
    await assertFails(decide(as('B'), 't1', 'accepted', 'B'));
  });

  test('kan inte ta emot mer än beloppet', async () => {
    await seedPending();
    await assertFails(decide(as('B'), 't1', 'accepted', 'B', 200));
  });

  test('bara mottagaren kan ta emot', async () => {
    await seedPending();
    await assertFails(decide(as('C'), 't1', 'accepted', 'C'));
    await assertFails(decide(as('A'), 't1', 'accepted', 'A'));
  });

  test('ta emot kräver att saldot krediteras i samma batch', async () => {
    await seedPending();
    await assertFails(updateDoc(doc(as('B'), 'cashierTransfers', 't1'), { status: 'accepted', decidedAt: serverTimestamp() }));
  });

  test('mottagaren nekar och pengarna går tillbaka till avsändaren', async () => {
    await seedPending();
    await assertSucceeds(decide(as('B'), 't1', 'rejected', 'A'));
    assert.equal(await balance('A', 'EUR'), 1000);
    assert.equal(await balance('B', 'EUR'), 0);
  });

  test('neka kan inte kreditera mottagaren själv', async () => {
    await seedPending();
    await assertFails(decide(as('B'), 't1', 'rejected', 'B'));
  });

  test('avsändaren avbryter och får tillbaka pengarna', async () => {
    await seedPending();
    await assertSucceeds(decide(as('A'), 't1', 'cancelled', 'A'));
    assert.equal(await balance('A', 'EUR'), 1000);
  });

  test('mottagaren kan inte avbryta, och avsändaren kan inte ta emot', async () => {
    await seedPending();
    await assertFails(decide(as('B'), 't1', 'cancelled', 'A'));
    await assertFails(decide(as('A'), 't1', 'accepted', 'B'));
  });

  test('avbruten överföring kan inte tas emot efteråt', async () => {
    await seedPending();
    await assertSucceeds(decide(as('A'), 't1', 'cancelled', 'A'));
    await assertFails(decide(as('B'), 't1', 'accepted', 'B'));
  });

  test('beloppet i en väntande överföring kan inte ändras', async () => {
    await seedPending();
    await assertFails(updateDoc(doc(as('A'), 'cashierTransfers', 't1'), { amount: 1 }));
    await assertFails(updateDoc(doc(as('B'), 'cashierTransfers', 't1'), { amount: 10000 }));
  });
});

describe('saldo', () => {
  test('kassören kan inte ändra sitt saldo själv', async () => {
    await assertFails(updateDoc(doc(as('A'), 'cashiers', 'A'), { 'balances.EUR': 999999 }));
    await assertFails(updateDoc(doc(as('A'), 'cashiers', 'A'), { 'balances.EUR': increment(1), lastTransferId: 'fake' }));
  });

  test('kassören kan inte ändra sin koppling', async () => {
    await assertFails(updateDoc(doc(as('A'), 'cashiers', 'A'), { managerId: 'X' }));
  });

  test('admin kan justera saldo', async () => {
    await assertSucceeds(updateDoc(doc(as('admin'), 'cashiers', 'B'), { 'balances.EUR': increment(500) }));
  });

  test('en gammal överföring kan inte återanvändas för att kreditera igen', async () => {
    await seedPending();
    await assertSucceeds(decide(as('B'), 't1', 'accepted', 'B'));
    await assertFails(
      updateDoc(doc(as('B'), 'cashiers', 'B'), { 'balances.EUR': increment(100), lastTransferId: 't1' }),
    );
  });
});

describe('läsrätt', () => {
  test('kassören läser bara sitt eget saldo, men alla i katalogen', async () => {
    await assertSucceeds(getDoc(doc(as('A'), 'cashiers', 'A')));
    await assertFails(getDoc(doc(as('A'), 'cashiers', 'B')));
    await assertSucceeds(getDocs(collection(as('A'), 'cashierDirectory')));
  });

  test('kunder ser varken kassörer eller katalog', async () => {
    await assertFails(getDoc(doc(as('K'), 'cashiers', 'A')));
    await assertFails(getDocs(collection(as('K'), 'cashierDirectory')));
  });

  test('managern ser kassörer kopplade till sig eller sitt kontor', async () => {
    await assertSucceeds(getDoc(doc(as('M'), 'cashiers', 'A'))); // managerId M
    await assertSucceeds(getDoc(doc(as('M'), 'cashiers', 'B'))); // kontor O1
    await assertFails(getDoc(doc(as('M'), 'cashiers', 'C')));
    await assertFails(getDoc(doc(as('X'), 'cashiers', 'A')));
  });

  test('managerns frågor (som i appen) godkänns', async () => {
    const m = as('M');
    await assertSucceeds(getDocs(query(collection(m, 'cashiers'), where('managerId', '==', 'M'))));
    await assertSucceeds(getDocs(query(collection(m, 'cashiers'), where('officeId', '==', 'O1'))));
    await seedPending();
    await assertSucceeds(getDocs(query(collection(m, 'cashierTransfers'), where('fromManagerId', '==', 'M'))));
    await assertSucceeds(getDocs(query(collection(m, 'cashierTransfers'), where('toOfficeId', '==', 'O1'))));
  });

  test('överföringar syns för avsändare, mottagare och deras manager, inte andra', async () => {
    await seedPending();
    await assertSucceeds(getDoc(doc(as('A'), 'cashierTransfers', 't1')));
    await assertSucceeds(getDoc(doc(as('B'), 'cashierTransfers', 't1')));
    await assertSucceeds(getDoc(doc(as('M'), 'cashierTransfers', 't1')));
    await assertFails(getDoc(doc(as('C'), 'cashierTransfers', 't1')));
    await assertFails(getDoc(doc(as('X'), 'cashierTransfers', 't1')));
    await assertFails(getDoc(doc(as('K'), 'cashierTransfers', 't1')));
  });

  test('kassörens egna frågor (som i appen) godkänns', async () => {
    await seedPending();
    await assertSucceeds(getDocs(query(collection(as('A'), 'cashierTransfers'), where('fromId', '==', 'A'))));
    await assertSucceeds(getDocs(query(collection(as('B'), 'cashierTransfers'), where('toId', '==', 'B'))));
  });
});

import assert from 'node:assert/strict';
