import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Inga transaktioner ännu."),
      );
    }
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        return ListTile(
          title: Text("${t.receiver} (${t.city}, ${t.country})"),
          subtitle: Text(
            "Valuta: ${t.currency}, Belopp: ${t.amount}, Avgift: ${t.fee}",
          ),
        );
      },
      shrinkWrap: true, // Viktig rad
      physics: const NeverScrollableScrollPhysics(), // Viktig rad
    );
  }
}
