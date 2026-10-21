import 'package:crm_app/utils/customer_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const customers = [
    CustomerSearchEntry(
      docId: 'a',
      clientId: 2,
      firstName: 'Ali',
      lastName: 'Musaev',
      phone: '+46 70 123 45 67',
      places: ['Ryssland Grozny'],
    ),
    CustomerSearchEntry(
      docId: 'b',
      clientId: '007',
      firstName: 'Alina',
      lastName: 'Svensson',
      phone: '0731112233',
      email: 'alina@example.com',
      places: ['Sverige Stockholm'],
    ),
    CustomerSearchEntry(
      docId: 'c',
      clientId: 12,
      firstName: 'Zelimkhan',
      lastName: 'Ali',
      phone: '',
    ),
    CustomerSearchEntry(
      docId: 'd',
      clientId: 120,
      firstName: 'Ayşe',
      lastName: 'Yılmaz',
      phone: '+90 555 000 11 22',
      places: ['Turkiet Istanbul'],
    ),
  ];

  List<String> ids(String q) =>
      searchCustomers(customers, q).map((e) => e.docId).toList();

  group('klient-ID från början', () {
    test('tom sökning visar alla, sorterade på klient-ID', () {
      expect(ids(''), ['a', 'b', 'c', 'd']);
    });
    test('"0" visar alla som börjar på 0', () {
      expect(ids('0'), ['a', 'b', 'c']);
    });
    test('"00" visar bara 001–009', () {
      expect(ids('00'), ['a', 'b']);
    });
    test('"002" visar exakt den kunden', () {
      expect(ids('002'), ['a']);
    });
    test('"12" matchar 012 och 120', () {
      expect(ids('12'), ['c', 'd']);
    });
    test('"#007" fungerar också', () {
      expect(ids('#007'), ['b']);
    });
    test('fyra siffror matchar även telefon', () {
      expect(ids('5550'), ['d']);
      expect(ids('1122'), ['b', 'd']);
    });
  });

  group('text', () {
    test('förnamn och efternamn, var som helst i texten', () {
      expect(ids('ali'), ['a', 'b', 'c']);
      expect(ids('ALINA'), ['b']);
    });
    test('land och stad från kontoren', () {
      expect(ids('grozny'), ['a']);
      expect(ids('sverige'), ['b']);
    });
    test('e-post', () {
      expect(ids('example'), ['b']);
    });
    test('alla ord måste matcha', () {
      expect(ids('ali grozny'), ['a']);
      expect(ids('ali 00'), ['a', 'b']);
      expect(ids('ali istanbul'), isEmpty);
    });
    test('turkiska tecken', () {
      expect(ids('yılmaz'), ['d']);
    });
  });
}
