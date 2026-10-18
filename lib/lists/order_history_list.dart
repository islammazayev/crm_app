import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

String _statusText(String status) {
  switch (status) {
    case 'customer_requested':
      return 'Ny förfrågan';
    case 'manager_proposed':
      return 'Förslag skickat';
    case 'customer_accepted':
      return 'Accepterad av kund';
    case 'customer_rejected':
      return 'Avböjd av kund';
    case 'completed':
      return 'Genomförd';
    default:
      return status;
  }
}

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
        final title = t.label.isNotEmpty
            ? t.label
            : "${t.receiver} (${t.city}, ${t.country})";
        final currency = t.toCurrency.isNotEmpty
            ? "${t.currency} → ${t.toCurrency}"
            : t.currency;
        final statusLine =
            t.status.isNotEmpty ? "Status: ${_statusText(t.status)}\n" : "";
        return ListTile(
          title: Text(title),
          subtitle: Text(
            "Valuta: $currency, Belopp: ${t.amount}, Avgift: ${t.fee}\n"
            "$statusLine"
            "Datum: ${t.date.toLocal().toString().split('.').first}"
          ),
          isThreeLine: t.status.isNotEmpty,
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
