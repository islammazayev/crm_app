import 'package:cloud_firestore/cloud_firestore.dart';

/// Håller `officeListings` i synk med `offices`.
///
/// `offices` innehåller privat information (saldon, betalningsuppgifter,
/// manager) som bara admin och kontorets manager får läsa. Kunder behöver
/// bara veta vilka kontor som finns och vilka valutor de hanterar, och det
/// är exakt vad `officeListings/{officeId}` innehåller:
///
///   country, city, address, mapUrl, currencies, updatedAt
///
/// Adressen och kartlänken visas för kunder som betalar kontant.
///
/// Dokumenten skrivs bara av admin-appen (se firestore.rules).
class OfficeListingService {
  OfficeListingService._();

  static CollectionReference<Map<String, dynamic>> get _listings =>
      FirebaseFirestore.instance.collection('officeListings');

  static List<String> _currenciesOf(Map<String, dynamic> office) {
    return (office['currencies'] as List? ?? [])
        .map((e) => e.toString())
        .toList();
  }

  static Map<String, dynamic> _publicFields(Map<String, dynamic> office) {
    return {
      'country': (office['country'] ?? '').toString(),
      'city': (office['city'] ?? '').toString(),
      'address': (office['address'] ?? '').toString(),
      'mapUrl': (office['mapUrl'] ?? '').toString(),
      'currencies': _currenciesOf(office),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Skapar eller uppdaterar kontorets publika post.
  static Future<void> upsert(String officeId, Map<String, dynamic> office) {
    return _listings.doc(officeId).set(_publicFields(office));
  }

  /// Tar bort kontorets publika post.
  static Future<void> remove(String officeId) {
    return _listings.doc(officeId).delete();
  }

  /// Jämför alla kontor med deras publika poster och rättar det som avviker.
  /// Körs när admin öppnar appen, så att kontor som skapats före
  /// `officeListings` infördes (eller ändrats på annat sätt) hamnar rätt.
  static Future<void> syncAll() async {
    final db = FirebaseFirestore.instance;
    final offices = await db.collection('offices').get();
    final listings = await _listings.get();

    final listingById = {for (final l in listings.docs) l.id: l.data()};
    final officeIds = offices.docs.map((d) => d.id).toSet();

    final batch = db.batch();
    var writes = 0;

    for (final office in offices.docs) {
      final data = office.data();
      final existing = listingById[office.id];

      final inSync = existing != null &&
          (existing['country'] ?? '').toString() ==
              (data['country'] ?? '').toString() &&
          (existing['city'] ?? '').toString() ==
              (data['city'] ?? '').toString() &&
          (existing['address'] ?? '').toString() ==
              (data['address'] ?? '').toString() &&
          (existing['mapUrl'] ?? '').toString() ==
              (data['mapUrl'] ?? '').toString() &&
          _sameSet(_currenciesOf(existing), _currenciesOf(data));

      if (!inSync) {
        batch.set(_listings.doc(office.id), _publicFields(data));
        writes++;
      }
    }

    // Poster för kontor som inte längre finns.
    for (final id in listingById.keys) {
      if (!officeIds.contains(id)) {
        batch.delete(_listings.doc(id));
        writes++;
      }
    }

    if (writes > 0) {
      await batch.commit();
    }
  }

  static bool _sameSet(List<String> a, List<String> b) {
    return a.toSet().length == b.toSet().length &&
        a.toSet().containsAll(b.toSet());
  }
}
