import 'package:flutter/material.dart';
import '../l10n/locale_controller.dart';
import '../models/office.dart';
import '../utils/currencies.dart';

class OfficeForm extends StatefulWidget {
  final Future<void> Function({
    required String country,
    required String city,
    required List<String> currencies,
    required List<OfficePaymentMethod> paymentMethods,
  }) onSubmit;

  const OfficeForm({
    super.key,
    required this.onSubmit,
  });

  @override
  State<OfficeForm> createState() => _OfficeFormState();
}

class _OfficeFormState extends State<OfficeForm> {
  final _formKey = GlobalKey<FormState>();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final Set<String> _selectedCurrencies = {};

  // Betalningsmetoder som byggs upp dynamiskt
  final List<_PaymentMethodEntry> _methods = [];

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    for (final m in _methods) {
      m.dispose();
    }
    super.dispose();
  }

  void _addMethod() {
    setState(() => _methods.add(_PaymentMethodEntry()));
  }

  void _removeMethod(int index) {
    setState(() {
      _methods[index].dispose();
      _methods.removeAt(index);
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final List<String> currencies = kSupportedCurrencies
        .where(_selectedCurrencies.contains)
        .toList();

    if (currencies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chooseAtLeastOneCurrency)),
      );
      return;
    }

    // Bygg betalningsmetoder
    final List<OfficePaymentMethod> paymentMethods = [];
    for (int i = 0; i < _methods.length; i++) {
      final m = _methods[i];
      final label = m.labelController.text.trim();
      final details = m.detailsController.text.trim();
      final supported = kSupportedCurrencies
          .where(m.supportedCurrencies.contains)
          .toList();

      if (label.isEmpty) continue; // hoppa över tomma rader

      paymentMethods.add(OfficePaymentMethod(
        id: 'method_${DateTime.now().millisecondsSinceEpoch}_$i',
        label: label,
        details: details,
        supportedFromCurrencies: supported,
      ));
    }

    await widget.onSubmit(
      country: _countryController.text.trim(),
      city: _cityController.text.trim(),
      currencies: currencies,
      paymentMethods: paymentMethods,
    );

    // Rensa formuläret
    _countryController.clear();
    _cityController.clear();
    setState(() {
      _selectedCurrencies.clear();
      for (final m in _methods) {
        m.dispose();
      }
      _methods.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Kontor-info ---
          TextFormField(
            controller: _countryController,
            decoration: InputDecoration(labelText: l10n.country),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.enterCountry : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(labelText: l10n.city),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.enterCity : null,
          ),
          const SizedBox(height: 8),
          Text(l10n.currencies,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: kSupportedCurrencies.map((c) {
              return FilterChip(
                label: Text(c),
                selected: _selectedCurrencies.contains(c),
                onSelected: (v) => setState(() {
                  v ? _selectedCurrencies.add(c) : _selectedCurrencies.remove(c);
                }),
              );
            }).toList(),
          ),

          // --- Betalningsmetoder ---
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                l10n.paymentMethods,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: _addMethod,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.add),
              ),
            ],
          ),

          if (_methods.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.noPaymentMethodsYet,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),

          for (int i = 0; i < _methods.length; i++)
            _PaymentMethodRow(
              index: i,
              entry: _methods[i],
              onRemove: () => _removeMethod(i),
            ),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: Text(l10n.createOffice),
          ),
        ],
      ),
    );
  }
}

// --- Data-klass för en metodrad ---
class _PaymentMethodEntry {
  final TextEditingController labelController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final Set<String> supportedCurrencies = {};

  void dispose() {
    labelController.dispose();
    detailsController.dispose();
  }
}

// --- Widget för en metodrad ---
class _PaymentMethodRow extends StatelessWidget {
  final int index;
  final _PaymentMethodEntry entry;
  final VoidCallback onRemove;

  const _PaymentMethodRow({
    required this.index,
    required this.entry,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.methodNumber(index + 1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: l10n.removeMethod,
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: entry.labelController,
              decoration: InputDecoration(
                labelText: l10n.methodName,
                hintText: l10n.methodNameHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: entry.detailsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.methodDetails,
                hintText: l10n.methodDetailsHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.supportsCurrencies,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            StatefulBuilder(
              builder: (context, setLocal) => Wrap(
                spacing: 8,
                children: kSupportedCurrencies.map((c) {
                  return FilterChip(
                    label: Text(c),
                    selected: entry.supportedCurrencies.contains(c),
                    onSelected: (v) => setLocal(() {
                      v
                          ? entry.supportedCurrencies.add(c)
                          : entry.supportedCurrencies.remove(c);
                    }),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
