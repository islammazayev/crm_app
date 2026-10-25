import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/currencies.dart';

/// Rättar äldre data som använder "RUBLE"/"EURO" i stället för "RUB"/"EUR".
///
/// Körs av admin vid start (efter att reglerna är utrullade). Den är
/// idempotent: när allt redan är normaliserat görs inga skrivningar.
class CurrencyMigrationService {
  CurrencyMigrationService._();

  static Future<void> run() async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();
    var writes = 0;

    // ── Kontor: valutor, saldonycklar och betalningsmetoder ──────────
    final offices = await db.collection('offices').get();
    for (final doc in offices.docs) {
      final data = doc.data();
      final update = <String, dynamic>{};

      final rawCurrencies = (data['currencies'] as List? ?? []);
      if (needsCurrencyNormalization(rawCurrencies)) {
        update['currencies'] = normalizeCurrencies(rawCurrencies);
      }

      final rawBalances = data['balances'];
      if (rawBalances is Map && needsCurrencyNormalization(rawBalances.keys)) {
        final merged = <String, dynamic>{};
        rawBalances.forEach((k, v) {
          final key = normalizeCurrency(k.toString());
          final value = v is num ? v.toDouble() : 0.0;
          final prev = merged[key];
          merged[key] = (prev is double ? prev : 0.0) + value;
        });
        update['balances'] = merged;
      }

      final rawMethods = data['paymentMethods'] as List? ?? [];
      var methodsChanged = false;
      final methods = rawMethods.map((m) {
        if (m is! Map) return m;
        final map = Map<String, dynamic>.from(m);
        final supported = map['supportedFromCurrencies'] as List? ?? [];
        if (needsCurrencyNormalization(supported)) {
          map['supportedFromCurrencies'] = normalizeCurrencies(supported);
          methodsChanged = true;
        }
        return map;
      }).toList();
      if (methodsChanged) update['paymentMethods'] = methods;

      if (update.isNotEmpty) {
        batch.update(doc.reference, update);
        writes++;
      }
    }

    // ── Transaktioner med gamla koder ────────────────────────────────
    const legacy = ['RUBLE', 'EURO'];
    for (final field in ['fromCurrency', 'toCurrency']) {
      final snap = await db
          .collection('transactions')
          .where(field, whereIn: legacy)
          .get();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {
          field: normalizeCurrency((doc.data()[field] ?? '').toString()),
        });
        writes++;
      }
    }

    if (writes > 0) await batch.commit();
  }
}
