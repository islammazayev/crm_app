import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SendSection extends StatefulWidget {
  const SendSection({super.key});

  @override
  State<SendSection> createState() => _SendSectionState();
}

class _SendSectionState extends State<SendSection> {
  String? _selectedOfficeId;
  String? _selectedFromCurrency;
  String? _selectedToCurrency;
  final _amountCtrl = TextEditingController();

  bool _loadingOffices = true;
  String? _error;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _offices = [];

  @override
  void initState() {
    super.initState();
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('offices')
          .get();

      setState(() {
        _offices = snap.docs;
        _loadingOffices = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Kunde inte ladda kontor: $e';
        _loadingOffices = false;
      });
    }
  }

  List<String> get _currenciesForSelectedOffice {
    if (_selectedOfficeId == null) return [];
    final office =
        _offices.firstWhere((o) => o.id == _selectedOfficeId);
    final data = office.data();
    final list = data['currencies'];
    if (list is List) {
      return list.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingOffices) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Välj kontor
          DropdownButtonFormField<String>(
            value: _selectedOfficeId,
            decoration: const InputDecoration(labelText: 'Välj kontor'),
            items: _offices.map((doc) {
              final data = doc.data();
              final name = data['officeName']?.toString() ??
                  data['city']?.toString() ??
                  'Office';
              return DropdownMenuItem(
                value: doc.id,
                child: Text(name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedOfficeId = value;
                _selectedFromCurrency = null;
                _selectedToCurrency = null;
              });
            },
          ),

          const SizedBox(height: 16),

          // 2. Från‑valuta
          DropdownButtonFormField<String>(
            value: _selectedFromCurrency,
            decoration:
                const InputDecoration(labelText: 'Valuta du skickar från'),
            items: _currenciesForSelectedOffice.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedFromCurrency = value);
            },
          ),

          const SizedBox(height: 16),

          // 3. Belopp
          TextFormField(
            controller: _amountCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Belopp att skicka'),
          ),

          const SizedBox(height: 16),

          // 4. Till‑valuta
          DropdownButtonFormField<String>(
            value: _selectedToCurrency,
            decoration: const InputDecoration(
                labelText: 'Valuta mottagaren tar emot'),
            items: _currenciesForSelectedOffice.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedToCurrency = value);
            },
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () async {
              if (_selectedOfficeId == null ||
                  _selectedFromCurrency == null ||
                  _selectedToCurrency == null ||
                  _amountCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fyll i alla fält')),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser!;
                final amountFrom = double.parse(
                    _amountCtrl.text.replaceAll(',', '.'));

                // HÄMTA clientId för den inloggade kunden
                final customerSnap = await FirebaseFirestore.instance
                    .collection('customers')
                    .doc(user.uid)
                    .get();

                final clientId =
                    customerSnap.data()?['clientId']?.toString() ?? '';

                await FirebaseFirestore.instance
                    .collection('transactions')
                    .add({
                  'customerId': user.uid,
                  'clientId': clientId,           // <-- viktigt för manager
                  'officeId': _selectedOfficeId,
                  'fromCurrency': _selectedFromCurrency,
                  'toCurrency': _selectedToCurrency,
                  'amountFrom': amountFrom,
                  'amountTo': null,
                  'feePercent': null,
                  'feeAmount': null,
                  'paymentMethod': null,
                  'status': 'customer_requested',
                  'createAt': FieldValue.serverTimestamp(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Begäran skickad till kontoret')),
                );

                _amountCtrl.clear();
                setState(() {
                  _selectedOfficeId = null;
                  _selectedFromCurrency = null;
                  _selectedToCurrency = null;
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Fel vid skapande av transaktion: $e')),
                );
              }
            },
            child: const Text('Skicka'),
          ),
        ],
      ),
    );
  }
}
