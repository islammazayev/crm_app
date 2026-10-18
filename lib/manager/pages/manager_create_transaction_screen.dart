import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  String? _error;

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
        _error = 'Kunde inte läsa kontorets valutor: $e';
        _loading = false;
      });
    }
  }

  Future<void> _create() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    final feePercent = double.tryParse(_feeCtrl.text.replaceAll(',', '.'));
    final name = _nameCtrl.text.trim();

    if (name.isEmpty) {
      _snack('Ange kundens namn.');
      return;
    }
    if (_from == null || _to == null || _from == _to) {
      _snack('Välj två olika valutor.');
      return;
    }
    if (amount == null || amount <= 0) {
      _snack('Ange ett belopp större än 0.');
      return;
    }
    if (feePercent == null || feePercent < 0 || feePercent >= 100) {
      _snack('Ange en avgift mellan 0 och 100 %.');
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
      _snack('Fel: $e');
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skapa ny transaktion')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kundens namn',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefon (valfritt)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _from,
                      decoration: const InputDecoration(
                        labelText: 'Kunden lämnar (valuta)',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Kunden får (valuta)',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Belopp som kunden lämnar',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _feeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Avgift (%)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saving ? null : _create,
                      child: Text(_saving ? 'Skapar …' : 'Skapa transaktion'),
                    ),
                  ],
                ),
    );
  }
}
