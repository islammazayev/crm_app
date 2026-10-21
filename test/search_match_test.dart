import 'package:crm_app/utils/search_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tom sökning räknas som tom', () {
    expect(isEmptySearch(''), isTrue);
    expect(isEmptySearch('   '), isTrue);
    expect(isEmptySearch(' a '), isFalse);
  });

  group('kontor', () {
    bool office(String q) =>
        matchesSearch(q, texts: ['Ryssland', 'Grozny', 'RUB', 'USD']);

    test('land, stad och valuta', () {
      expect(office('gro'), isTrue);
      expect(office('ryss'), isTrue);
      expect(office('usd'), isTrue);
      expect(office('ryssland usd'), isTrue);
      expect(office('sek'), isFalse);
    });
    test('siffror matchar inget utan id eller telefon', () {
      expect(office('1'), isFalse);
    });
  });

  group('manager', () {
    bool manager(String q) => matchesSearch(
      q,
      phones: ['+46 70-123 45 67'],
      texts: [
        'Adam',
        'Doe',
        'adam@kontor.se',
        '+46 70-123 45 67',
        'Sverige Malmö',
      ],
    );

    test('namn, e-post och kontor', () {
      expect(manager('ada'), isTrue);
      expect(manager('kontor.se'), isTrue);
      expect(manager('malmö'), isTrue);
    });
    test('telefon från fyra siffror, oavsett mellanslag och bindestreck', () {
      expect(manager('7012'), isTrue);
      expect(manager('701'), isFalse);
    });
  });

  group('transaktion', () {
    bool tx(String q) => matchesSearch(
      q,
      ids: ['007', '7'],
      phones: ['0731112233'],
      texts: ['Ali Musaev', 'Ryssland Grozny', 'SEK', 'RUB', 'Genomförd'],
    );

    test('klient-ID från början', () {
      expect(tx('0'), isTrue);
      expect(tx('00'), isTrue);
      expect(tx('007'), isTrue);
      expect(tx('008'), isFalse);
      expect(tx('#007'), isTrue);
    });
    test('status, valuta och namn tillsammans', () {
      expect(tx('genomförd rub ali'), isTrue);
      expect(tx('genomförd eur'), isFalse);
    });
  });
}
