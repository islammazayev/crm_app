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
            return Center(
              child: Text(l10n.errorWithDetails('${snapshot.error}')),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final double amountFrom = (data['amountFrom'] ?? 0 as num).toDouble();
          final String fromCurrency = (data['fromCurrency'] ?? '').toString();
          final String toCurrency = (data['toCurrency'] ?? '').toString();

          final double rateFromTo = (data['rateFromTo'] ?? 0 as num).toDouble();
          final double feePercent = (data['feePercent'] ?? 0 as num).toDouble();
          final double feeAmountFrom = (data['feeAmountFrom'] ?? 0 as num)
              .toDouble();
          final double amountToGross = (data['amountToGross'] ?? 0 as num)
              .toDouble();
          final double amountToNet = (data['amountToNet'] ?? 0 as num)
              .toDouble();
          final double feeAmountTo = (data['feeAmountTo'] ?? 0 as num)
              .toDouble();

          final String status = (data['status'] ?? '').toString();
          final String paymentLabel = (data['paymentMethodLabel'] ?? '')
              .toString();
          final String paymentDetails = (data['paymentMethodDetails'] ?? '')
              .toString();

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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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

                // Svar på managerns förslag: acceptera, avböj eller (en gång)
                // motförslag med lägre avgift.
                if (status == 'manager_proposed') ...[
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
                  ),
                  const SizedBox(height: 12),
                  if (data['counterOfferUsed'] == true)
                    Text(
                      l10n.counterOfferAlreadyUsed,
                      style: const TextStyle(color: Colors.grey),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.handshake_outlined),
                        label: Text(l10n.counterOffer),
                        onPressed: () => _showCounterOfferDialog(
                          context,
                          docRef: docRef,
                          amountFrom: amountFrom,
                          fromCurrency: fromCurrency,
                          toCurrency: toCurrency,
                          rate: rateFromTo,
                          currentFee: feePercent,
                        ),
                      ),
                    ),
                ] else if (status == 'customer_countered')
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.yourCounterOffer(
                              _num(
                                data['counterFeePercent'],
                              ).toStringAsFixed(2),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if ('${data['counterMessage'] ?? ''}'.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('"${data['counterMessage']}"'),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            l10n.waitingForManagerAnswer,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
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

double _num(Object? v) => v is num ? v.toDouble() : 0;

/// Kunden föreslår en lägre avgift. Visar direkt hur mycket kunden skulle
/// få ut med den nya avgiften (samma växelkurs som managerns förslag).
Future<void> _showCounterOfferDialog(
  BuildContext context, {
  required DocumentReference docRef,
  required double amountFrom,
  required String fromCurrency,
  required String toCurrency,
  required double rate,
  required double currentFee,
}) async {
  final l10n = context.l10n;
  final feeCtrl = TextEditingController();
  final msgCtrl = TextEditingController();
  String? error;

  final sent = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) {
        final fee = double.tryParse(feeCtrl.text.replaceAll(',', '.'));
        final net = fee == null
            ? null
            : (amountFrom - amountFrom * fee / 100) * rate;
        return AlertDialog(
          title: Text(l10n.counterOffer),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.counterOfferIntro(currentFee.toStringAsFixed(2))),
                const SizedBox(height: 12),
                TextField(
                  controller: feeCtrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.counterFeeLabel,
                    errorText: error,
                  ),
                  onChanged: (_) => setLocal(() => error = null),
                ),
                if (net != null && fee! >= 0 && fee < currentFee) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.youWouldReceive(net.toStringAsFixed(2), toCurrency),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: msgCtrl,
                  maxLength: 500,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.messageOptional),
                ),
                Text(
                  l10n.counterOfferOnce,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (fee == null || fee < 0 || fee >= currentFee) {
                  setLocal(
                    () => error = l10n.counterFeeMustBeLower(
                      currentFee.toStringAsFixed(2),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: Text(l10n.sendCounterOffer),
            ),
          ],
        );
      },
    ),
  );

  if (sent == true) {
    final fee = double.parse(feeCtrl.text.replaceAll(',', '.'));
    try {
      await docRef.update({
        'status': 'customer_countered',
        'counterOfferUsed': true,
        'counterFeePercent': fee,
        'counterMessage': msgCtrl.text.trim(),
        'customerDecisionAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.counterOfferSent)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithDetails('$e'))));
      }
    }
  }
  feeCtrl.dispose();
  msgCtrl.dispose();
}
