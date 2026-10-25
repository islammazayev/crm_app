import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/locale_controller.dart';
import '../../services/transaction_number_service.dart';

/// Ett kontor så som kunden får se det (från `officeListings`):
/// bara land, stad och vilka valutor kontoret hanterar.
class _OfficeListing {
  final String id;
  final String country;
  final String city;
  final List<String> currencies;

  _OfficeListing({
    required this.id,
    required this.country,
    required this.city,
    required this.currencies,
  });

  factory _OfficeListing.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return _OfficeListing(
      id: doc.id,
      country: (data['country'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      currencies: (data['currencies'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  String label(AppLocalizations l10n) {
    if (city.isEmpty) return country.isEmpty ? l10n.office : country;
    return country.isEmpty ? city : '$city – $country';
  }
}

/// Skicka-flödet: kunden väljer först vilken valuta hen vill skicka. Därefter
/// visas bara de kontor som hanterar den valutan, och sist väljer kunden
/// vilken valuta mottagaren ska få (bland kontorets valutor).
class SendSection extends StatefulWidget {
  const SendSection({super.key});

  @override
  State<SendSection> createState() => _SendSectionState();
}

class _SendSectionState extends State<SendSection> {
  String? _selectedFromCurrency;
  String? _selectedOfficeId;
  String? _selectedToCurrency;
  final _amountCtrl = TextEditingController();

  bool _loadingOffices = true;
  bool _sending = false;
  String Function(AppLocalizations l10n)? _error;
  List<_OfficeListing> _offices = [];

  @override
  void initState() {
    super.initState();
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('officeListings')
          .get();

      if (!mounted) return;
      setState(() {
        _offices = snap.docs.map(_OfficeListing.fromDoc).toList();
        _loadingOffices = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = (l10n) => l10n.couldNotLoadOffices('$e');
        _loadingOffices = false;
      });
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  /// Alla valutor som minst ett kontor hanterar.
  List<String> get _allCurrencies {
    final set = <String>{};
    for (final o in _offices) {
      set.addAll(o.currencies);
    }
    final list = set.toList()..sort();
    return list;
  }

  /// Kontor som hanterar valutan kunden vill skicka.
  List<_OfficeListing> get _officesForFromCurrency {
    final from = _selectedFromCurrency;
    if (from == null) return [];
    return _offices.where((o) => o.currencies.contains(from)).toList();
  }

  _OfficeListing? get _selectedOffice {
    final id = _selectedOfficeId;
    if (id == null) return null;
    for (final o in _offices) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Valutor mottagaren kan få: kontorets valutor utom den som skickas.
  List<String> get _toCurrencies {
    final office = _selectedOffice;
    final from = _selectedFromCurrency;
    if (office == null) return [];
    return office.currencies.where((c) => c != from).toList();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final from = _selectedFromCurrency;
    final officeId = _selectedOfficeId;
    final to = _selectedToCurrency;
    final amount = double.tryParse(
      _amountCtrl.text.trim().replaceAll(',', '.'),
    );

    if (from == null ||
        officeId == null ||
        to == null ||
        amount == null ||
        amount <= 0) {
      _snack(l10n.fillAllFieldsValidAmount);
      return;
    }

    setState(() => _sending = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;

      // Kundens profil (klient-ID, namn, telefon). Hämtas med userId så att
      // det fungerar oavsett vilket dokument-ID kundposten har.
      final customerSnap = await FirebaseFirestore.instance
          .collection('customers')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (customerSnap.docs.isEmpty) {
        throw Exception(l10n.noCustomerProfile);
      }

      final customer = customerSnap.docs.first.data();
      final customerName =
          '${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}'.trim();

      await TransactionNumberService.create({
        'customerId': user.uid,
        'clientId': (customer['clientId'] ?? '').toString(),
        // Kopieras in så att kontorets manager ser vem kunden är utan att
        // behöva läsa kundregistret.
        'customerName': customerName,
        'customerPhone': (customer['phone'] ?? '').toString(),
        'officeId': officeId,
        'fromCurrency': from,
        'toCurrency': to,
        'amountFrom': amount,
        'amountTo': null,
        'feePercent': null,
        'feeAmount': null,
        'paymentMethod': null,
        'status': 'customer_requested',
        'createAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _snack(l10n.requestSentToOffice);

      _amountCtrl.clear();
      setState(() {
        _selectedFromCurrency = null;
        _selectedOfficeId = null;
        _selectedToCurrency = null;
      });
    } catch (e) {
      if (!mounted) return;
      _snack(l10n.couldNotCreateTransaction('$e'));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_loadingOffices) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!(l10n)));
    }

    if (_offices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.noOfficesAvailable),
        ),
      );
    }

    final officeChoices = _officesForFromCurrency;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Valutan du skickar
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedFromCurrency),
            initialValue: _selectedFromCurrency,
            decoration: InputDecoration(labelText: l10n.currencyYouSend),
            items: _allCurrencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFromCurrency = value;
                _selectedOfficeId = null;
                _selectedToCurrency = null;
              });
            },
          ),

          const SizedBox(height: 16),

          // 2. Kontor som hanterar den valutan
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedOfficeId),
            initialValue: _selectedOfficeId,
            decoration: InputDecoration(
              labelText: _selectedFromCurrency == null
                  ? l10n.chooseOfficeFirstCurrency
                  : l10n.officesHandlingCurrency(_selectedFromCurrency!),
            ),
            items: officeChoices
                .map(
                  (o) =>
                      DropdownMenuItem(value: o.id, child: Text(o.label(l10n))),
                )
                .toList(),
            onChanged: _selectedFromCurrency == null
                ? null
                : (value) {
                    setState(() {
                      _selectedOfficeId = value;
                      _selectedToCurrency = null;
                    });
                  },
          ),

          const SizedBox(height: 16),

          // 3. Valutan mottagaren får
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedToCurrency),
            initialValue: _selectedToCurrency,
            decoration: InputDecoration(labelText: l10n.currencyRecipientGets),
            items: _toCurrencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: _selectedOfficeId == null
                ? null
                : (value) => setState(() => _selectedToCurrency = value),
          ),

          const SizedBox(height: 16),

          // 4. Belopp
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.amountToSend),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _sending ? null : _send,
            child: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.send),
          ),
        ],
      ),
    );
  }
}
