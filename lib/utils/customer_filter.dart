import 'customer_search.dart';

/// Ordning i kundlistan.
enum CustomerSort { newest, name, clientId }

/// Filter i adminens kundlista. Tomt filter visar alla kunder.
class CustomerFilter {
  /// true: med konto i appen, false: utan konto, null: alla.
  final bool? account;

  /// En nivå ('silver', 'gold', 'diamond'), 'any' för någon nivå, 'none'
  /// för ingen nivå, eller null för alla.
  final String? tier;

  /// "Land Stad" för ett kontor som kunden har handlat via.
  final String? place;

  /// Senaste transaktionen inom så många dagar; 0 betyder aldrig handlat.
  final int? activeWithinDays;

  final DateTime? createdFrom;
  final DateTime? createdTo;
  final CustomerSort sort;

  const CustomerFilter({
    this.account,
    this.tier,
    this.place,
    this.activeWithinDays,
    this.createdFrom,
    this.createdTo,
    this.sort = CustomerSort.newest,
  });

  /// Antal aktiva avancerade filter (konto och nivå syns som snabbfilter).
  int get advancedCount => [
    place,
    activeWithinDays,
    createdFrom,
    createdTo,
  ].where((v) => v != null).length;

  bool get isEmpty => account == null && tier == null && advancedCount == 0;

  CustomerFilter copyWith({
    Object? account = _keep,
    Object? tier = _keep,
    Object? place = _keep,
    Object? activeWithinDays = _keep,
    Object? createdFrom = _keep,
    Object? createdTo = _keep,
    CustomerSort? sort,
  }) => CustomerFilter(
    account: account == _keep ? this.account : account as bool?,
    tier: tier == _keep ? this.tier : tier as String?,
    place: place == _keep ? this.place : place as String?,
    activeWithinDays: activeWithinDays == _keep
        ? this.activeWithinDays
        : activeWithinDays as int?,
    createdFrom: createdFrom == _keep
        ? this.createdFrom
        : createdFrom as DateTime?,
    createdTo: createdTo == _keep ? this.createdTo : createdTo as DateTime?,
    sort: sort ?? this.sort,
  );

  /// Behåller filtret som det var (för [copyWith]).
  static const _keep = Object();

  bool matches(CustomerSearchEntry e, DateTime now) {
    if (account != null && e.hasAccount != account) return false;
    if (tier != null) {
      final ok = switch (tier) {
        'none' => e.tier == null,
        'any' => e.tier != null,
        _ => e.tier == tier,
      };
      if (!ok) return false;
    }
    if (place != null && !e.places.contains(place)) return false;
    final days = activeWithinDays;
    if (days != null) {
      final last = e.lastActivity;
      if (days == 0) {
        if (last != null) return false;
      } else if (last == null || now.difference(last).inDays >= days) {
        return false;
      }
    }
    final from = createdFrom;
    final to = createdTo;
    if (from != null || to != null) {
      final created = e.createdAt;
      if (created == null) return false;
      if (from != null && created.isBefore(from)) return false;
      // "Till" gäller hela dagen.
      if (to != null && !created.isBefore(to.add(const Duration(days: 1)))) {
        return false;
      }
    }
    return true;
  }

  /// Sökning ([matchesCustomerQuery]) och filter, i vald ordning.
  List<CustomerSearchEntry> apply(
    Iterable<CustomerSearchEntry> entries,
    String query, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final list = entries
        .where((e) => query.trim().isEmpty || matchesCustomerQuery(e, query))
        .where((e) => matches(e, at))
        .toList();
    switch (sort) {
      case CustomerSort.newest:
        final old = DateTime(1970);
        list.sort((a, b) => (b.createdAt ?? old).compareTo(a.createdAt ?? old));
      case CustomerSort.name:
        list.sort(
          (a, b) =>
              a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );
      case CustomerSort.clientId:
        list.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    }
    return list;
  }
}
