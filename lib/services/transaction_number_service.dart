import 'package:cloud_firestore/cloud_firestore.dart';

/// Löpnummer för transaktioner (T-00001, T-00002 …).
///
/// Räknaren ligger i `meta/transactions.lastTransactionNo`. Numret delas ut i
/// samma Firestore-transaktion som transaktionen skapas, så två
/// transaktioner kan aldrig få samma nummer (reglerna kontrollerar det).
class TransactionNumberService {
  TransactionNumberService._();

  static final _db = FirebaseFirestore.instance;
  static DocumentReference<Map<String, dynamic>> get _counter =>
      _db.collection('meta').doc('transactions');

  /// Skapar en transaktion med nästa löpnummer och returnerar dess referens.
  static Future<DocumentReference<Map<String, dynamic>>> create(
    Map<String, dynamic> data,
  ) async {
    final ref = _db.collection('transactions').doc();
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_counter);
      final next =
          ((snap.data()?['lastTransactionNo'] as num?)?.toInt() ?? 0) + 1;
      tx.set(_counter, {'lastTransactionNo': next}, SetOptions(merge: true));
      tx.set(ref, {...data, 'transactionNo': next});
    });
    return ref;
  }

  /// Ger äldre transaktioner utan nummer nästa lediga nummer, i datumordning
  /// (äldst först). Körs av admin vid start; gör inget när alla har nummer.
  static Future<void> backfill() async {
    final all = await _db.collection('transactions').get();
    final missing =
        all.docs.where((d) => d.data()['transactionNo'] is! int).toList()
          ..sort((a, b) {
            DateTime? at(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                (d.data()['createAt'] as Timestamp?)?.toDate();
            final ta = at(a), tb = at(b);
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return ta.compareTo(tb);
          });
    if (missing.isEmpty) return;

    // Reservera ett block av nummer i räknaren först, så att nya
    // transaktioner som skapas samtidigt inte får samma nummer.
    final highest = all.docs
        .map((d) => d.data()['transactionNo'])
        .whereType<int>()
        .fold<int>(0, (a, b) => a > b ? a : b);
    final first = await _db.runTransaction<int>((tx) async {
      final snap = await tx.get(_counter);
      final last = (snap.data()?['lastTransactionNo'] as num?)?.toInt() ?? 0;
      final start = (last > highest ? last : highest) + 1;
      tx.set(_counter, {
        'lastTransactionNo': start + missing.length - 1,
      }, SetOptions(merge: true));
      return start;
    });

    for (var i = 0; i < missing.length; i += 400) {
      final batch = _db.batch();
      for (var j = i; j < missing.length && j < i + 400; j++) {
        batch.update(missing[j].reference, {'transactionNo': first + j});
      }
      await batch.commit();
    }
  }
}
