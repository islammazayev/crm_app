// Tester av "Skicka pengar": samma valuta går och utbetalningslandet.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, serverTimestamp, setDoc, writeBatch } from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-crm-rules-send',
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
    // O1 har utbetalningsländer, O2 har inga.
    await setDoc(doc(db, 'officeListings', 'O1'), {
      currencies: ['EUR', 'USD'], pickupCountries: ['RU', 'TR'],
    });
    await setDoc(doc(db, 'officeListings', 'O2'), { currencies: ['EUR', 'USD'] });
    await setDoc(doc(db, 'offices', 'O1'), { balances: { EUR: 500 } });
    await setDoc(doc(db, 'transactions', 'same'), {
      status: 'payment_confirmed', officeId: 'O1', customerId: 'C',
      fromCurrency: 'EUR', toCurrency: 'EUR', amountFrom: 100, amountToNet: 97,
      pickupCode: '261122-1234-5678',
    });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

const request = (extra) => ({
  customerId: 'C', clientId: '1', customerName: 'K', customerPhone: '1',
  officeId: 'O1', fromCurrency: 'EUR', toCurrency: 'USD', amountFrom: 100,
  amountTo: null, feePercent: null, feeAmount: null, paymentMethod: null,
  status: 'customer_requested', createAt: serverTimestamp(), ...extra,
});

describe('skicka pengar', () => {
  test('samma valuta går (EUR → EUR)', async () => {
    await assertSucceeds(setDoc(doc(as('C'), 'transactions', 't1'),
      request({ toCurrency: 'EUR', pickupCountry: 'RU' })));
  });

  test('landet måste väljas bland kontorets länder', async () => {
    await assertSucceeds(setDoc(doc(as('C'), 'transactions', 't1'), request({ pickupCountry: 'TR' })));
    await assertFails(setDoc(doc(as('C'), 'transactions', 't2'), request({})));
    await assertFails(setDoc(doc(as('C'), 'transactions', 't3'), request({ pickupCountry: 'SE' })));
  });

  test('kontor utan länder: inget land', async () => {
    await assertSucceeds(setDoc(doc(as('C'), 'transactions', 't1'), request({ officeId: 'O2' })));
    await assertFails(setDoc(doc(as('C'), 'transactions', 't2'),
      request({ officeId: 'O2', pickupCountry: 'RU' })));
  });

  test('köp och sälj kräver fortfarande olika valutor och inget land', async () => {
    await assertFails(setDoc(doc(as('C'), 'transactions', 't1'),
      request({ kind: 'sell', deliveryMethod: 'cash', toCurrency: 'EUR' })));
    await assertSucceeds(setDoc(doc(as('C'), 'transactions', 't2'), request({ kind: 'sell', deliveryMethod: 'cash' })));
    await assertFails(setDoc(doc(as('C'), 'transactions', 't3'),
      request({ kind: 'sell', deliveryMethod: 'cash', pickupCountry: 'RU' })));
  });
});

describe('genomföra med samma valuta', () => {
  const complete = (eur) => {
    const db = as('M');
    const batch = writeBatch(db);
    batch.update(doc(db, 'transactions', 'same'), {
      status: 'completed', payoutCode: '261122-1234-5678',
    });
    batch.update(doc(db, 'offices', 'O1'), {
      balances: { EUR: eur }, lastBookedTransactionId: 'same',
    });
    return batch.commit();
  };

  test('saldot ändras med in minus ut', async () => {
    await assertFails(complete(600));
    await assertSucceeds(complete(503));
  });
});
