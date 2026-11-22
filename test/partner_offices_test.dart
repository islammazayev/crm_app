import 'package:crm_app/services/partner_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Partnerns kontor: listan (flera kontor) och äldre poster med ett kontor.
void main() {
  test('läser flera kontor med namn', () {
    expect(
      PartnerService.exchangeOffices({
        'exchangeOfficeIds': ['O1', 'O2'],
        'exchangeOffices': {'O1': 'Stockholm', 'O2': 'Göteborg'},
      }),
      {'O1': 'Stockholm', 'O2': 'Göteborg'},
    );
  });

  test('äldre post med ett kontor fungerar', () {
    expect(
      PartnerService.exchangeOffices({
        'exchangeOfficeId': 'O1',
        'exchangeOfficeLabel': 'Stockholm',
      }),
      {'O1': 'Stockholm'},
    );
  });

  test('inget kontor ger tom karta', () {
    expect(PartnerService.exchangeOffices({}), isEmpty);
    expect(PartnerService.exchangeOffices(null), isEmpty);
  });
}
