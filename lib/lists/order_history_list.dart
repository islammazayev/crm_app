import 'package:flutter/material.dart';
import '../l10n/locale_controller.dart';
import '../l10n/status_text.dart';
import '../models/transaction_model.dart';

class OrderHistoryList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final void Function(int index) onDelete;
  final void Function(int index)? onEdit;
  const OrderHistoryList({
    super.key,
    required this.transactions,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.noOrdersYet),
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
        final statusLine = t.status.isNotEmpty
            ? "${l10n.orderStatusLine(statusText(l10n, t.status))}\n"
            : "";
        return ListTile(
          title: Text(title),
          subtitle: Text(
            "${l10n.orderDetails(currency, t.amount, t.fee)}\n"
            "$statusLine"
            "${l10n.dateValue(t.date.toLocal().toString().split('.').first)}",
          ),
          isThreeLine: t.status.isNotEmpty,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                IconButton(
                  tooltip: l10n.edit,
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => onEdit!(index),
                ),
              IconButton(
                tooltip: l10n.deleteAction,
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(index),
              ),
            ],
          ),
        );
      },
      shrinkWrap: true, // Lägg till denna rad!
      physics: const NeverScrollableScrollPhysics(), // Hindra dubbelskroll
    );
  }
}
