import 'package:cloud_firestore/cloud_firestore.dart';

import 'merged_query.dart';

/// Kundens transaktioner: de kunden själv har skickat, och de managern har
/// skapat på kontoret med kundens klient-ID (innan kunden hade konto).
/// En fråga per villkor, så att reglerna kan godkänna dem.
Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> customerTransactions(
  String uid,
) async* {
  final db = FirebaseFirestore.instance;
  final tx = db.collection('transactions');
  Object? clientId;
  try {
    clientId = (await db.collection('customers').doc(uid).get())
        .data()?['clientId'];
  } catch (_) {}
  yield* mergedQuery([
    tx.where('customerId', isEqualTo: uid),
    if (clientId != null)
      tx
          .where('customerId', isEqualTo: '')
          .where('clientId', isEqualTo: '$clientId'),
  ]);
}
