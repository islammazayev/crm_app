// Tester av en manager som också är kassör (users/{uid}.alsoCashier).
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  doc, serverTimestamp, setDoc, updateDoc, writeBatch,
} from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-crm-rules-mc',
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
    await setDoc(doc(db, 'users', 'MK'), { role: 'manager', officeId: 'O1', alsoCashier: true });
    await setDoc(doc(db, 'users', 'M'), { role: 'manager', officeId: 'O1' });
    await setDoc(doc(db, 'cashiers', 'MK'), { officeId: 'O1', balances: { EUR: 100 } });
    await setDoc(doc(db, 'cashierDirectory', 'MK'), { name: 'MK', officeId: 'O1' });
    await setDoc(doc(db, 'users', 'K2'), { role: 'cashier' });
    await setDoc(doc(db, 'cashiers', 'K2'), { officeId: 'O1', balances: {} });
    await setDoc(doc(db, 'cashierDirectory', 'K2'), { name: 'K2', officeId: 'O1' });
    await setDoc(doc(db, 'transactions', 'cash'), {
      status: 'customer_accepted', officeId: 'O1', customerId: 'C', payMethod: 'cash',
    });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

describe('manager som också är kassör', () => {
  test('skickar pengar från sin egen kassa', async () => {
    const db = as('MK');
    const ref = doc(db, 'cashierTransfers', 'tr1');
    const batch = writeBatch(db);
    batch.set(ref, {
      fromId: 'MK', fromName: 'MK', toId: 'K2', toName: 'K2', currency: 'EUR', amount: 50,
      note: '', status: 'pending', createdAt: serverTimestamp(),
      fromOfficeId: 'O1', fromManagerId: null, toOfficeId: 'O1', toManagerId: null,
    });
    batch.update(doc(db, 'cashiers', 'MK'), { balances: { EUR: 50 }, lastTransferId: 'tr1' });
    await assertSucceeds(batch.commit());
  });

  test('en vanlig manager har ingen kassa', async () => {
    const db = as('M');
    const batch = writeBatch(db);
    batch.set(doc(db, 'cashierTransfers', 'tr2'), {
      fromId: 'M', fromName: 'M', toId: 'K2', toName: 'K2', currency: 'EUR', amount: 1,
      note: '', status: 'pending', createdAt: serverTimestamp(),
      fromOfficeId: 'O1', fromManagerId: null, toOfficeId: 'O1', toManagerId: null,
    });
    await assertFails(batch.commit());
  });

  test('ingen kan göra sig själv till kassör', async () => {
    await assertFails(updateDoc(doc(as('M'), 'users', 'M'), { alsoCashier: true }));
    await assertSucceeds(updateDoc(doc(as('M'), 'users', 'M'), { phone: '070' }));
  });

  test('bekräftar kontant inbetalning som kassör', async () => {
    await assertSucceeds(updateDoc(doc(as('MK'), 'transactions', 'cash'), {
      status: 'payment_confirmed', pickupCode: '261031-1234-5678',
      pickupToken: 'a'.repeat(32), paymentConfirmedAt: serverTimestamp(),
      paymentConfirmedBy: 'MK',
    }));
  });
});
