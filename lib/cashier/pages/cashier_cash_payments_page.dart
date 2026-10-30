import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/pickup_code.dart';
import '../../utils/transaction_no.dart';

/// Kontanta inbetalningar på kassörens kontor: kunder som har accepterat
/// och ska betala kontant. Kassören bekräftar när pengarna är lämnade, och
/// kunden får då sin uthämtningskod (som när managern bekräftar).
class CashierCashPaymentsPage extends StatelessWidget {
  final String officeId;

  const CashierCashPaymentsPage({super.key, required this.officeId});

  /// Kontanta inbetalningar som väntar på kontoret.
  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> waiting(
    String officeId,
  ) => FirebaseFirestore.instance
      .collection('transactions')
      .where('officeId', isEqualTo: officeId)
      .snapshots()
      .map(
        (s) => s.docs
            .where(
              (d) =>
                  d.data()['payMethod'] == 'cash' &&
                  d.data()['status'] == 'customer_accepted' &&
                  d.data()['archived'] != true,
            )
            .toList(),
      );

  Future<void> _confirm(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final l10n = context.l10n;
    final d = doc.data();
    final amount =
        '${((d['amountFrom'] ?? 0) as num).toStringAsFixed(2)} ${d['fromCurrency'] ?? ''}';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cashPaymentReceived),
        content: Text(
          l10n.confirmCashReceived(amount, '${d['customerName'] ?? ''}'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await doc.reference.update({
        'status': 'payment_confirmed',
        'pickupCode': newPickupCode(),
        'pickupToken': newPickupToken(),
        'paymentConfirmedAt': FieldValue.serverTimestamp(),
        'paymentConfirmedBy': FirebaseAuth.instance.currentUser?.uid,
      });
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.paymentConfirmedSent)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.errorWithDetails('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cashPaymentsTitle)),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: waiting(officeId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text(l10n.errorWithDetails('${snap.error}')));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!;
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.noCashPaymentsWaiting,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final doc in docs)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            formatTransactionNo(doc.data()['transactionNo']),
                            '${doc.data()['customerName'] ?? ''}',
                          ].where((t) => t.isNotEmpty).join('  ·  '),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.customerPaysCashAmount(
                            ((doc.data()['amountFrom'] ?? 0) as num)
                                .toStringAsFixed(2),
                            '${doc.data()['fromCurrency'] ?? ''}',
                          ),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            icon: const Icon(Icons.payments_outlined),
                            label: Text(l10n.cashPaymentReceived),
                            onPressed: () => _confirm(context, doc),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
