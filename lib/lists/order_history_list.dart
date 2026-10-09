import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class OrderHistoryList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final void Function(int index) onDelete;
  const OrderHistoryList({super.key, required this.transactions, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Inga ordrar ännu."),
      );
    }
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        return ListTile(
          title: Text("${t.receiver} (${t.city}, ${t.country})"),
          subtitle: Text(
            "Valuta: ${t.currency}, Belopp: ${t.amount}, Avgift: ${t.fee}\n"
            "Datum: ${t.date.toLocal().toString().split('.').first}"
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(index),
          ),
        );
      },
      shrinkWrap: true,         // Lägg till denna rad!
      physics: const NeverScrollableScrollPhysics(), // Hindra dubbelskroll
    );
  }
}
