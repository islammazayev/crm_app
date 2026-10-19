import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Transaktion')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Fel: ${snapshot.error}'));
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
                Text('Du skickar: $amountFrom $fromCurrency'),
                const SizedBox(height: 8),
                Text(
                  'Växelkurs: 1 $fromCurrency = ${rateFromTo.toStringAsFixed(6)} $toCurrency',
                ),
                const SizedBox(height: 8),
                Text(
                  'Brutto mottaget: ${amountToGross.toStringAsFixed(2)} $toCurrency',
                ),
                const SizedBox(height: 8),
                Text(
                  'Avgift: ${feePercent.toStringAsFixed(2)}% '
                  '(${feeAmountFrom.toStringAsFixed(2)} $fromCurrency '
                  '≈ ${feeAmountTo.toStringAsFixed(2)} $toCurrency)',
                ),
                const SizedBox(height: 8),
                Text(
                  'Du får ut: ${amountToNet.toStringAsFixed(2)} $toCurrency',
                ),
                const SizedBox(height: 8),
                Text('Status: ${customerStatusText(status)}'),
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
                                ? 'Betalning till: $paymentLabel'
                                : 'Betala $amountFrom $fromCurrency till:',
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
                  const Text(
                    'Du har accepterat. Managern skickar betalningsuppgifter inom kort.',
                    style: TextStyle(color: Colors.grey),
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
                          child: const Text('Acceptera'),
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
                          child: const Text('Avböj'),
                        ),
                      ),
                    ],
                  )
                else if (status == 'customer_requested')
                  const Text(
                    'Väntar på att managern ska skicka ett förslag.',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
