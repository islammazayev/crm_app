// Ren logik för inbjudnings-SMS (testas med `npm test`, utan Firebase).

const crypto = require('crypto');

const LIVE_ORIGIN = 'https://crm-app-1e5fe.web.app';

/// Länken pekar på livelänken, eller på projektets egen testlänk om admin
/// använder den. Andra adresser godtas inte.
function inviteOrigin(origin) {
  const ok = /^https:\/\/crm-app-1e5fe(--[a-z0-9-]+)?\.(web\.app|firebaseapp\.com)$/;
  return typeof origin === 'string' && ok.test(origin) ? origin : LIVE_ORIGIN;
}

/// Telefonnummer med landskod, t.ex. +46701234567. Annars null.
function e164(phone) {
  const p = String(phone || '').replace(/[\s\-()]/g, '');
  return /^\+[1-9]\d{6,14}$/.test(p) ? p : null;
}

/// Samma slags kod som appen skapar (32 tecken, inga punkter).
function newInviteCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
  const bytes = crypto.randomBytes(32);
  return Array.from(bytes, (b) => chars[b % chars.length]).join('');
}

/// Meddelandet: appens text med "{link}" ersatt av länken.
function inviteMessage(template, link) {
  const t = String(template || '').slice(0, 500);
  return t.includes('{link}') ? t.replace('{link}', link) : `${t} ${link}`.trim();
}

module.exports = { inviteOrigin, e164, newInviteCode, inviteMessage, LIVE_ORIGIN };
