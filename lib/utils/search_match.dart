/// Gemensam sökregel för alla sökrutor i appen.
///
/// Sökningen delas upp i ord och alla ord måste matcha.
/// - Ord med bara siffror (även med "#" först) matchar [ids] från början:
///   "0" ger 001–099, "00" ger 001–009. Från fyra siffror matchar de också
///   [phones] var som helst i numret.
/// - Andra ord matchar [texts] var som helst, utan hänsyn till stora/små
///   bokstäver.
bool matchesSearch(
  String query, {
  Iterable<String> ids = const [],
  Iterable<String> phones = const [],
  Iterable<String> texts = const [],
}) {
  final terms = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .map((t) => t.startsWith('#') ? t.substring(1) : t)
      .where((t) => t.isNotEmpty);

  final idList = ids.map((i) => i.trim()).where((i) => i.isNotEmpty).toList();
  final phoneDigits = phones.map((p) => p.replaceAll(_nonDigits, '')).toList();
  final haystack = texts.join('\n').toLowerCase();

  for (final term in terms) {
    if (_digits.hasMatch(term)) {
      final idMatch = idList.any((i) => i.startsWith(term));
      final phoneMatch =
          term.length >= 4 && phoneDigits.any((p) => p.contains(term));
      if (!idMatch && !phoneMatch) return false;
    } else if (!haystack.contains(term)) {
      return false;
    }
  }
  return true;
}

/// Sant om sökrutan är tom, och listan därför inte ska visas.
bool isEmptySearch(String query) => query.trim().isEmpty;

/// Fler träffar än så visas inte; man får skriva mer för att begränsa.
const maxSearchResults = 50;

final _digits = RegExp(r'^\d+$');
final _nonDigits = RegExp(r'\D');
