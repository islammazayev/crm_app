import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class OrderReport extends StatelessWidget {
  final List<TransactionModel> transactions;
  const OrderReport({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    double profit = transactions.fold(0, (sum, t) => sum + t.fee);
    int count = transactions.length;

    // Skapa summering per dag
    final perDay = <String, double>{};
    final dateFormat = DateFormat('yyyy-MM-dd');
    for (final t in transactions) {
      final key = dateFormat.format(t.date);
      perDay[key] = (perDay[key] ?? 0) + t.fee;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Totalt antal ordrar: $count",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "Total företagets vinst: ${profit.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text("Vinst per dag:", style: TextStyle(fontWeight: FontWeight.bold)),
          for (final entry in perDay.entries)
            Text("${entry.key}: ${entry.value.toStringAsFixed(2)}"),
        ],
      ),
    );
  }
}
