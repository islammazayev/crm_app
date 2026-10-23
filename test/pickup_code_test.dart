import 'package:crm_app/utils/pickup_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nya koder har formatet 1234-5678', () {
    for (var i = 0; i < 200; i++) {
      expect(newPickupCode(), matches(RegExp(r'^\d{4}-\d{4}$')));
    }
  });

  test('inskriven kod godtas oavsett mellanslag och bindestreck', () {
    expect(pickupCodeMatches('4821-7730', '4821-7730'), isTrue);
    expect(pickupCodeMatches('48217730', '4821-7730'), isTrue);
    expect(pickupCodeMatches(' 4821 7730 ', '4821-7730'), isTrue);
    expect(pickupCodeMatches('4821-7731', '4821-7730'), isFalse);
    expect(pickupCodeMatches('', '4821-7730'), isFalse);
  });
}
