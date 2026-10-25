// Tester av kompanjoner: växling mellan ett kontor och en kompanjon.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  doc, increment, serverTimestamp, setDoc, updateDoc, writeBatch,
} from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-crm-rules-partners',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});

after(async () => {
  await env?.cleanup();
});

// Kontoret ger 1000 SEK och får 90 EUR av kompanjonen.
const terms = {
  officeGivesCurrency: 'SEK', officeGivesAmount: 1000,
  partnerGivesCurrency: 'EUR', partnerGivesAmount: 90,
};

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users', 'M'), { role: 'manager', officeId: 'O1' });
    await setDoc(doc(db, 'users', 'M2'), { role: 'manager', officeId: 'O2' });
    await setDoc(doc(db, 'users', 'P'), { role: 'partner' });
    await setDoc(doc(db, 'users', 'P2'), { role: 'partner' });
    await setDoc(doc(db, 'partners', 'P'), {
      managerId: 'M', exchangeOfficeId: 'O1', balances: { EUR: 500 },
    });
    await setDoc(doc(db, 'partners', 'P2'), {
      officeId: 'O2', exchangeOfficeId: 'O2', balances: {},
    });
    await setDoc(doc(db, 'offices', 'O1'), { balances: { SEK: 5000 } });
    await setDoc(doc(db, 'partnerExchanges', 'byOffice'), {
      ...terms, officeId: 'O1', partnerId: 'P', status: 'proposed', proposedBy: 'office',
    });
    await setDoc(doc(db, 'partnerExchanges', 'done'), {
      ...terms, officeId: 'O1', partnerId: 'P', status: 'accepted', proposedBy: 'office',
      officeSent: true, partnerSent: true,
    });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

const proposal = (extra) => ({
  ...terms, officeLabel: 'Kontor', partnerName: 'P', note: '',
  status: 'proposed', createdAt: serverTimestamp(), ...extra,
});

describe('förslag', () => {
  test('managern föreslår till sin kompanjon', async () => {
    await assertSucceeds(setDoc(doc(as('M'), 'partnerExchanges', 'e1'),
      proposal({ officeId: 'O1', managerId: 'M', partnerId: 'P', proposedBy: 'office' })));
  });

  test('managern kan inte föreslå till en annans kompanjon', async () => {
    await assertFails(setDoc(doc(as('M'), 'partnerExchanges', 'e1'),
      proposal({ officeId: 'O1', managerId: 'M', partnerId: 'P2', proposedBy: 'office' })));
  });

  test('kompanjonen föreslår bara till sitt eget kontor', async () => {
    await assertSucceeds(setDoc(doc(as('P'), 'partnerExchanges', 'e1'),
      proposal({ officeId: 'O1', managerId: '', partnerId: 'P', proposedBy: 'partner' })));
    await assertFails(setDoc(doc(as('P'), 'partnerExchanges', 'e2'),
      proposal({ officeId: 'O2', managerId: '', partnerId: 'P', proposedBy: 'partner' })));
  });

  test('samma valuta eller belopp 0 nekas', async () => {
    await assertFails(setDoc(doc(as('M'), 'partnerExchanges', 'e1'), proposal({
      officeId: 'O1', managerId: 'M', partnerId: 'P', proposedBy: 'office',
      partnerGivesCurrency: 'SEK',
    })));
    await assertFails(setDoc(doc(as('M'), 'partnerExchanges', 'e2'), proposal({
      officeId: 'O1', managerId: 'M', partnerId: 'P', proposedBy: 'office',
      officeGivesAmount: 0,
    })));
  });
});

describe('svar på förslag', () => {
  const ref = (uid) => doc(as(uid), 'partnerExchanges', 'byOffice');

  test('den andra sidan kan acceptera eller avböja, inte den som föreslog', async () => {
    await assertFails(updateDoc(ref('M'), { status: 'accepted' }));
    await assertSucceeds(updateDoc(ref('P'), { status: 'accepted' }));
  });

  test('motförslag byter vem som ska svara', async () => {
    await assertSucceeds(updateDoc(ref('P'), { partnerGivesAmount: 88, proposedBy: 'partner' }));
    await assertSucceeds(updateDoc(ref('M'), { status: 'accepted' }));
  });

  test('den som föreslog kan avbryta', async () => {
    await assertFails(updateDoc(ref('P'), { status: 'cancelled' }));
    await assertSucceeds(updateDoc(ref('M'), { status: 'cancelled' }));
  });

  test('andra kontor och kompanjoner kommer inte åt växlingen', async () => {
    await assertFails(updateDoc(ref('M2'), { status: 'accepted' }));
    await assertFails(updateDoc(ref('P2'), { status: 'accepted' }));
  });
});

describe('skickat och mottaget', () => {
  beforeEach(async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'partnerExchanges', 'acc'), {
        ...terms, officeId: 'O1', partnerId: 'P', status: 'accepted', proposedBy: 'office',
      });
    });
  });

  test('var sida markerar bara sina egna pengar som skickade', async () => {
    await assertSucceeds(updateDoc(doc(as('M'), 'partnerExchanges', 'acc'), { officeSent: true }));
    await assertFails(updateDoc(doc(as('M'), 'partnerExchanges', 'acc'), { partnerSent: true }));
  });

  test('mottaget först när den andra har skickat', async () => {
    await assertFails(updateDoc(doc(as('M'), 'partnerExchanges', 'acc'), { officeReceived: true }));
  });

  test('den första som tar emot ändrar inga saldon', async () => {
    await assertSucceeds(updateDoc(doc(as('P'), 'partnerExchanges', 'done'), { partnerReceived: true }));
  });

  // Den sista bekräftelsen bokför kontorets och kompanjonens saldo.
  const finish = (uid, overrides = {}) => {
    const db = as(uid);
    const batch = writeBatch(db);
    const side = uid === 'M' ? 'officeReceived' : 'partnerReceived';
    batch.update(doc(db, 'partnerExchanges', 'done'), { [side]: true, status: 'completed' });
    batch.update(doc(db, 'offices', 'O1'), {
      'balances.SEK': increment(overrides.officeSek ?? -1000),
      'balances.EUR': increment(90),
      lastPartnerExchangeId: 'done',
    });
    batch.update(doc(db, 'partners', 'P'), {
      'balances.SEK': increment(1000),
      'balances.EUR': increment(-90),
      lastExchangeId: 'done',
    });
    return batch.commit();
  };

  const otherReceived = async (field) => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'partnerExchanges', 'done'), { [field]: true });
    });
  };

  test('managern bekräftar sist och bokför båda saldona', async () => {
    await otherReceived('partnerReceived');
    await assertSucceeds(finish('M'));
  });

  test('kompanjonen bekräftar sist och bokför båda saldona', async () => {
    await otherReceived('officeReceived');
    await assertSucceeds(finish('P'));
  });

  test('fel belopp på kontoret nekas', async () => {
    await otherReceived('partnerReceived');
    await assertFails(finish('M', { officeSek: -900 }));
  });

  test('genomförd utan att saldona bokförs nekas', async () => {
    await otherReceived('partnerReceived');
    await assertFails(updateDoc(doc(as('M'), 'partnerExchanges', 'done'),
      { officeReceived: true, status: 'completed' }));
  });

  test('kontorets saldo kan inte bli negativt', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'offices', 'O1'), { 'balances.SEK': 500 });
    });
    await otherReceived('partnerReceived');
    await assertFails(finish('M'));
  });
});
