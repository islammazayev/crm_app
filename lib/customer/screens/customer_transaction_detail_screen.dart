import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../services/receipt_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/receipt_button.dart';
import '../../utils/transaction_no.dart';
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

          return LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight - 32),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (formatTransactionNo(
                        data['transactionNo'],
                      ).isNotEmpty) ...[
                        Text(
                          l10n.transactionNoValue(
                            formatTransactionNo(data['transactionNo']),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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
                        l10n.youReceive(
                          amountToNet.toStringAsFixed(2),
                          toCurrency,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.orderStatusLine(customerStatusText(l10n, status)),
                      ),
                      if (paymentLabel.isNotEmpty &&
                          const [
                            'customer_accepted',
                            'customer_paid',
                            'payment_confirmed',
                            'completed',
                          ].contains(status)) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status == 'customer_accepted'
                                      ? l10n.payAmountTo(
                                          amountFrom,
                                          fromCurrency,
                                        )
                                      : l10n.paymentTo(paymentLabel),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (status == 'customer_accepted') ...[
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

                      // Managern har meddelat att betalningen inte har kommit.
                      if (status == 'customer_accepted' &&
                          '${data['paymentIssueNote'] ?? ''}'.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _NoticeCard(
                          color: AppColors.warning,
                          icon: Icons.report_outlined,
                          title: l10n.paymentMissingTitle,
                          body: '${data['paymentIssueNote']}',
                        ),
                      ],

                      if (status == 'customer_paid') ...[
                        const SizedBox(height: 12),
                        _NoticeCard(
                          color: AppColors.info,
                          icon: Icons.hourglass_top,
                          title: l10n.markedAsPaid,
                          body: [
                            l10n.managerCheckingPayment,
                            if ('${data['paymentNote'] ?? ''}'.isNotEmpty)
                              '"${data['paymentNote']}"',
                          ].join('\n'),
                          action: '${data['receiptPath'] ?? ''}'.isEmpty
                              ? null
                              : ReceiptButton(
                                  path: '${data['receiptPath']}',
                                  label: l10n.showReceipt,
                                ),
                        ),
                      ],

                      if (status == 'payment_confirmed') ...[
                        const SizedBox(height: 16),
                        _PickupCodeCard(
                          code: '${data['pickupCode'] ?? ''}',
                          amount: _num(data['amountToNet']).toStringAsFixed(2),
                          currency: toCurrency,
                        ),
                      ],

                      if (status == 'completed') ...[
                        const SizedBox(height: 12),
                        _NoticeCard(
                          color: AppColors.success,
                          icon: Icons.task_alt,
                          title: l10n.paidOutTitle,
                          body: l10n.paidOutBody,
                        ),
                      ],

                      const Spacer(),

                      if (status == 'customer_accepted' &&
                          paymentLabel.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(l10n.iHavePaid),
                            onPressed: () =>
                                _showMarkPaidDialog(context, docRef: docRef),
                          ),
                        ),

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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if ('${data['counterMessage'] ?? ''}'
                                    .isNotEmpty) ...[
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
                ),
              ),
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

/// Ruta med ikon, rubrik och text, t.ex. "Betalning saknas".
class _NoticeCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  const _NoticeCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(body),
                ?action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Uthämtningskoden, stort och tydligt, efter att betalningen bekräftats.
class _PickupCodeCard extends StatelessWidget {
  final String code;
  final String amount;
  final String currency;

  const _PickupCodeCard({
    required this.code,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDim,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            l10n.paymentConfirmedTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.yourPickupCode,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          SelectableText(
            code,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.pickupCodeInstructions(amount, currency),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Kunden markerar betalningen som gjord, med valfritt kvitto och meddelande.
Future<void> _showMarkPaidDialog(
  BuildContext context, {
  required DocumentReference docRef,
}) async {
  final l10n = context.l10n;
  final noteCtrl = TextEditingController();
  PickedReceipt? receipt;
  String? error;
  bool sending = false;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: Text(l10n.iHavePaid),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.markPaidIntro),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: Text(
                  receipt == null ? l10n.attachReceipt : l10n.changeReceipt,
                ),
                onPressed: sending
                    ? null
                    : () async {
                        final picked = await ReceiptService.pick();
                        if (picked == null) return;
                        setLocal(() {
                          if (picked.bytes.length > ReceiptService.maxBytes) {
                            error = l10n.receiptTooLarge;
                          } else {
                            receipt = picked;
                            error = null;
                          }
                        });
                      },
              ),
              if (receipt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    receipt!.name,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLength: 500,
                maxLines: 3,
                enabled: !sending,
                decoration: InputDecoration(labelText: l10n.messageOptional),
              ),
              if (error != null)
                Text(error!, style: const TextStyle(color: AppColors.error)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: sending ? null : () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: sending
                ? null
                : () async {
                    setLocal(() {
                      sending = true;
                      error = null;
                    });
                    try {
                      final update = <String, dynamic>{
                        'status': 'customer_paid',
                        'customerPaidAt': FieldValue.serverTimestamp(),
                        'paymentNote': noteCtrl.text.trim(),
                      };
                      final r = receipt;
                      if (r != null) {
                        update['receiptPath'] = await ReceiptService.upload(
                          docRef.id,
                          r,
                        );
                        update['receiptName'] = r.name;
                        update['receiptContentType'] = r.contentType;
                      }
                      await docRef.update(update);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.markedAsPaidSent)),
                        );
                      }
                    } catch (e) {
                      setLocal(() {
                        sending = false;
                        error = l10n.errorWithDetails('$e');
                      });
                    }
                  },
            child: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.confirmPaid),
          ),
        ],
      ),
    ),
  );
  noteCtrl.dispose();
}
