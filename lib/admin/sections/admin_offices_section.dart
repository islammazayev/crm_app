import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ─── Hjälpklass för betalningsmetod-formulär ─────────────────────────────────
class PaymentMethodFormItem {
  final TextEditingController idController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  Set<String> supportedCurrencies = {};

  void dispose() {
    idController.dispose();
    labelController.dispose();
    detailsController.dispose();
  }
}

// ─── Redigerings-dialog ───────────────────────────────────────────────────────
class EditOfficeDialog extends StatefulWidget {
  final String officeId;
  final Map<String, dynamic> data;
  final List<String> availableCurrencies;

  const EditOfficeDialog({
    super.key,
    required this.officeId,
    required this.data,
    required this.availableCurrencies,
  });

  @override
  State<EditOfficeDialog> createState() => _EditOfficeDialogState();
}

class _EditOfficeDialogState extends State<EditOfficeDialog> {
  late final TextEditingController _countryCtrl;
  late final TextEditingController _cityCtrl;
  late Set<String> _selectedCurrencies;
  late List<PaymentMethodFormItem> _methods;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _countryCtrl = TextEditingController(
      text: (widget.data['country'] ?? '').toString(),
    );
    _cityCtrl = TextEditingController(
      text: (widget.data['city'] ?? '').toString(),
    );
    _selectedCurrencies = Set<String>.from(
      (widget.data['currencies'] as List? ?? []).map((e) => e.toString()),
    );
    final rawMethods = widget.data['paymentMethods'] as List? ?? [];
    _methods = rawMethods.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      final item = PaymentMethodFormItem();
      item.idController.text = (m['id'] ?? '').toString();
      item.labelController.text = (m['label'] ?? '').toString();
      item.detailsController.text = (m['details'] ?? '').toString();
      item.supportedCurrencies = Set<String>.from(
        (m['supportedFromCurrencies'] as List? ?? [])
            .map((e) => e.toString()),
      );
      return item;
    }).toList();
  }

  @override
  void dispose() {
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    for (final m in _methods) {
      m.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final paymentMethods = _methods
          .map((m) => {
                'id': m.idController.text.trim(),
                'label': m.labelController.text.trim(),
                'details': m.detailsController.text.trim(),
                'supportedFromCurrencies': m.supportedCurrencies.toList(),
              })
          .toList();

      await FirebaseFirestore.instance
          .collection('offices')
          .doc(widget.officeId)
          .update({
        'country': _countryCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'currencies': _selectedCurrencies.toList(),
        'paymentMethods': paymentMethods,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kontor uppdaterat!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fel: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Redigera kontor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _countryCtrl,
              decoration: const InputDecoration(
                labelText: 'Land',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cityCtrl,
              decoration: const InputDecoration(
                labelText: 'Stad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Valutor', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.availableCurrencies.map((c) {
                final sel = _selectedCurrencies.contains(c);
                return FilterChip(
                  label: Text(c),
                  selected: sel,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedCurrencies.add(c);
                    } else {
                      _selectedCurrencies.remove(c);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Betalningsmetoder',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _methods.add(PaymentMethodFormItem())),
                  icon: const Icon(Icons.add),
                  label: const Text('Lägg till'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ..._methods.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Metod ${i + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () =>
                                setState(() => _methods.removeAt(i)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: m.idController,
                        decoration: const InputDecoration(
                          labelText: 'ID (t.ex. usdt-trc20)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: m.labelController,
                        decoration: const InputDecoration(
                          labelText: 'Namn',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: m.detailsController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Detaljer (IBAN, wallet etc.)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Stöds för valuta (fromCurrency)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.availableCurrencies.map((c) {
                          final sel = m.supportedCurrencies.contains(c);
                          return FilterChip(
                            label: Text(c),
                            selected: sel,
                            onSelected: (v) => setState(() {
                              if (v) {
                                m.supportedCurrencies.add(c);
                              } else {
                                m.supportedCurrencies.remove(c);
                              }
                            }),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Spara ändringar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Huvudsektion ─────────────────────────────────────────────────────────────
class AdminOfficesSection extends StatefulWidget {
  const AdminOfficesSection({super.key});

  @override
  State<AdminOfficesSection> createState() => _AdminOfficesSectionState();
}

class _AdminOfficesSectionState extends State<AdminOfficesSection> {
  final _formKey = GlobalKey<FormState>();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  final List<String> _availableCurrencies = [
    'EUR', 'USD', 'SEK', 'RUB', 'USDT', 'GBP', 'AED', 'TRY',
  ];
  Set<String> _selectedCurrencies = {};
  final Map<String, TextEditingController> _balanceControllers = {};
  String? _selectedManagerDocId;
  final List<PaymentMethodFormItem> _paymentMethods = [];
  bool _saving = false;

  // Sök
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    _searchController.dispose();
    for (final c in _balanceControllers.values) {
      c.dispose();
    }
    for (final m in _paymentMethods) {
      m.dispose();
    }
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _addPaymentMethod() {
    setState(() => _paymentMethods.add(PaymentMethodFormItem()));
  }

  void _removePaymentMethod(int i) {
    setState(() {
      _paymentMethods[i].dispose();
      _paymentMethods.removeAt(i);
    });
  }

  Future<void> _saveOffice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCurrencies.isEmpty) {
      _snack('Välj minst en valuta');
      return;
    }
    setState(() => _saving = true);
    try {
      final balances = <String, double>{};
      for (final c in _selectedCurrencies) {
        final txt = _balanceControllers[c]
                ?.text
                .replaceAll(',', '.') ??
            '0';
        balances[c] = double.tryParse(txt) ?? 0.0;
      }

      final paymentMethods = _paymentMethods
          .map((m) => {
                'id': m.idController.text.trim(),
                'label': m.labelController.text.trim(),
                'details': m.detailsController.text.trim(),
                'supportedFromCurrencies': m.supportedCurrencies.toList(),
              })
          .toList();

      final officeRef =
          await FirebaseFirestore.instance.collection('offices').add({
        'country': _countryController.text.trim(),
        'city': _cityController.text.trim(),
        'currencies': _selectedCurrencies.toList(),
        'balances': balances,
        'paymentMethods': paymentMethods,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (_selectedManagerDocId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_selectedManagerDocId)
            .update({'officeId': officeRef.id});
      }

      _formKey.currentState!.reset();
      _countryController.clear();
      _cityController.clear();
      setState(() {
        _selectedCurrencies = {};
        _balanceControllers.clear();
        _selectedManagerDocId = null;
        _paymentMethods.clear();
      });

      if (!mounted) return;
      _snack('Kontor skapat!');
    } catch (e) {
      if (!mounted) return;
      _snack('Fel: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteOffice(String officeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Radera kontor?'),
        content: const Text('Kontoret tas bort permanent. Är du säker?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Radera', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('officeId', isEqualTo: officeId)
          .get();
      for (final doc in usersSnap.docs) {
        await doc.reference.update({'officeId': FieldValue.delete()});
      }
      await FirebaseFirestore.instance
          .collection('offices')
          .doc(officeId)
          .delete();
      if (!mounted) return;
      _snack('Kontor raderat');
    } catch (e) {
      if (!mounted) return;
      _snack('Fel vid radering: $e');
    }
  }

  Widget _buildMethodCard(int i, PaymentMethodFormItem m) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Metod ${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removePaymentMethod(i),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: m.idController,
              decoration: const InputDecoration(
                labelText: 'ID (t.ex. usdt-trc20)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: m.labelController,
              decoration: const InputDecoration(
                labelText: 'Namn',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: m.detailsController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Detaljer (IBAN, wallet etc.)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Stöds för valuta (fromCurrency)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableCurrencies.map((c) {
                final sel = m.supportedCurrencies.contains(c);
                return FilterChip(
                  label: Text(c),
                  selected: sel,
                  onSelected: (v) => setState(() {
                    if (v) {
                      m.supportedCurrencies.add(c);
                    } else {
                      m.supportedCurrencies.remove(c);
                    }
                  }),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Skapa kontor ──────────────────────────────────────────────────
          const Text(
            'Skapa kontor',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Land',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ange land' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Stad',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ange stad' : null,
                ),
                const SizedBox(height: 12),
                const Text('Valutor',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableCurrencies.map((c) {
                    final sel = _selectedCurrencies.contains(c);
                    return FilterChip(
                      label: Text(c),
                      selected: sel,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _selectedCurrencies.add(c);
                          _balanceControllers[c] ??=
                              TextEditingController();
                        } else {
                          _selectedCurrencies.remove(c);
                          _balanceControllers[c]?.dispose();
                          _balanceControllers.remove(c);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                ..._selectedCurrencies.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller: _balanceControllers[c],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Startsaldo $c',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    )),
                const SizedBox(height: 4),
                const Text('Tilldela manager',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'manager')
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final docs = snap.data!.docs;
                    if (docs.isEmpty) {
                      return const Text(
                        'Inga managers registrerade ännu.',
                        style: TextStyle(color: Colors.grey),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedManagerDocId,
                      decoration: const InputDecoration(
                        labelText: 'Manager',
                        border: OutlineInputBorder(),
                      ),
                      items: docs.map((doc) {
                        final d =
                            doc.data() as Map<String, dynamic>;
                        final name =
                            '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'
                                .trim();
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(
                              name.isEmpty ? doc.id : name),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setState(() => _selectedManagerDocId = v),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Betalningsmetoder',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addPaymentMethod,
                      icon: const Icon(Icons.add),
                      label: const Text('Lägg till'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_paymentMethods.isEmpty)
                  const Text(
                    'Inga betalningsmetoder tillagda ännu.',
                    style:
                        TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ..._paymentMethods
                    .asMap()
                    .entries
                    .map((e) => _buildMethodCard(e.key, e.value)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveOffice,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Skapa kontor'),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 48),

          // ── Sök & hantera kontor ──────────────────────────────────────────
          const Text(
            'Sök & hantera kontor',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Sök på land eller stad...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('offices')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Fel: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allDocs = snapshot.data!.docs;
              final docs = _searchQuery.isEmpty
                  ? allDocs
                  : allDocs.where((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      final country =
                          (d['country'] ?? '').toString().toLowerCase();
                      final city =
                          (d['city'] ?? '').toString().toLowerCase();
                      return country.contains(_searchQuery) ||
                          city.contains(_searchQuery);
                    }).toList();

              if (docs.isEmpty) {
                return const Text(
                  'Inga kontor hittades.',
                  style: TextStyle(color: Colors.grey),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final officeId = doc.id;
                  final data = doc.data() as Map<String, dynamic>;
                  final country = (data['country'] ?? '').toString();
                  final city = (data['city'] ?? '').toString();
                  final currencies =
                      (data['currencies'] as List? ?? []).join(', ');
                  final methodCount =
                      (data['paymentMethods'] as List? ?? []).length;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(
                        '$country - $city',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          'Valutor: $currencies\n$methodCount betalningsmetod(er)'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.blue),
                            tooltip: 'Redigera',
                            onPressed: () => showDialog(
                              context: context,
                              builder: (ctx) => EditOfficeDialog(
                                officeId: officeId,
                                 data: data,
                                availableCurrencies: _availableCurrencies,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            tooltip: 'Radera',
                            onPressed: () => _deleteOffice(officeId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
