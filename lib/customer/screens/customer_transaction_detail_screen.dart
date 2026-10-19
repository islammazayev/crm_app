import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import 'customer_transactions_screen.dart' show customerStatusText;

class CustomerTransactionDetailScreen extends StatelessWidget {
  final String transactionId;

  const CustomerTransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection('transactions')
        .doc(transactionId);

    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transaction)),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.errorWithDetails('${snapshot.error}')));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final double amountFrom =
              (data['amountFrom'] ?? 0 as num).toDouble();
          final String fromCurrency =
              (data['fromCurrency'] ?? '').toString();
          final String toCurrency =
              (data['toCurrency'] ?? '').toString();

          final double rateFromTo =
              (data['rateFromTo'] ?? 0 as num).toDouble();
          final double feePercent =
              (data['feePercent'] ?? 0 as num).toDouble();
          final double feeAmountFrom =
              (data['feeAmountFrom'] ?? 0 as num).toDouble();
          final double amountToGross =
              (data['amountToGross'] ?? 0 as num).toDouble();
          final double amountToNet =
              (data['amountToNet'] ?? 0 as num).toDouble();
          final double feeAmountTo =
              (data['feeAmountTo'] ?? 0 as num).toDouble();

          final String status = (data['status'] ?? '').toString();
          final String paymentLabel =
              (data['paymentMethodLabel'] ?? '').toString();
          final String paymentDetails =
              (data['paymentMethodDetails'] ?? '').toString();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.youSend(amountFrom, fromCurrency)),
                const SizedBox(height: 8),
                Text(
                  l10n.exchangeRateValue(
                    fromCurrency,
                    rateFromTo.toStringAsFixed(6),
                    toCurrency,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.grossReceived(
                    amountToGross.toStringAsFixed(2),
                    toCurrency,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.feeValue(
                    feePercent.toStringAsFixed(2),
                    feeAmountFrom.toStringAsFixed(2),
                    fromCurrency,
                    feeAmountTo.toStringAsFixed(2),
                    toCurrency,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.youReceive(amountToNet.toStringAsFixed(2), toCurrency),
                ),
                const SizedBox(height: 8),
                Text(l10n.orderStatusLine(customerStatusText(l10n, status))),
                if (paymentLabel.isNotEmpty &&
                    (status == 'customer_accepted' ||
                        status == 'completed')) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status == 'completed'
                                ? l10n.paymentTo(paymentLabel)
                                : l10n.payAmountTo(amountFrom, fromCurrency),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (status != 'completed') ...[
                            const SizedBox(height: 4),
                            Text(paymentLabel),
                          ],
                          const SizedBox(height: 8),
                          SelectableText(paymentDetails),
                        ],
                      ),
                    ),
                  ),
                ] else if (status == 'customer_accepted') ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.acceptedWaitingPayment,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
                const Spacer(),

                // Knappar bara när manager har föreslagit villkor
                if (status == 'manager_proposed')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            await docRef.update({
                              'status': 'customer_accepted',
                              'customerDecisionAt':
                                  FieldValue.serverTimestamp(),
                            });
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Text(l10n.accept),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            await docRef.update({
                              'status': 'customer_rejected',
                              'customerDecisionAt':
                                  FieldValue.serverTimestamp(),
                            });
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Text(l10n.reject),
                        ),
                      ),
                    ],
                  )
                else if (status == 'customer_requested')
                  Text(
                    l10n.waitingForProposal,
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
