// Tester av reglerna för att radera och ändra kundtransaktioner.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, deleteField, doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-crm-rules-tx',
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
    await setDoc(doc(db, 'users', 'admin'), { role: 'admin' });
    await setDoc(doc(db, 'users', 'M'), { role: 'manager', officeId: 'O1' });
    await setDoc(doc(db, 'transactions', 'done'), {
      status: 'completed', officeId: 'O1', amountFrom: 10000, feeAmountFrom: 500,
    });
    await setDoc(doc(db, 'transactions', 'open'), {
      status: 'customer_requested', officeId: 'O1', amountFrom: 100,
    });
  });
});

const admin = () => env.authenticatedContext('admin').firestore();

describe('genomförda transaktioner', () => {
  test('kan inte raderas, inte ens av admin', async () => {
    await assertFails(deleteDoc(doc(admin(), 'transactions', 'done')));
  });

  test('kan arkiveras och återställas av admin', async () => {
    const ref = doc(admin(), 'transactions', 'done');
    await assertSucceeds(updateDoc(ref, { archived: true }));
    await assertSucceeds(updateDoc(ref, { archived: deleteField() }));
  });

  test('status kan inte ändras bort från genomförd', async () => {
    await assertFails(updateDoc(doc(admin(), 'transactions', 'done'), { status: 'customer_rejected' }));
  });

  test('admin kan ändra kundnamn och telefon', async () => {
    await assertSucceeds(updateDoc(doc(admin(), 'transactions', 'done'), { customerName: 'Ny', customerPhone: '1' }));
  });

  test('manager kan inte arkivera eller radera', async () => {
    const m = env.authenticatedContext('M').firestore();
    await assertFails(updateDoc(doc(m, 'transactions', 'done'), { archived: true }));
    await assertFails(deleteDoc(doc(m, 'transactions', 'done')));
  });
});

describe('ej genomförda transaktioner', () => {
  test('admin kan radera och ändra status', async () => {
    await assertSucceeds(updateDoc(doc(admin(), 'transactions', 'open'), { status: 'customer_rejected' }));
    await assertSucceeds(deleteDoc(doc(admin(), 'transactions', 'open')));
    let exists = true;
    await env.withSecurityRulesDisabled(async (ctx) => {
      exists = (await getDoc(doc(ctx.firestore(), 'transactions', 'open'))).exists();
    });
    assert.equal(exists, false);
  });
});
