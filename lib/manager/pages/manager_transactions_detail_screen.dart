import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/exchange_rate_service.dart';

class ManagerTransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const ManagerTransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<ManagerTransactionDetailScreen> createState() =>
      _ManagerTransactionDetailScreenState();
}

class _ManagerTransactionDetailScreenState
    extends State<ManagerTransactionDetailScreen> {
  final _feeController = TextEditingController(text: '5');

  double? _rate;
  double? _amountToGross;
  double? _amountToNet;
  double? _feeAmountFrom;
  double? _feeAmountTo;
  bool _calculating = false;

  String? _selectedMethodId;

  @override
  void dispose() {
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _recalculate({
    required double amountFrom,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final feePercent =
        double.tryParse(_feeController.text.replaceAll(',', '.'));
    if (feePercent == null) return;

    setState(() => _calculating = true);
    try {
      final rate = _rate ??
          await ExchangeRateService.getRate(fromCurrency, toCurrency);

      final feeAmountFrom = amountFrom * feePercent / 100;
      final amountFromNet = amountFrom - feeAmountFrom;

      final amountToGross = amountFrom * rate;
      final amountToNet = amountFromNet * rate;
      final feeAmountTo = amountToGross - amountToNet;

      setState(() {
        _rate = rate;
        _feeAmountFrom = feeAmountFrom;
        _amountToGross = amountToGross;
        _amountToNet = amountToNet;
        _feeAmountTo = feeAmountTo;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fel vid beräkning: $e')),
      );
    } finally {
      if (mounted) setState(() => _calculating = false);
    }
  }

  List<Map<String, dynamic>> _filterPaymentMethods({
    required List rawMethods,
    required String fromCurrency,
  }) {
    return rawMethods
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((method) {
          final supported =
              (method['supportedFromCurrencies'] as List? ?? [])
                  .map((e) => e.toString().toUpperCase())
                  .toList();

          return supported.contains(fromCurrency.toUpperCase());
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final txRef = FirebaseFirestore.instance
        .collection('transactions')
        .doc(widget.transactionId);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaktion (manager)')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: txRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Fel: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final double amountFrom =
              ((data['amountFrom'] ?? 0) as num).toDouble();
          final String fromCurrency =
              (data['fromCurrency'] ?? '').toString();
          final String toCurrency =
              (data['toCurrency'] ?? '').toString();
          final String status =
              (data['status'] ?? '').toString();
          final String officeId =
              (data['officeId'] ?? '').toString();
          final String? chosenPaymentMethodId =
              data['chosenPaymentMethodId'] as String?;

          if (_selectedMethodId == null && chosenPaymentMethodId != null) {
            _selectedMethodId = chosenPaymentMethodId;
          }

          final double savedRateFromTo =
              ((data['rateFromTo'] ?? 0) as num).toDouble();
          final double savedFeePercent =
              ((data['feePercent'] ?? 0) as num).toDouble();
          final double savedFeeAmountFrom =
              ((data['feeAmountFrom'] ?? 0) as num).toDouble();
          final double savedAmountToGross =
              ((data['amountToGross'] ?? 0) as num).toDouble();
          final double savedAmountToNet =
              ((data['amountToNet'] ?? 0) as num).toDouble();
          final double savedFeeAmountTo =
              ((data['feeAmountTo'] ?? 0) as num).toDouble();

          final feePercentInput =
              double.tryParse(_feeController.text.replaceAll(',', '.'));

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kund skickar: $amountFrom $fromCurrency'),
                const SizedBox(height: 8),
                Text('Till valuta: $toCurrency'),
                const SizedBox(height: 8),
                Text('Status: $status'),
                const SizedBox(height: 16),

                if (status == 'customer_requested' ||
                    status == 'manager_proposed') ...[
                  TextField(
                    controller: _feeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Avgift (%)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      _recalculate(
                        amountFrom: amountFrom,
                        fromCurrency: fromCurrency,
                        toCurrency: toCurrency,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_rate != null && feePercentInput != null) ...[
                    Text(
                      'Växelkurs: 1 $fromCurrency = ${_rate!.toStringAsFixed(6)} $toCurrency',
                    ),
                    const SizedBox(height: 8),
                    if (_amountToGross != null)
                      Text(
                        'Brutto mottaget: ${_amountToGross!.toStringAsFixed(2)} $toCurrency',
                      ),
                    const SizedBox(height: 8),
                    if (_feeAmountFrom != null && _feeAmountTo != null)
                      Text(
                        'Avgift: ${feePercentInput.toStringAsFixed(2)}% (${_feeAmountFrom!.toStringAsFixed(2)} $fromCurrency ≈ ${_feeAmountTo!.toStringAsFixed(2)} $toCurrency)',
                      ),
                    const SizedBox(height: 8),
                    if (_amountToNet != null)
                      Text(
                        'Kunden får ut: ${_amountToNet!.toStringAsFixed(2)} $toCurrency',
                      ),
                  ] else if (_calculating)
                    const Text('Beräknar...'),
                ],

                if (status == 'customer_accepted' ||
                    status == 'completed') ...[
                  Text(
                    'Växelkurs: 1 $fromCurrency = ${savedRateFromTo.toStringAsFixed(6)} $toCurrency',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Brutto mottaget: ${savedAmountToGross.toStringAsFixed(2)} $toCurrency',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Avgift: ${savedFeePercent.toStringAsFixed(2)}% (${savedFeeAmountFrom.toStringAsFixed(2)} $fromCurrency ≈ ${savedFeeAmountTo.toStringAsFixed(2)} $toCurrency)',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kunden får ut: ${savedAmountToNet.toStringAsFixed(2)} $toCurrency',
                  ),
                ],

                if (status == 'customer_accepted' && officeId.isNotEmpty)
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('offices')
                        .doc(officeId)
                        .get(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snap.hasData || !snap.data!.exists) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('Office hittades inte.'),
                        );
                      }

                      final office =
                          snap.data!.data() as Map<String, dynamic>;
                      final List rawMethods =
                          office['paymentMethods'] as List? ?? [];

                      final methods = _filterPaymentMethods(
                        rawMethods: rawMethods,
                        fromCurrency: fromCurrency,
                      );

                      if (methods.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'Inga betalningsmetoder för den här valutan.',
                          ),
                        );
                      }

                      return Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(top: 16),
                          children: [
                            const Text(
                              'Välj betalningsmetod att skicka till kund:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...methods.map((method) {
                              final id = (method['id'] ?? '').toString();
                              final label =
                                  (method['label'] ?? '').toString();
                              final details =
                                  (method['details'] ?? '').toString();

                              return Card(
                                child: RadioListTile<String>(
                                  value: id,
                                  groupValue: _selectedMethodId,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMethodId = value;
                                    });
                                  },
                                  title: Text(label),
                                  subtitle: Text(
                                    details,
                                    softWrap: true,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),

                if (status != 'customer_accepted') const Spacer(),

                if (status == 'customer_requested' ||
                    status == 'manager_proposed')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_rate == null || feePercentInput == null)
                          ? null
                          : () async {
                              await txRef.update({
                                'status': 'manager_proposed',
                                'feePercent': feePercentInput,
                                'feeAmountFrom': _feeAmountFrom,
                                'rateFromTo': _rate,
                                'amountToGross': _amountToGross,
                                'amountToNet': _amountToNet,
                                'feeAmountTo': _feeAmountTo,
                                'managerProposedAt':
                                    FieldValue.serverTimestamp(),
                              });

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                      child: const Text('Föreslå villkor'),
                    ),
                  ),

                if (status == 'customer_accepted')
                  SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: _selectedMethodId == null
                            ? null
                            : () async {
                                await txRef.update({
                                  'chosenPaymentMethodId': _selectedMethodId,
                                  'status': 'completed',
                                  'completedAt':
                                      FieldValue.serverTimestamp(),
                                });

                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                        child: const Text('Markera som genomförd'),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
