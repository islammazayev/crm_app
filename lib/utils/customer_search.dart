import 'client_id.dart';
import 'search_match.dart';

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

  /// Kundens nivå och ev. egen rabatt (se customer_tiers.dart).
  final String? tier;
  final double? tierDiscount;

  /// Kunden har ett konto i appen (bara då gäller nivån för förfrågningar).
  final bool hasAccount;

  const CustomerSearchEntry({
    required this.docId,
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email = '',
    this.places = const [],
    this.tier,
    this.tierDiscount,
    this.hasAccount = false,
  });

  String get formattedClientId => formatClientId(clientId);

  String get fullName => '$firstName $lastName'.trim();

  /// Klient-ID som tal, för sortering. Saknas det hamnar kunden sist.
  int get sortKey => int.tryParse('${clientId ?? ''}'.trim()) ?? 1 << 30;
}

/// Sant om [entry] matchar sökningen [query] (se [matchesSearch]).
/// Klient-ID matchar från början, övriga fält var som helst.
bool matchesCustomerQuery(CustomerSearchEntry entry, String query) {
  return matchesSearch(
    query,
    ids: [entry.formattedClientId, '${entry.clientId ?? ''}'],
    phones: [entry.phone],
    texts: [
      entry.firstName,
      entry.lastName,
      entry.phone,
      entry.email,
      ...entry.places,
    ],
  );
}

/// Filtrerar och sorterar på klient-ID.
List<CustomerSearchEntry> searchCustomers(
  Iterable<CustomerSearchEntry> entries,
  String query,
) {
  return entries.where((e) => matchesCustomerQuery(e, query)).toList()
    ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
}
