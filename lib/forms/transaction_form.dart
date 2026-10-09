import 'package:flutter/material.dart';
import '../models/office.dart';

class TransactionForm extends StatefulWidget {
  final List<Office> offices;
  final Function({
    required String receiver,
    required String country,
    required String city,
    required String currency,
    required double amount,
    required double fee,
  }) onSubmit;

  const TransactionForm({
    super.key,
    required this.offices,
    required this.onSubmit,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _amountController = TextEditingController();

  Office? _selectedOffice;
  String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    if (widget.offices.isNotEmpty) {
      _selectedOffice = widget.offices.first;
      _selectedCurrency = widget.offices.first.currencies.first;
    }
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate() ||
        _selectedOffice == null ||
        _selectedCurrency == null) {
      return;
    }

    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    widget.onSubmit(
      receiver: _receiverController.text.trim(),
      country: _selectedOffice!.country,
      city: _selectedOffice!.city,
      currency: _selectedCurrency!,
      amount: amount,
      fee: 0, // fee beräknas senare i Manager/Admin
    );

    _receiverController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final offices = widget.offices;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _receiverController,
            decoration: const InputDecoration(labelText: 'Mottagare'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ange mottagare' : null,
          ),
          const SizedBox(height: 8),

          // KONTOR
          DropdownButtonFormField<Office>(
            value: offices.contains(_selectedOffice) ? _selectedOffice : null,
            decoration: const InputDecoration(labelText: 'Kontor'),
            items: offices
                .map(
                  (o) => DropdownMenuItem<Office>(
                    value: o,
                    child: Text('${o.country} – ${o.city}'),
                  ),
                )
                .toList(),
            onChanged: (o) {
              setState(() {
                _selectedOffice = o;
                _selectedCurrency =
                    (o?.currencies.isNotEmpty ?? false) ? o!.currencies.first : null;
              });
            },
          ),
          const SizedBox(height: 8),

          // VALUTA
          DropdownButtonFormField<String>(
            value: (_selectedOffice?.currencies ?? [])
                    .contains(_selectedCurrency)
                ? _selectedCurrency
                : null,
            decoration: const InputDecoration(labelText: 'Valuta'),
            items: (_selectedOffice?.currencies ?? [])
                .map(
                  (c) => DropdownMenuItem<String>(
                    value: c,
                    child: Text(c),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedCurrency = v),
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Belopp'),
            validator: (v) {
              final value =
                  double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0;
              if (value <= 0) return 'Belopp måste vara > 0';
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Skapa transaktion'),
          ),
        ],
      ),
    );
  }
}
