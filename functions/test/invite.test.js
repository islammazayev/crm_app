const test = require('node:test');
const assert = require('node:assert');
const { inviteOrigin, e164, newInviteCode, inviteMessage, LIVE_ORIGIN } = require('../invite');

test('länken pekar bara på projektets egna adresser', () => {
  assert.equal(inviteOrigin('https://crm-app-1e5fe.web.app'), LIVE_ORIGIN);
  assert.equal(
    inviteOrigin('https://crm-app-1e5fe--preview-l0nhj7xu.web.app'),
    'https://crm-app-1e5fe--preview-l0nhj7xu.web.app',
  );
  assert.equal(inviteOrigin('https://evil.example.com'), LIVE_ORIGIN);
  assert.equal(inviteOrigin(undefined), LIVE_ORIGIN);
});

test('telefon måste ha landskod', () => {
  assert.equal(e164('+46701234567'), '+46701234567');
  assert.equal(e164('+46 70-123 45 67'), '+46701234567');
  assert.equal(e164('0701234567'), null);
  assert.equal(e164(''), null);
});

test('koden är 32 tecken utan punkt', () => {
  const c = newInviteCode();
  assert.equal(c.length, 32);
  assert.ok(!c.includes('.'));
});

test('meddelandet får länken', () => {
  assert.equal(inviteMessage('Hej! Länk: {link}', 'https://x'), 'Hej! Länk: https://x');
  assert.equal(inviteMessage('Hej!', 'https://x'), 'Hej! https://x');
});
