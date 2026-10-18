import 'package:flutter/foundation.dart';

/// Läser ett kontors `balances`-fält på ett säkert sätt.
///
/// Fältet ska vara en karta som { "USD": 10000, "RUBLE": 500000 }. Om någon
/// har skrivit in ett värde som text (t.ex. i Firebase-konsolen) ska appen
/// inte krascha: tal läses som de är, text som ser ut som ett tal omvandlas
/// och allt annat blir 0 och loggas, så att dokumentet går att hitta och rätta.
Map<String, double> parseBalances(Object? raw, {String? officeId}) {
  final result = <String, double>{};
  if (raw is! Map) return result;

  raw.forEach((key, value) {
    double? parsed;
    if (value is num) {
      parsed = value.toDouble();
    } else if (value is String) {
      parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    }

    if (parsed == null) {
      debugPrint(
        'Ogiltigt saldo i kontor ${officeId ?? '?'}: "$key" = $value '
        '(ska vara ett tal). Behandlas som 0.',
      );
      parsed = 0.0;
    }

    result[key.toString()] = parsed;
  });

  return result;
}
