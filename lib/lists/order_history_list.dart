import 'package:flutter/material.dart';
import '../l10n/locale_controller.dart';
import '../l10n/status_text.dart';
import '../models/transaction_model.dart';

class OrderHistoryList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final void Function(int index) onDelete;
  final void Function(int index)? onEdit;
  final void Function(int index)? onRestore;
  const OrderHistoryList({
    super.key,
    required this.transactions,
    required this.onDelete,
    this.onEdit,
    this.onRestore,
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
          title: Row(
            children: [
              Flexible(child: Text(title)),
              if (t.archived) ...[
                const SizedBox(width: 8),
                Chip(
                  label: Text(l10n.archivedBadge),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
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
              if (t.archived && onRestore != null)
                IconButton(
                  tooltip: l10n.restoreAction,
                  icon: const Icon(Icons.unarchive_outlined),
                  onPressed: () => onRestore!(index),
                )
              else
                IconButton(
                  // Genomförda arkiveras, övriga raderas (se admin).
                  tooltip: t.isCompleted && t.status.isNotEmpty
                      ? l10n.archiveAction
                      : l10n.deleteAction,
                  icon: Icon(
                    t.isCompleted && t.status.isNotEmpty
                        ? Icons.archive_outlined
                        : Icons.delete,
                    color: Colors.red,
                  ),
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
