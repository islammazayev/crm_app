import 'package:crm_app/utils/customer_filter.dart';
import 'package:crm_app/utils/customer_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 7, 12);
  final islam = CustomerSearchEntry(
    docId: 'a',
    clientId: 9,
    firstName: 'Islam',
    lastName: 'Mazayev',
    phone: '0729',
    hasAccount: true,
    tier: 'diamond',
    places: const ['Ryssland Grozny'],
    createdAt: DateTime(2026, 10, 1),
    lastActivity: DateTime(2026, 11, 5),
  );
  final abu = CustomerSearchEntry(
    docId: 'b',
    clientId: 12,
    firstName: 'Abu',
    lastName: 'Abueva',
    phone: '0701',
    hasAccount: true,
    places: const ['Ryssland Moskva'],
    createdAt: DateTime(2026, 11, 3),
    lastActivity: DateTime(2026, 8, 1),
  );
  final alvi = CustomerSearchEntry(
    docId: 'c',
    clientId: 6,
    firstName: 'Alvi',
    lastName: 'Bagiev',
    phone: '0739',
    createdAt: DateTime(2026, 9, 15),
  );
  final all = [islam, abu, alvi];
  List<String> names(CustomerFilter f, [String q = '']) =>
      f.apply(all, q, now: now).map((e) => e.firstName).toList();

  test('tomt filter visar alla, nyast först', () {
    expect(names(const CustomerFilter()), ['Abu', 'Islam', 'Alvi']);
  });

  test('konto och nivå', () {
    expect(names(const CustomerFilter(account: false)), ['Alvi']);
    expect(names(const CustomerFilter(tier: 'diamond')), ['Islam']);
    expect(names(const CustomerFilter(tier: 'none')), ['Abu', 'Alvi']);
  });

  test('ort och senaste transaktion', () {
    expect(names(const CustomerFilter(place: 'Ryssland Moskva')), ['Abu']);
    expect(names(const CustomerFilter(activeWithinDays: 7)), ['Islam']);
    expect(names(const CustomerFilter(activeWithinDays: 0)), ['Alvi']);
  });

  test('skapad mellan två datum, till-dagen räknas med', () {
    final f = CustomerFilter(
      createdFrom: DateTime(2026, 9, 1),
      createdTo: DateTime(2026, 10, 1),
    );
    expect(names(f), ['Islam', 'Alvi']);
  });

  test('sortering och sökning tillsammans med filter', () {
    expect(names(const CustomerFilter(sort: CustomerSort.name)), [
      'Abu',
      'Alvi',
      'Islam',
    ]);
    expect(names(const CustomerFilter(sort: CustomerSort.clientId)), [
      'Alvi',
      'Islam',
      'Abu',
    ]);
    expect(names(const CustomerFilter(account: true), 'abu'), ['Abu']);
  });

  test('antal avancerade filter och copyWith', () {
    const f = CustomerFilter(account: true);
    expect(f.advancedCount, 0);
    final g = f.copyWith(place: 'X', activeWithinDays: 30);
    expect(g.advancedCount, 2);
    expect(g.account, true);
    expect(g.copyWith(place: null).place, isNull);
    expect(g.copyWith(place: null).activeWithinDays, 30);
  });
}
