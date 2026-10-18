import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class OrderReport extends StatelessWidget {
  final List<TransactionModel> transactions;
  const OrderReport({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Bara genomförda ordrar ger vinst. Avgiften ligger i den valuta kunden
    // skickar, så vinsten summeras per valuta och aldrig över valutor.
    final done = transactions.where((t) => t.isCompleted).toList();

    final profitByCurrency = <String, double>{};
    final perDay = <String, Map<String, double>>{};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final t in done) {
      final currency = t.currency.isEmpty ? '?' : t.currency;
      profitByCurrency[currency] = (profitByCurrency[currency] ?? 0) + t.fee;

      final day = dateFormat.format(t.date);
      final dayTotals = perDay.putIfAbsent(day, () => <String, double>{});
      dayTotals[currency] = (dayTotals[currency] ?? 0) + t.fee;
    }

    String format(Map<String, double> totals) {
      if (totals.isEmpty) return '0.00';
      return totals.entries
          .map((e) => '${e.value.toStringAsFixed(2)} ${e.key}')
          .join(' · ');
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Totalt antal ordrar: ${transactions.length} "
            "(genomförda: ${done.length})",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "Total företagets vinst (genomförda): ${format(profitByCurrency)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text("Vinst per dag:", style: TextStyle(fontWeight: FontWeight.bold)),
          for (final entry in perDay.entries)
            Text("${entry.key}: ${format(entry.value)}"),
        ],
      ),
    );
  }
}
