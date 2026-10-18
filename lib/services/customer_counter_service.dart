import 'package:cloud_firestore/cloud_firestore.dart';

/// Kund-ID:n delas ut från en gemensam räknare: `meta/customers.lastClientId`.
/// Både admin (som lägger till kunder) och kunder (som registrerar sig)
/// använder den, i en transaktion, så att två personer aldrig får samma ID.
class CustomerCounterService {
  CustomerCounterService._();

  /// Ser till att räknaren är minst lika hög som det högsta befintliga
  /// klient-ID:t. Behövs en gång för kunder som skapades innan räknaren
  /// delades (de fick ID efter antal kunder + 1). Körs av admin-appen.
  static Future<void> ensureAtLeastMax() async {
    final db = FirebaseFirestore.instance;

    final customers = await db.collection('customers').get();
    var maxId = 0;
    for (final doc in customers.docs) {
      final n = int.tryParse((doc.data()['clientId'] ?? '').toString());
      if (n != null && n > maxId) maxId = n;
    }

    final metaRef = db.collection('meta').doc('customers');
    await db.runTransaction((tx) async {
      final snap = await tx.get(metaRef);
      final current = (snap.data()?['lastClientId'] as num?)?.toInt() ?? 0;
      if (current < maxId) {
        tx.set(metaRef, {'lastClientId': maxId}, SetOptions(merge: true));
      }
    });
  }
}
