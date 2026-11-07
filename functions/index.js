const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');
const { inviteOrigin, e164, newInviteCode, inviteMessage } = require('./invite');

admin.initializeApp();

// 46elks API-uppgifter. Läggs in med:
//   firebase functions:secrets:set ELKS_API_USERNAME
//   firebase functions:secrets:set ELKS_API_PASSWORD
const ELKS_USER = defineSecret('ELKS_API_USERNAME');
const ELKS_PASS = defineSecret('ELKS_API_PASSWORD');

/// Avsändarnamnet som kunden ser (högst 11 tecken).
const SMS_FROM = 'GreenTex';

/// Admin skickar en länk via SMS till en kund utan konto. Kunden skapar
/// bara lösenord och behåller sitt klient-ID (inviteByAdmin).
exports.sendCustomerInvite = onCall(
  { region: 'europe-west1', secrets: [ELKS_USER, ELKS_PASS] },
  async (req) => {
    if (!req.auth) throw new HttpsError('unauthenticated', 'Logga in först.');
    const db = admin.firestore();
    const me = await db.doc(`users/${req.auth.uid}`).get();
    if (me.get('role') !== 'admin') {
      throw new HttpsError('permission-denied', 'Bara admin.');
    }

    const docId = String(req.data?.docId || '');
    if (!docId || docId.includes('/')) {
      throw new HttpsError('invalid-argument', 'docId saknas.');
    }
    const ref = db.collection('customers').doc(docId);
    const snap = await ref.get();
    if (!snap.exists) throw new HttpsError('not-found', 'Kunden finns inte.');
    const c = snap.data();
    if (c.userId) {
      throw new HttpsError('failed-precondition', 'already-has-account');
    }
    const to = e164(c.phone);
    if (!to) throw new HttpsError('failed-precondition', 'phone-needs-country-code');

    const code =
      typeof c.inviteCode === 'string' && c.inviteCode.length >= 24
        ? c.inviteCode
        : newInviteCode();
    await ref.update({
      inviteCode: code,
      inviteByAdmin: true,
      invitedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const link = `${inviteOrigin(req.data?.origin)}/?invite=${docId}.${code}`;
    const message = inviteMessage(req.data?.message, link);

    const auth = Buffer.from(`${ELKS_USER.value()}:${ELKS_PASS.value()}`).toString('base64');
    const res = await fetch('https://api.46elks.com/a1/sms', {
      method: 'POST',
      headers: {
        Authorization: `Basic ${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({ from: SMS_FROM, to, message }).toString(),
    });
    if (!res.ok) {
      const text = await res.text();
      console.error('46elks', res.status, text);
      throw new HttpsError('internal', `sms-failed: ${text.slice(0, 200)}`);
    }
    return { sent: true, to };
  },
);
