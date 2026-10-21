import 'client_id.dart';

/// En kund som den visas och söks i adminens kundlista.
class CustomerSearchEntry {
  final String docId;
  final Object? clientId;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  /// "Land Stad" för de kontor kunden har gjort transaktioner via.
  final List<String> places;

  const CustomerSearchEntry({
    required this.docId,
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email = '',
    this.places = const [],
  });

  String get formattedClientId => formatClientId(clientId);

  String get fullName => '$firstName $lastName'.trim();

  /// Klient-ID som tal, för sortering. Saknas det hamnar kunden sist.
  int get sortKey => int.tryParse('${clientId ?? ''}'.trim()) ?? 1 << 30;
}

final _digits = RegExp(r'^\d+$');
final _nonDigits = RegExp(r'\D');

/// Sant om [entry] matchar sökningen [query].
///
/// Sökningen delas upp i ord och alla ord måste matcha.
/// - Ord med bara siffror (även med "#" först) matchar klient-ID från början:
///   "0" ger 001–099, "00" ger 001–009, "002" ger 002. Från fyra siffror
///   matchar de också telefonnumret.
/// - Andra ord matchar förnamn, efternamn, telefon, e-post, land eller stad
///   var som helst i texten, utan hänsyn till stora/små bokstäver.
bool matchesCustomerQuery(CustomerSearchEntry entry, String query) {
  final terms = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty);

  final idText = entry.formattedClientId;
  final rawId = '${entry.clientId ?? ''}'.trim();
  final phoneDigits = entry.phone.replaceAll(_nonDigits, '');
  final haystack = [
    entry.firstName,
    entry.lastName,
    entry.phone,
    entry.email,
    ...entry.places,
  ].join('\n').toLowerCase();

  for (final raw in terms) {
    final term = raw.startsWith('#') ? raw.substring(1) : raw;
    if (term.isEmpty) continue;

    if (_digits.hasMatch(term)) {
      final idMatch = idText.startsWith(term) || rawId.startsWith(term);
      final phoneMatch = term.length >= 4 && phoneDigits.contains(term);
      if (!idMatch && !phoneMatch) return false;
    } else if (!haystack.contains(term)) {
      return false;
    }
  }
  return true;
}

/// Filtrerar och sorterar på klient-ID.
List<CustomerSearchEntry> searchCustomers(
  Iterable<CustomerSearchEntry> entries,
  String query,
) {
  return entries.where((e) => matchesCustomerQuery(e, query)).toList()
    ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
}
