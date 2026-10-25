// Tester av kundnivåer (Silver, Guld, Diamant) och avgiftstaket.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-crm-rules-tiers',
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
    await setDoc(doc(db, 'users', 'gold'), { role: 'customer' });
    await setDoc(doc(db, 'users', 'plain'), { role: 'customer' });
    await setDoc(doc(db, 'customers', 'gold'), { userId: 'gold', clientId: 1, tier: 'gold' });
    await setDoc(doc(db, 'customers', 'plain'), { userId: 'plain', clientId: 2 });
    await setDoc(doc(db, 'meta', 'tiers'), {
      standardFee: 5, discounts: { silver: 0.5, gold: 1, diamond: 2 },
    });
    await setDoc(doc(db, 'officeListings', 'O1'), { currencies: ['SEK', 'EUR'] });
    await setDoc(doc(db, 'transactions', 'capped'), {
      status: 'customer_requested', officeId: 'O1', customerId: 'gold',
      customerTier: 'gold', tierDiscount: 1, maxFeePercent: 4,
    });
    await setDoc(doc(db, 'transactions', 'free'), {
      status: 'customer_requested', officeId: 'O1', customerId: 'plain',
    });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

const request = (uid, extra = {}) => ({
  customerId: uid, clientId: '1', customerName: 'K', customerPhone: '1',
  officeId: 'O1', fromCurrency: 'SEK', toCurrency: 'EUR', amountFrom: 100,
  amountTo: null, feePercent: null, feeAmount: null, paymentMethod: null,
  status: 'customer_requested', createAt: serverTimestamp(), ...extra,
});

describe('kundens förfrågan', () => {
  test('kund med nivå skickar rätt nivå och tak', async () => {
    await assertSucceeds(setDoc(doc(as('gold'), 'transactions', 't1'),
      request('gold', { customerTier: 'gold', tierDiscount: 1, maxFeePercent: 4 })));
  });

  test('fel tak eller saknad nivå nekas', async () => {
    await assertFails(setDoc(doc(as('gold'), 'transactions', 't1'),
      request('gold', { customerTier: 'gold', tierDiscount: 3, maxFeePercent: 2 })));
    await assertFails(setDoc(doc(as('gold'), 'transactions', 't2'), request('gold')));
  });

  test('egen rabatt för kunden går före nivåns', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'customers', 'gold'), { tierDiscount: 1.5 });
    });
    await assertSucceeds(setDoc(doc(as('gold'), 'transactions', 't1'),
      request('gold', { customerTier: 'gold', tierDiscount: 1.5, maxFeePercent: 3.5 })));
  });

  test('kund utan nivå får inte hitta på en', async () => {
    await assertSucceeds(setDoc(doc(as('plain'), 'transactions', 't1'), request('plain')));
    await assertFails(setDoc(doc(as('plain'), 'transactions', 't2'),
      request('plain', { customerTier: 'diamond', tierDiscount: 2, maxFeePercent: 3 })));
  });
});

describe('nivån sätts bara av admin', () => {
  test('kunden kan inte ge sig själv nivå eller rabatt', async () => {
    await assertFails(updateDoc(doc(as('plain'), 'customers', 'plain'), { tier: 'diamond' }));
    await assertFails(updateDoc(doc(as('gold'), 'customers', 'gold'), { tierDiscount: 4 }));
  });

  test('admin sätter nivå och rabatter', async () => {
    await assertSucceeds(updateDoc(doc(as('admin'), 'customers', 'plain'), { tier: 'silver' }));
    await assertSucceeds(updateDoc(doc(as('admin'), 'meta', 'tiers'), { standardFee: 4 }));
    await assertFails(updateDoc(doc(as('M'), 'meta', 'tiers'), { standardFee: 9 }));
  });
});

describe('managerns förslag', () => {
  const propose = (fee) => ({ status: 'manager_proposed', feePercent: fee, rateFromTo: 0.09 });

  test('avgift upp till taket godkänns, även lägre', async () => {
    await assertSucceeds(updateDoc(doc(as('M'), 'transactions', 'capped'), propose(4)));
    await assertSucceeds(updateDoc(doc(as('M'), 'transactions', 'capped'), propose(2.5)));
  });

  test('avgift över taket nekas', async () => {
    await assertFails(updateDoc(doc(as('M'), 'transactions', 'capped'), propose(4.5)));
  });

  test('kund utan nivå har inget tak', async () => {
    await assertSucceeds(updateDoc(doc(as('M'), 'transactions', 'free'), propose(7)));
  });
});
