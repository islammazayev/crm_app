import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Slår ihop flera Firestore-frågor till en ström (utan dubbletter).
///
/// Behövs när reglerna kräver en fråga per villkor, t.ex. "skickade av
/// mig" och "skickade till mig", eller managerns kontor och manager-id.
Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> mergedQuery(
  List<Query<Map<String, dynamic>>> queries,
) {
  if (queries.isEmpty) return Stream.value(const []);
  late final StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  controller;
  final latest =
      List<List<QueryDocumentSnapshot<Map<String, dynamic>>>?>.filled(
        queries.length,
        null,
      );
  final subs = <StreamSubscription>[];

  void emit() {
    if (latest.any((l) => l == null)) return;
    final byId = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final list in latest) {
      for (final d in list!) {
        byId[d.id] = d;
      }
    }
    controller.add(byId.values.toList());
  }

  controller = StreamController(
    onListen: () {
      for (var i = 0; i < queries.length; i++) {
        subs.add(
          queries[i].snapshots().listen((snap) {
            latest[i] = snap.docs;
            emit();
          }, onError: controller.addError),
        );
      }
    },
    onCancel: () async {
      for (final s in subs) {
        await s.cancel();
      }
    },
  );
  return controller.stream;
}
