import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/locale_controller.dart';
import '../../l10n/rate_error_text.dart';
import '../../services/exchange_rate_service.dart';
import 'manager_transactions_detail_screen.dart';

/// Manager registrerar en kund som kommer in på kontoret och saknar konto.
/// Villkoren räknas ut direkt och transaktionen skapas som redan accepterad,
/// så nästa steg är att skicka betalningsuppgifter och markera som genomförd.
class ManagerCreateTransactionScreen extends StatefulWidget {
  final String officeId;
  const ManagerCreateTransactionScreen({super.key, required this.officeId});

  @override
  State<ManagerCreateTransactionScreen> createState() =>
      _ManagerCreateTransactionScreenState();
}

class _ManagerCreateTransactionScreenState
    extends State<ManagerCreateTransactionScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _feeCtrl = TextEditingController(text: '5');

  List<String> _currencies = [];
  String? _from;
  String? _to;
  bool _loading = true;
  bool _saving = false;
  String Function(AppLocalizations l10n)? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCurrencies() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('officeListings')
          .doc(widget.officeId)
          .get();
      final list = (snap.data()?['currencies'] as List? ?? [])
          .map((e) => e.toString())
          .toList();
      if (!mounted) return;
      setState(() {
        _currencies = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = (l10n) => l10n.couldNotLoadOfficeCurrencies('$e');
        _loading = false;
      });
    }
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    final feePercent = double.tryParse(_feeCtrl.text.replaceAll(',', '.'));
    final name = _nameCtrl.text.trim();

    if (name.isEmpty) {
      _snack(l10n.enterCustomerName);
      return;
    }
    if (_from == null || _to == null || _from == _to) {
      _snack(l10n.chooseTwoDifferentCurrencies);
      return;
    }
    if (amount == null || amount <= 0) {
      _snack(l10n.enterAmountAboveZero);
      return;
    }
    if (feePercent == null || feePercent < 0 || feePercent >= 100) {
      _snack(l10n.enterFeeRange);
      return;
    }

    setState(() => _saving = true);
    try {
      final rate = await ExchangeRateService.getRate(_from!, _to!);
      final feeAmountFrom = amount * feePercent / 100;
      final amountToGross = amount * rate;
      final amountToNet = (amount - feeAmountFrom) * rate;

      final ref = await FirebaseFirestore.instance.collection('transactions').add({
        'customerId': '',
        'customerName': name,
        'customerPhone': _phoneCtrl.text.trim(),
        'officeId': widget.officeId,
        'fromCurrency': _from,
        'toCurrency': _to,
        'amountFrom': amount,
        'feePercent': feePercent,
        'feeAmountFrom': feeAmountFrom,
        'rateFromTo': rate,
        'amountToGross': amountToGross,
        'amountToNet': amountToNet,
        'feeAmountTo': amountToGross - amountToNet,
        'status': 'customer_accepted',
        'createdByManager': true,
        'createAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ManagerTransactionDetailScreen(transactionId: ref.id),
        ),
      );
    } catch (e) {
      _snack(l10n.errorWithDetails(rateErrorText(l10n, e)));
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createNewTransaction)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!(l10n)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.customerName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.phoneOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _from,
                      decoration: InputDecoration(
                        labelText: l10n.customerGivesCurrency,
                        border: const OutlineInputBorder(),
                      ),
                      items: _currencies
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _from = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _to,
                      decoration: InputDecoration(
                        labelText: l10n.customerGetsCurrency,
                        border: const OutlineInputBorder(),
                      ),
                      items: _currencies
                          .where((c) => c != _from)
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _to = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.amountCustomerGives,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _feeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.feePercentLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saving ? null : _create,
                      child: Text(_saving ? l10n.creating : l10n.createTransaction),
                    ),
                  ],
                ),
    );
  }
}
