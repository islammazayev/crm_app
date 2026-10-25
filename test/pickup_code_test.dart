import 'package:crm_app/utils/pickup_code.dart';
import 'package:crm_app/utils/pickup_code_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('koden börjar med datumet och har åtta slumpade siffror', () {
    final code = newPickupCode(DateTime(2026, 10, 23));
    expect(code, matches(RegExp(r'^261023-\d{4}-\d{4}$')));
    expect(newPickupCode(DateTime(2027, 1, 5)), startsWith('270105-'));
  });

  test('koder och nycklar blir olika varje gång', () {
    final codes = {for (var i = 0; i < 200; i++) newPickupCode()};
    expect(codes.length, greaterThan(190));
    final tokens = {for (var i = 0; i < 200; i++) newPickupToken()};
    expect(tokens.length, 200);
    expect(newPickupToken(), matches(RegExp(r'^[A-Za-z0-9]{32}$')));
  });

  test('QR-innehåll skrivs och läses tillbaka', () {
    final token = newPickupToken();
    final qr = pickupQrPayload('abc123', token);
    final parsed = parsePickupQr(qr);
    expect(parsed?.transactionId, 'abc123');
    expect(parsed?.token, token);
  });

  test('andra QR-koder avvisas', () {
    expect(parsePickupQr('https://example.com'), isNull);
    expect(parsePickupQr('crmpickup:v1:abc'), isNull);
    expect(parsePickupQr('crmpickup:v1:abc:kort'), isNull);
  });

  test('nyckeln måste stämma exakt', () {
    final t = newPickupToken();
    expect(pickupTokenMatches(t, t), isTrue);
    expect(pickupTokenMatches(t, newPickupToken()), isFalse);
    expect(pickupTokenMatches('', ''), isFalse);
  });

  test('inskriven kod godtas oavsett mellanslag och bindestreck', () {
    const code = '261023-4821-7730';
    expect(pickupCodeMatches('261023-4821-7730', code), isTrue);
    expect(pickupCodeMatches('26102348217730', code), isTrue);
    expect(pickupCodeMatches(' 261023 4821 7730 ', code), isTrue);
    expect(pickupCodeMatches('261023-4821-7731', code), isFalse);
    expect(pickupCodeMatches('', code), isFalse);
  });

  test('bindestrecken sätts in medan man skriver siffror', () {
    String type(String text) => PickupCodeInputFormatter()
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text))
        .text;
    expect(type('2610'), '2610');
    expect(type('2610234'), '261023-4');
    expect(type('26102348217730'), '261023-4821-7730');
    expect(type('261023-4821-77309'), '261023-4821-7730');
    expect(type('261023 48'), '261023-48');
  });
}
