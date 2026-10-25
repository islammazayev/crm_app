// Tester av köp: kunden anger hur mycket hen vill köpa, kontant eller bank.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, serverTimestamp, setDoc, updateDoc, writeBatch } from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-crm-rules-buy',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});

after(async () => {
  await env?.cleanup();
});

const confirmed = (delivery) => ({
  status: 'payment_confirmed', officeId: 'O1', customerId: 'C',
  kind: 'buy', deliveryMethod: delivery, buyAmount: 100,
  fromCurrency: 'SEK', toCurrency: 'EUR', amountFrom: 1200, amountToNet: 100,
  pickupCode: '261025-1234-5678',
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users', 'M'), { role: 'manager', officeId: 'O1' });
    await setDoc(doc(db, 'users', 'C'), { role: 'customer' });
    await setDoc(doc(db, 'customers', 'C'), { userId: 'C', clientId: 1 });
    await setDoc(doc(db, 'officeListings', 'O1'), { currencies: ['SEK', 'EUR'] });
    await setDoc(doc(db, 'offices', 'O1'), { balances: { SEK: 0, EUR: 500 } });
    await setDoc(doc(db, 'transactions', 'req'), {
      status: 'customer_requested', officeId: 'O1', customerId: 'C',
      kind: 'buy', deliveryMethod: 'cash', buyAmount: 100, amountFrom: null,
    });
    await setDoc(doc(db, 'transactions', 'send'), {
      status: 'customer_requested', officeId: 'O1', customerId: 'C', amountFrom: 1000,
    });
    await setDoc(doc(db, 'transactions', 'bank'), confirmed('bank'));
    await setDoc(doc(db, 'transactions', 'cash'), confirmed('cash'));
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

const request = (extra) => ({
  customerId: 'C', clientId: '1', customerName: 'K', customerPhone: '1',
  officeId: 'O1', fromCurrency: 'SEK', toCurrency: 'EUR',
  amountTo: null, feePercent: null, feeAmount: null, paymentMethod: null,
  status: 'customer_requested', createAt: serverTimestamp(), ...extra,
});

describe('kundens köpförfrågan', () => {
  test('köp med belopp att köpa och kontant eller bank', async () => {
    await assertSucceeds(setDoc(doc(as('C'), 'transactions', 'b1'),
      request({ kind: 'buy', buyAmount: 100, deliveryMethod: 'cash', amountFrom: null })));
    await assertSucceeds(setDoc(doc(as('C'), 'transactions', 'b2'),
      request({ kind: 'buy', buyAmount: 100, deliveryMethod: 'bank', amountFrom: null })));
  });

  test('köp utan giltigt belopp eller sätt nekas', async () => {
    await assertFails(setDoc(doc(as('C'), 'transactions', 'b1'),
      request({ kind: 'buy', buyAmount: 0, deliveryMethod: 'cash', amountFrom: null })));
    await assertFails(setDoc(doc(as('C'), 'transactions', 'b2'),
      request({ kind: 'buy', buyAmount: 100, deliveryMethod: 'post', amountFrom: null })));
  });

  test('vanlig sändning fungerar som förut', async () => {
    await assertSucceeds(setDoc(doc(as('C'), 'transactions', 's1'), request({ amountFrom: 1000 })));
    await assertFails(setDoc(doc(as('C'), 'transactions', 's2'), request({ amountFrom: null })));
  });
});

describe('managerns förslag på köp', () => {
  const propose = (amountFrom, amountToNet) => ({
    status: 'manager_proposed', feePercent: 5, rateFromTo: 0.09, amountFrom, amountToNet,
  });

  test('beloppet att betala sätts så att kunden får det hen köper', async () => {
    await assertSucceeds(updateDoc(doc(as('M'), 'transactions', 'req'), propose(1169.59, 100)));
  });

  test('fel belopp till kunden nekas', async () => {
    await assertFails(updateDoc(doc(as('M'), 'transactions', 'req'), propose(1000, 85.5)));
  });

  test('beloppet i en vanlig sändning kan inte ändras', async () => {
    await assertFails(updateDoc(doc(as('M'), 'transactions', 'send'), propose(2000, 170)));
  });
});

describe('motbud på köp', () => {
  beforeEach(async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'transactions', 'req'), {
        status: 'customer_countered', feePercent: 5, counterFeePercent: 4,
        rateFromTo: 0.09, amountFrom: 1169.59, amountToNet: 100,
      });
    });
  });

  const accept = (amountFrom, amountToNet) => updateDoc(doc(as('M'), 'transactions', 'req'), {
    status: 'customer_accepted', feePercent: 4, rateFromTo: 0.09, amountFrom, amountToNet,
  });

  test('kunden betalar mindre men får samma belopp', async () => {
    await assertSucceeds(accept(1157.41, 100));
  });

  test('kunden kan inte få ett annat belopp', async () => {
    await assertFails(accept(1169.59, 101.05));
  });
});

describe('utbetalning till bank', () => {
  const bankDetails = { bankName: 'Nordea', bankPhone: '0701234567', bankAccountHolder: 'Islam M' };

  test('kunden fyller i bankuppgifter när betalningen är bekräftad', async () => {
    await assertSucceeds(updateDoc(doc(as('C'), 'transactions', 'bank'), bankDetails));
  });

  test('inte vid kontant och inte med tomma fält', async () => {
    await assertFails(updateDoc(doc(as('C'), 'transactions', 'cash'), bankDetails));
    await assertFails(updateDoc(doc(as('C'), 'transactions', 'bank'), { ...bankDetails, bankName: '' }));
  });

  const complete = (txId, extra = {}) => {
    const db = as('M');
    const batch = writeBatch(db);
    batch.update(doc(db, 'transactions', txId), { status: 'completed', ...extra });
    batch.update(doc(db, 'offices', 'O1'), {
      balances: { SEK: 1200, EUR: 400 }, lastBookedTransactionId: txId,
    });
    return batch.commit();
  };

  test('managern kan inte genomföra innan kunden har fyllt i banken', async () => {
    await assertFails(complete('bank'));
  });

  test('managern genomför utan kod när bankuppgifterna finns', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'transactions', 'bank'), bankDetails);
    });
    await assertSucceeds(complete('bank'));
  });

  test('kontant kräver fortfarande rätt kod', async () => {
    await assertFails(complete('cash', { payoutCode: 'fel' }));
    await assertSucceeds(complete('cash', { payoutCode: '261025-1234-5678' }));
  });
});
