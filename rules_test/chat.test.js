// Tester av intern chatt per ärende (manager, kassör, partner).
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  addDoc, collection, doc, getDoc, getDocs, query, serverTimestamp, setDoc,
  updateDoc, where,
} from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-crm-rules-chat',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});

after(async () => {
  await env?.cleanup();
});

const txChat = {
  type: 'tx', refId: 't1', title: 'T-00001', officeIds: ['O1'], managerIds: [],
  cashierOfficeIds: ['O1'], cashierIds: [], partnerId: '',
};
const exChat = {
  type: 'ex', refId: 'e1', title: 'Växling', officeIds: ['O1'], managerIds: [],
  cashierOfficeIds: ['O1'], cashierIds: [], partnerId: 'P',
};

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users', 'M'), { role: 'manager', officeId: 'O1' });
    await setDoc(doc(db, 'users', 'M2'), { role: 'manager', officeId: 'O2' });
    await setDoc(doc(db, 'users', 'K'), { role: 'cashier' });
    await setDoc(doc(db, 'cashiers', 'K'), { officeId: 'O1' });
    await setDoc(doc(db, 'users', 'K2'), { role: 'cashier' });
    await setDoc(doc(db, 'cashiers', 'K2'), { officeId: 'O2' });
    await setDoc(doc(db, 'users', 'P'), { role: 'partner' });
    await setDoc(doc(db, 'users', 'C'), { role: 'customer' });
    await setDoc(doc(db, 'transactions', 't1'), { officeId: 'O1', customerId: 'C', status: 'customer_requested' });
    await setDoc(doc(db, 'partnerExchanges', 'e1'), { officeId: 'O1', partnerId: 'P', status: 'proposed' });
    await setDoc(doc(db, 'cashierTransfers', 'ct1'), {
      fromId: 'K', toId: 'K2', fromOfficeId: 'O1', toOfficeId: 'O2',
      fromManagerId: null, toManagerId: null, status: 'pending',
    });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();
const message = (uid, text = 'Hej') => ({ senderId: uid, senderName: uid, text, createdAt: serverTimestamp() });

describe('chatt i en kundtransaktion', () => {
  test('managern skapar chatten och skriver', async () => {
    await assertSucceeds(setDoc(doc(as('M'), 'chats', 'tx_t1'), { ...txChat, createdAt: serverTimestamp() }));
    await assertSucceeds(addDoc(collection(as('M'), 'chats', 'tx_t1', 'messages'), message('M')));
  });

  test('kontorets kassör läser och skriver, men inte kunden eller andra kontor', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => setDoc(doc(ctx.firestore(), 'chats', 'tx_t1'), txChat));
    await assertSucceeds(addDoc(collection(as('K'), 'chats', 'tx_t1', 'messages'), message('K')));
    await assertSucceeds(getDocs(collection(as('K'), 'chats', 'tx_t1', 'messages')));
    await assertFails(getDocs(collection(as('C'), 'chats', 'tx_t1', 'messages')));
    await assertFails(addDoc(collection(as('M2'), 'chats', 'tx_t1', 'messages'), message('M2')));
    await assertFails(addDoc(collection(as('K2'), 'chats', 'tx_t1', 'messages'), message('K2')));
  });

  test('kassören hittar kontorets chattar med en fråga', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => setDoc(doc(ctx.firestore(), 'chats', 'tx_t1'), txChat));
    await assertSucceeds(getDocs(query(collection(as('K'), 'chats'), where('cashierOfficeIds', 'array-contains', 'O1'))));
    await assertSucceeds(getDocs(query(collection(as('K'), 'chats'), where('cashierIds', 'array-contains', 'K'))));
    await assertFails(getDocs(query(collection(as('K2'), 'chats'), where('cashierOfficeIds', 'array-contains', 'O1'))));
  });

  test('fel deltagare eller fel ID nekas', async () => {
    await assertFails(setDoc(doc(as('M2'), 'chats', 'tx_t1'), { ...txChat, officeIds: ['O2'], cashierOfficeIds: ['O2'] }));
    await assertFails(setDoc(doc(as('M'), 'chats', 'tx_x'), txChat));
  });

  test('man kan inte skriva i någon annans namn', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => setDoc(doc(ctx.firestore(), 'chats', 'tx_t1'), txChat));
    await assertFails(addDoc(collection(as('K'), 'chats', 'tx_t1', 'messages'), message('M')));
  });
});

describe('chatt i en partnerväxling', () => {
  test('partnern och managern är med, inte en annan partner', async () => {
    await assertSucceeds(setDoc(doc(as('P'), 'chats', 'ex_e1'), exChat));
    await assertSucceeds(addDoc(collection(as('M'), 'chats', 'ex_e1', 'messages'), message('M')));
    await assertSucceeds(getDocs(query(collection(as('P'), 'chats'), where('partnerId', '==', 'P'))));
    await assertSucceeds(getDocs(query(collection(as('M'), 'chats'), where('officeIds', 'array-contains', 'O1'))));
  });
});

describe('chatt i en kassörsöverföring', () => {
  test('båda kassörerna och deras kontors managers', async () => {
    await assertSucceeds(setDoc(doc(as('K'), 'chats', 'ct_ct1'), {
      type: 'ct', refId: 'ct1', title: 'Överföring', officeIds: ['O1', 'O2'],
      managerIds: [null, null], cashierOfficeIds: [], cashierIds: ['K', 'K2'], partnerId: '',
    }));
    await assertSucceeds(addDoc(collection(as('K2'), 'chats', 'ct_ct1', 'messages'), message('K2')));
    await assertSucceeds(addDoc(collection(as('M2'), 'chats', 'ct_ct1', 'messages'), message('M2')));
    await assertFails(addDoc(collection(as('P'), 'chats', 'ct_ct1', 'messages'), message('P')));
  });
});

describe('olästa', () => {
  test('var och en sätter bara sin egen läsmarkering', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => setDoc(doc(ctx.firestore(), 'chats', 'tx_t1'), txChat));
    await assertSucceeds(updateDoc(doc(as('K'), 'chats', 'tx_t1'), { 'readBy.K': serverTimestamp() }));
    await assertFails(updateDoc(doc(as('K'), 'chats', 'tx_t1'), { 'readBy.M': serverTimestamp() }));
    await assertFails(updateDoc(doc(as('K'), 'chats', 'tx_t1'), { officeIds: ['O2'] }));
  });

  test('en chatt som inte finns kan kollas och visas tom', async () => {
    await assertSucceeds(getDoc(doc(as('M'), 'chats', 'tx_t1')));
    await assertSucceeds(getDocs(collection(as('M'), 'chats', 'tx_t1', 'messages')));
  });
});
