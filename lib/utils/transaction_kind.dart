import '../l10n/app_localizations.dart';

/// Sant om transaktionen är ett köp (se BuySection): kunden anger hur mycket
/// hen vill få (buyAmount i toCurrency), och managern räknar ut amountFrom.
bool isBuyTransaction(Map<String, dynamic> data) => data['kind'] == 'buy';

/// Sant om transaktionen är en försäljning: kunden säljer amountFrom
/// i fromCurrency och får toCurrency.
bool isSellTransaction(Map<String, dynamic> data) => data['kind'] == 'sell';

/// Sant om köpet eller försäljningen betalas ut till kundens bank i stället
/// för kontant.
bool isBankPayout(Map<String, dynamic> data) =>
    data['deliveryMethod'] == 'bank';

/// En rad som beskriver transaktionen i listor, t.ex. "1000 SEK → EUR",
/// "Köp 100 EUR med SEK · Bank" eller "Sälj 100 EUR för SEK · Kontant".
String transactionSummary(AppLocalizations l10n, Map<String, dynamic> data) {
  final from = (data['fromCurrency'] ?? '').toString();
  final to = (data['toCurrency'] ?? '').toString();
  if (isBuyTransaction(data)) {
    final amount = data['buyAmount'] ?? 0;
    final delivery = isBankPayout(data) ? l10n.deliveryBank : l10n.deliveryCash;
    return '${l10n.buySummary('$amount', to, from)} · $delivery';
  }
  if (isSellTransaction(data)) {
    final amount = data['amountFrom'] ?? 0;
    final delivery = isBankPayout(data) ? l10n.deliveryBank : l10n.deliveryCash;
    return '${l10n.sellSummary('$amount', from, to)} · $delivery';
  }
  return '${data['amountFrom'] ?? 0} $from → $to';
}
