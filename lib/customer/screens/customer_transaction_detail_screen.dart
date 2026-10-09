import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
                Text('Status: $status'),
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
                else
                  const Text(
                    'Förslaget är redan hanterat.',
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
