import 'package:crm_app/l10n/app_localizations.dart';
import 'package:crm_app/l10n/app_localizations_sv.dart';
import 'package:crm_app/utils/transaction_kind.dart';
import 'package:crm_app/widgets/pickup_countries_field.dart';
import 'package:flutter_test/flutter_test.dart';

/// Utbetalningslandet visas med flagga och namn, och i transaktionsraden.
void main() {
  final AppLocalizations l10n = AppLocalizationsSv();

  test('landskod blir flagga och namn', () {
    expect(countryLabel('RU'), '🇷🇺 Russia');
    expect(countryLabel('XX'), 'XX');
  });

  test('skicka-raden visar landet', () {
    expect(
      transactionSummary(l10n, {
        'fromCurrency': 'EUR',
        'toCurrency': 'EUR',
        'amountFrom': 100,
        'pickupCountry': 'TR',
      }),
      '100 EUR → EUR · 🇹🇷 Turkey',
    );
    expect(
      transactionSummary(l10n, {
        'fromCurrency': 'EUR',
        'toCurrency': 'USD',
        'amountFrom': 100,
      }),
      '100 EUR → USD',
    );
  });
}
