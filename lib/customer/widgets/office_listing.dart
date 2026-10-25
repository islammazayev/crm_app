import 'package:cloud_firestore/cloud_firestore.dart';

import '../../l10n/app_localizations.dart';

/// Ett kontor så som kunden får se det (från `officeListings`):
/// bara land, stad och vilka valutor kontoret hanterar.
class OfficeListing {
  final String id;
  final String country;
  final String city;
  final List<String> currencies;

  OfficeListing({
    required this.id,
    required this.country,
    required this.city,
    required this.currencies,
  });

  factory OfficeListing.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return OfficeListing(
      id: doc.id,
      country: (data['country'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      currencies: (data['currencies'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  String label(AppLocalizations l10n) {
    if (city.isEmpty) return country.isEmpty ? l10n.office : country;
    return country.isEmpty ? city : '$city – $country';
  }
}

/// Alla kontor som kunder kan välja (officeListings).
Future<List<OfficeListing>> loadOfficeListings() async {
  final snap = await FirebaseFirestore.instance
      .collection('officeListings')
      .get();
  return snap.docs.map(OfficeListing.fromDoc).toList();
}
