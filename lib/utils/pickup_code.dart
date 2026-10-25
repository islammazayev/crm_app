import 'dart:math';

final _random = Random.secure();

/// Ny uthämtningskod: datumet då den skapas (ÅÅMMDD) och åtta slumpade
/// siffror, t.ex. "261023-4821-7730". Datumet gör koden lätt att söka på.
String newPickupCode([DateTime? now]) {
  final d = now ?? DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  String four() => _random.nextInt(10000).toString().padLeft(4, '0');
  final date = '${two(d.year % 100)}${two(d.month)}${two(d.day)}';
  return '$date-${four()}-${four()}';
}

const _tokenChars =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

/// Hemlig nyckel i QR-koden: 32 slumpade tecken (cirka 190 bitar), så den
/// går inte att gissa.
String newPickupToken() => List.generate(
  32,
  (_) => _tokenChars[_random.nextInt(_tokenChars.length)],
).join();

const _qrPrefix = 'crmpickup:v1:';

/// Innehållet i kundens QR-kod.
String pickupQrPayload(String transactionId, String token) =>
    '$_qrPrefix$transactionId:$token';

/// Läser en skannad QR-kod. Null om det inte är en uthämtningskod från appen.
({String transactionId, String token})? parsePickupQr(String raw) {
  final text = raw.trim();
  if (!text.startsWith(_qrPrefix)) return null;
  final parts = text.substring(_qrPrefix.length).split(':');
  if (parts.length != 2 || parts[0].isEmpty || parts[1].length < 32) {
    return null;
  }
  return (transactionId: parts[0], token: parts[1]);
}

/// Jämför nycklar utan att avslöja hur många tecken som stämde.
bool pickupTokenMatches(String a, String b) {
  if (a.isEmpty || a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

/// Jämför en inskriven kod med den riktiga. Mellanslag och bindestreck
/// spelar ingen roll, så "261023 4821 7730" godtas också.
bool pickupCodeMatches(String entered, String code) {
  String digits(String s) => s.replaceAll(RegExp(r'\D'), '');
  final e = digits(entered);
  return e.isNotEmpty && e == digits(code);
}
