/// Gemensam lista och normalisering av valutakoder.
///
/// Appen använder ISO-liknande koder överallt (RUB, EUR, USD, ...). Äldre data
/// kan innehålla "RUBLE" eller "EURO"; [normalizeCurrency] gör om dem.
const List<String> kSupportedCurrencies = [
  'EUR', 'USD', 'SEK', 'RUB', 'USDT', 'GBP', 'AED', 'TRY',
];

const Map<String, String> _aliases = {
  'RUBLE': 'RUB',
  'RUBLES': 'RUB',
  'EURO': 'EUR',
  'EUROS': 'EUR',
  'DOLLAR': 'USD',
  'KRONA': 'SEK',
};

/// Versaler, utan mellanslag, och kända alias omvandlade till standardkod.
String normalizeCurrency(String code) {
  final c = code.trim().toUpperCase();
  return _aliases[c] ?? c;
}

/// Normaliserar en lista och tar bort dubbletter (ordningen bevaras).
List<String> normalizeCurrencies(Iterable<Object?> codes) {
  final out = <String>[];
  for (final c in codes) {
    final n = normalizeCurrency(c.toString());
    if (n.isNotEmpty && !out.contains(n)) out.add(n);
  }
  return out;
}

/// Finns det några värden som inte redan är i standardform?
bool needsCurrencyNormalization(Iterable<Object?> codes) {
  return codes.any((c) => normalizeCurrency(c.toString()) != c.toString());
}
