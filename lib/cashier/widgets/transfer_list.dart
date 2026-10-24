import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/locale_controller.dart';
import '../../services/cashier_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confirm_delete.dart';

/// Överföringens status i klartext.
String transferStatusText(AppLocalizations l10n, String status) {
  switch (status) {
    case 'pending':
      return l10n.transferPending;
    case 'accepted':
      return l10n.transferAccepted;
    case 'rejected':
      return l10n.transferRejected;
    case 'cancelled':
      return l10n.transferCancelled;
    default:
      return status;
  }
}

/// Lista med överföringar för en kassör, senaste först.
///
/// [actorId] är den inloggade kassören. Är den samma som [cashierId] visas
/// knapparna Ta emot/Neka (inkommande) och Avbryt (skickade) på väntande
/// överföringar. Admin och manager ser listan utan knappar.
class TransferList extends StatelessWidget {
  final String cashierId;
  final Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> stream;
  final String? actorId;
  final bool onlyIncomingPending;

  const TransferList({
    super.key,
    required this.cashierId,
    required this.stream,
    this.actorId,
    this.onlyIncomingPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.errorWithDetails('${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        var docs = snapshot.data!
            .where(
              (d) =>
                  d.data()['fromId'] == cashierId ||
                  d.data()['toId'] == cashierId,
            )
            .toList();
        if (onlyIncomingPending) {
          docs = docs
              .where(
                (d) =>
                    d.data()['toId'] == cashierId &&
                    d.data()['status'] == 'pending',
              )
              .toList();
        }
        DateTime? at(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            (d.data()['createdAt'] as Timestamp?)?.toDate();
        docs.sort((a, b) {
          final ta = at(a), tb = at(b);
          if (ta == null && tb == null) return 0;
          if (ta == null) return -1;
          if (tb == null) return 1;
          return tb.compareTo(ta);
        });
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              onlyIncomingPending
                  ? l10n.noIncomingTransfers
                  : l10n.noTransfersYet,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          );
        }
        return Column(
          children: [for (final d in docs) _TransferTile(doc: d, list: this)],
        );
      },
    );
  }
}

class _TransferTile extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final TransferList list;

  const _TransferTile({required this.doc, required this.list});

  @override
  State<_TransferTile> createState() => _TransferTileState();
}

class _TransferTileState extends State<_TransferTile> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorWithDetails('$e'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = widget.doc.data();
    final cid = widget.list.cashierId;
    final incoming = d['toId'] == cid;
    final status = '${d['status'] ?? ''}';
    final amount = ((d['amount'] ?? 0) as num).toStringAsFixed(2);
    final currency = '${d['currency'] ?? ''}';
    final other = incoming ? '${d['fromName'] ?? ''}' : '${d['toName'] ?? ''}';
    final created = (d['createdAt'] as Timestamp?)?.toDate();
    final note = '${d['note'] ?? ''}';
    final canAct = widget.list.actorId == cid && status == 'pending';

    final color = switch (status) {
      'accepted' => AppColors.success,
      'pending' => AppColors.warning,
      _ => AppColors.textMuted,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  incoming ? Icons.call_received : Icons.call_made,
                  color: incoming ? AppColors.success : AppColors.info,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    incoming
                        ? l10n.transferFrom(other)
                        : l10n.transferTo(other),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${incoming ? '+' : '−'}$amount $currency',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: incoming ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                transferStatusText(l10n, status),
                if (created != null)
                  created.toLocal().toString().split('.').first,
              ].join(' · '),
              style: TextStyle(color: color, fontSize: 13),
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('"$note"'),
            ],
            if (canAct) ...[
              const SizedBox(height: 8),
              if (incoming)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: _busy
                            ? null
                            : () => _run(
                                () => CashierService.accept(widget.doc),
                                l10n.transferAcceptedDone,
                              ),
                        child: Text(l10n.receivedButton),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () async {
                                final ok = await confirmDelete(
                                  context,
                                  title: l10n.rejectTransferTitle,
                                  message: l10n.rejectTransferConfirm(
                                    amount,
                                    currency,
                                    other,
                                  ),
                                );
                                if (ok) {
                                  await _run(
                                    () => CashierService.reject(widget.doc),
                                    l10n.transferRejectedDone,
                                  );
                                }
                              },
                        child: Text(l10n.reject),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            final ok = await confirmDelete(
                              context,
                              title: l10n.cancelTransferTitle,
                              message: l10n.cancelTransferConfirm(
                                amount,
                                currency,
                                other,
                              ),
                            );
                            if (ok) {
                              await _run(
                                () => CashierService.cancel(widget.doc),
                                l10n.transferCancelledDone,
                              );
                            }
                          },
                    child: Text(l10n.cancelTransfer),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Saldon per valuta, t.ex. "5 000.00 EUR".
class BalancesCard extends StatelessWidget {
  final Map<String, double> balances;

  const BalancesCard({super.key, required this.balances});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = balances.entries.where((e) => e.value != 0).toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cashBalance,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            Text(l10n.noBalanceYet)
          else
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (final e in entries)
                  Text(
                    '${e.value.toStringAsFixed(2)} ${e.key}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
