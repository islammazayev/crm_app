import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../l10n/locale_controller.dart';
import '../../l10n/rate_error_text.dart';
import '../../l10n/status_text.dart';
import '../../utils/pickup_code.dart';
import '../../widgets/receipt_button.dart';
import '../../services/exchange_rate_service.dart';
import '../../utils/transaction_no.dart';
import '../../utils/balances.dart';

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
  bool _autoCalcStarted = false;
  bool _counterPrefilled = false;
  final _payoutCodeController = TextEditingController();

  String? _selectedMethodId;
  Map<String, Map<String, dynamic>> _methodCache = {};
  bool _busy = false;

  @override
  void dispose() {
    _feeController.dispose();
    _payoutCodeController.dispose();
    super.dispose();
  }

  Future<void> _recalculate({
    required double amountFrom,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final feePercent = double.tryParse(
      _feeController.text.replaceAll(',', '.'),
    );
    if (feePercent == null) return;

    setState(() => _calculating = true);
    try {
      final rate =
          _rate ?? await ExchangeRateService.getRate(fromCurrency, toCurrency);

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
        SnackBar(
          content: Text(
            context.l10n.calculationError(rateErrorText(context.l10n, e)),
          ),
        ),
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
          final supported = (method['supportedFromCurrencies'] as List? ?? [])
              .map((e) => e.toString().toUpperCase())
              .toList();

          return supported.contains(fromCurrency.toUpperCase());
        })
        .toList();
  }

  /// Accepterar kundens motförslag: kundens avgift och samma växelkurs som
  /// i förslaget. Transaktionen blir accepterad direkt (kunden har redan
  /// sagt ja till den avgiften).
  Future<void> _acceptCounter({
    required DocumentReference txRef,
    required double amountFrom,
    required double rate,
    required double counterFee,
  }) async {
    setState(() => _busy = true);
    try {
      final feeAmountFrom = amountFrom * counterFee / 100;
      final amountToGross = amountFrom * rate;
      final amountToNet = (amountFrom - feeAmountFrom) * rate;
      await txRef.update({
        'status': 'customer_accepted',
        'feePercent': counterFee,
        'feeAmountFrom': feeAmountFrom,
        'rateFromTo': rate,
        'amountToGross': amountToGross,
        'amountToNet': amountToNet,
        'feeAmountTo': amountToGross - amountToNet,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.counterOfferAccepted)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorWithDetails('$e'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Bekräftar att kundens betalning har kommit och skapar uthämtningskoden,
  /// som kunden ser direkt i appen.
  Future<void> _confirmPayment(DocumentReference txRef) async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await txRef.update({
        'status': 'payment_confirmed',
        'pickupCode': newPickupCode(),
        'paymentConfirmedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.paymentConfirmedSent)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorWithDetails('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Betalningen har inte kommit: skickar tillbaka till kunden med ett
  /// meddelande. Kunden kan markera som betalt igen.
  Future<void> _reportPaymentMissing(DocumentReference txRef) async {
    final l10n = context.l10n;
    final noteCtrl = TextEditingController(text: l10n.paymentMissingDefault);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.paymentMissing),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(labelText: l10n.messageToCustomer),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.send),
          ),
        ],
      ),
    );
    final note = noteCtrl.text.trim();
    noteCtrl.dispose();
    if (ok != true) return;
    try {
      await txRef.update({
        'status': 'customer_accepted',
        'paymentIssueNote': note,
        'paymentIssueAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorWithDetails('$e'))));
    }
  }

  /// Sparar vald betalningsmetod i transaktionen så att kunden ser uppgifterna.
  Future<void> _sendPaymentDetails(DocumentReference txRef) async {
    final method = _methodCache[_selectedMethodId];
    if (method == null) return;
    setState(() => _busy = true);
    try {
      await txRef.update({
        'chosenPaymentMethodId': _selectedMethodId,
        'paymentMethodLabel': (method['label'] ?? '').toString(),
        'paymentMethodDetails': (method['details'] ?? '').toString(),
        'paymentSentAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.paymentDetailsSent)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorWithDetails('$e'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Markerar som genomförd och bokför saldot i kontoret i en gemensam batch:
  /// kontoret får in skickad valuta och betalar ut kundens nettobelopp.
  Future<void> _complete({
    required DocumentReference txRef,
    required String officeId,
    required String fromCurrency,
    required String toCurrency,
    required double amountFrom,
    required double amountToNet,
    required String pickupCode,
  }) async {
    final l10n = context.l10n;
    final entered = _payoutCodeController.text;
    if (!pickupCodeMatches(entered, pickupCode)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.wrongPickupCode)));
      return;
    }
    setState(() => _busy = true);
    try {
      final db = FirebaseFirestore.instance;
      final officeRef = db.collection('offices').doc(officeId);
      final officeSnap = await officeRef.get();
      final balances = parseBalances(
        officeSnap.data()?['balances'],
        officeId: officeId,
      );
      final available = balances[toCurrency] ?? 0;
      if (available < amountToNet) {
        throw Exception(
          l10n.insufficientBalance(
            toCurrency,
            available.toStringAsFixed(2),
            amountToNet.toStringAsFixed(2),
          ),
        );
      }

      final batch = db.batch();
      batch.update(txRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        // Måste vara exakt kundens kod (kontrolleras i reglerna).
        'payoutCode': pickupCode,
      });
      batch.update(officeRef, {
        'balances.$fromCurrency': FieldValue.increment(amountFrom),
        'balances.$toCurrency': FieldValue.increment(-amountToNet),
        'lastBookedTransactionId': txRef.id,
      });
      await batch.commit();

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.errorWithDetails(e.toString().replaceFirst('Exception: ', '')),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final txRef = FirebaseFirestore.instance
        .collection('transactions')
        .doc(widget.transactionId);

    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionManager)),
      body: StreamBuilder<DocumentSnapshot>(
        stream: txRef.snapshots(),
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

          final double amountFrom = ((data['amountFrom'] ?? 0) as num)
              .toDouble();
          final String fromCurrency = (data['fromCurrency'] ?? '').toString();
          final String toCurrency = (data['toCurrency'] ?? '').toString();
          final String status = (data['status'] ?? '').toString();
          final String officeId = (data['officeId'] ?? '').toString();
          final String? chosenPaymentMethodId =
              data['chosenPaymentMethodId'] as String?;

          final String paymentLabel = (data['paymentMethodLabel'] ?? '')
              .toString();
          final bool paymentSent = paymentLabel.isNotEmpty;

          if (_selectedMethodId == null && chosenPaymentMethodId != null) {
            _selectedMethodId = chosenPaymentMethodId;
          }

          final double savedRateFromTo = ((data['rateFromTo'] ?? 0) as num)
              .toDouble();
          final double savedFeePercent = ((data['feePercent'] ?? 0) as num)
              .toDouble();
          final double savedFeeAmountFrom =
              ((data['feeAmountFrom'] ?? 0) as num).toDouble();
          final double savedAmountToGross =
              ((data['amountToGross'] ?? 0) as num).toDouble();
          final double savedAmountToNet = ((data['amountToNet'] ?? 0) as num)
              .toDouble();
          final double savedFeeAmountTo = ((data['feeAmountTo'] ?? 0) as num)
              .toDouble();

          final feePercentInput = double.tryParse(
            _feeController.text.replaceAll(',', '.'),
          );

          // Kundens motförslag: fyll i kundens avgift och använd samma
          // växelkurs som i förslaget, så att managern ser vad det innebär.
          final countered = status == 'customer_countered';
          final double counterFee = ((data['counterFeePercent'] ?? 0) as num)
              .toDouble();
          if (countered && !_counterPrefilled) {
            _counterPrefilled = true;
            _autoCalcStarted = true;
            _feeController.text = counterFee.toString();
            if (savedRateFromTo > 0) _rate = savedRateFromTo;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _recalculate(
                amountFrom: amountFrom,
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
              );
            });
          }

          // Räkna direkt med standardavgiften när sidan öppnas, så att knappen
          // "Föreslå villkor" inte är avstängd tills managern ändrar avgiften.
          if (!_autoCalcStarted &&
              _rate == null &&
              (status == 'customer_requested' ||
                  status == 'manager_proposed')) {
            _autoCalcStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _recalculate(
                amountFrom: amountFrom,
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
              );
            });
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (formatTransactionNo(data['transactionNo']).isNotEmpty) ...[
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
                Text(l10n.customerSends(amountFrom, fromCurrency)),
                const SizedBox(height: 8),
                Text(l10n.toCurrencyValue(toCurrency)),
                const SizedBox(height: 8),
                Text(l10n.orderStatusLine(statusText(l10n, status))),
                const SizedBox(height: 16),

                if (countered)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.customerCounterOffer(
                              savedFeePercent.toStringAsFixed(2),
                              counterFee.toStringAsFixed(2),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if ('${data['counterMessage'] ?? ''}'.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('"${data['counterMessage']}"'),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            l10n.counterOfferManagerHint,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (countered) const SizedBox(height: 12),

                if (status == 'customer_requested' ||
                    status == 'manager_proposed' ||
                    countered) ...[
                  TextField(
                    controller: _feeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.feePercentLabel,
                      border: const OutlineInputBorder(),
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
                      l10n.exchangeRateValue(
                        fromCurrency,
                        _rate!.toStringAsFixed(6),
                        toCurrency,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_amountToGross != null)
                      Text(
                        l10n.grossReceived(
                          _amountToGross!.toStringAsFixed(2),
                          toCurrency,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (_feeAmountFrom != null && _feeAmountTo != null)
                      Text(
                        l10n.feeValue(
                          feePercentInput.toStringAsFixed(2),
                          _feeAmountFrom!.toStringAsFixed(2),
                          fromCurrency,
                          _feeAmountTo!.toStringAsFixed(2),
                          toCurrency,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (_amountToNet != null)
                      Text(
                        l10n.customerReceives(
                          _amountToNet!.toStringAsFixed(2),
                          toCurrency,
                        ),
                      ),
                  ] else if (_calculating)
                    Text(l10n.calculating),
                ],

                if (const [
                  'customer_accepted',
                  'customer_paid',
                  'payment_confirmed',
                  'completed',
                ].contains(status)) ...[
                  Text(
                    l10n.exchangeRateValue(
                      fromCurrency,
                      savedRateFromTo.toStringAsFixed(6),
                      toCurrency,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.grossReceived(
                      savedAmountToGross.toStringAsFixed(2),
                      toCurrency,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.feeValue(
                      savedFeePercent.toStringAsFixed(2),
                      savedFeeAmountFrom.toStringAsFixed(2),
                      fromCurrency,
                      savedFeeAmountTo.toStringAsFixed(2),
                      toCurrency,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.customerReceives(
                      savedAmountToNet.toStringAsFixed(2),
                      toCurrency,
                    ),
                  ),
                ],

                if (paymentSent &&
                    const [
                      'customer_paid',
                      'payment_confirmed',
                      'completed',
                    ].contains(status)) ...[
                  const SizedBox(height: 8),
                  Text(l10n.paymentMethodValue(paymentLabel)),
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
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(l10n.officeNotFound),
                        );
                      }

                      final office = snap.data!.data() as Map<String, dynamic>;
                      final List rawMethods =
                          office['paymentMethods'] as List? ?? [];

                      final methods = _filterPaymentMethods(
                        rawMethods: rawMethods,
                        fromCurrency: fromCurrency,
                      );

                      _methodCache = {
                        for (final m in methods) (m['id'] ?? '').toString(): m,
                      };

                      if (methods.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(l10n.noPaymentMethodsForCurrency),
                        );
                      }

                      return Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(top: 16),
                          children: [
                            Text(
                              l10n.choosePaymentMethodForCustomer,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RadioGroup<String>(
                              groupValue: _selectedMethodId,
                              onChanged: (value) {
                                setState(() {
                                  _selectedMethodId = value;
                                });
                              },
                              child: Column(
                                children: methods.map((method) {
                                  final id = (method['id'] ?? '').toString();
                                  final label = (method['label'] ?? '')
                                      .toString();
                                  final details = (method['details'] ?? '')
                                      .toString();

                                  return Card(
                                    child: RadioListTile<String>(
                                      value: id,
                                      title: Text(label),
                                      subtitle: Text(details, softWrap: true),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                if (status != 'customer_accepted') const Spacer(),

                if (countered) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _busy || savedRateFromTo <= 0
                          ? null
                          : () => _acceptCounter(
                              txRef: txRef,
                              amountFrom: amountFrom,
                              rate: savedRateFromTo,
                              counterFee: counterFee,
                            ),
                      child: Text(
                        l10n.acceptCounterOffer(counterFee.toStringAsFixed(2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                if (status == 'customer_requested' ||
                    status == 'manager_proposed' ||
                    countered)
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
                      child: Text(
                        countered ? l10n.sendNewProposal : l10n.proposeTerms,
                      ),
                    ),
                  ),

                if (status == 'customer_paid') ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.customerMarkedPaid,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if ('${data['paymentNote'] ?? ''}'.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('"${data['paymentNote']}"'),
                          ],
                          const SizedBox(height: 4),
                          if ('${data['receiptPath'] ?? ''}'.isNotEmpty)
                            ReceiptButton(
                              path: '${data['receiptPath']}',
                              label: l10n.showReceiptNamed(
                                '${data['receiptName'] ?? ''}',
                              ),
                            )
                          else
                            Text(
                              l10n.noReceiptAttached,
                              style: const TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _busy ? null : () => _confirmPayment(txRef),
                      child: Text(l10n.confirmPayment),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _reportPaymentMissing(txRef),
                      child: Text(l10n.paymentMissing),
                    ),
                  ),
                ],

                if (status == 'payment_confirmed') ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.paymentConfirmedManager,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.payoutInstructions(
                              savedAmountToNet.toStringAsFixed(2),
                              toCurrency,
                            ),
                          ),
                          if (data['createdByManager'] == true) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n.giveCodeToWalkIn(
                                '${data['pickupCode'] ?? ''}',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _payoutCodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.customerPickupCode,
                      hintText: '1234-5678',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _busy
                          ? null
                          : () => _complete(
                              txRef: txRef,
                              officeId: officeId,
                              fromCurrency: fromCurrency,
                              toCurrency: toCurrency,
                              amountFrom: amountFrom,
                              amountToNet: savedAmountToNet,
                              pickupCode: '${data['pickupCode'] ?? ''}',
                            ),
                      child: Text(l10n.payOutAndComplete),
                    ),
                  ),
                ],

                if (status == 'customer_accepted')
                  SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        if (paymentSent)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              l10n.sentToCustomer(paymentLabel),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed:
                                (_busy ||
                                    _selectedMethodId == null ||
                                    !_methodCache.containsKey(
                                      _selectedMethodId,
                                    ))
                                ? null
                                : () => _sendPaymentDetails(txRef),
                            child: Text(
                              paymentSent
                                  ? l10n.resendPaymentDetails
                                  : l10n.sendPaymentDetailsToCustomer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            // För kunder utan konto (eller om kunden inte
                            // hunnit markera) kan managern bekräfta direkt.
                            onPressed: (_busy || !paymentSent)
                                ? null
                                : () => _confirmPayment(txRef),
                            child: Text(l10n.confirmPayment),
                          ),
                        ),
                      ],
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
