import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/locale_controller.dart';
import '../../services/transaction_number_service.dart';
import '../../utils/customer_tiers.dart';
import '../../widgets/pay_method.dart';
import '../../widgets/pickup_countries_field.dart';
import 'office_listing.dart';

/// Skicka-flödet: kunden väljer först vilken valuta hen vill skicka. Därefter
/// visas bara de kontor som hanterar den valutan, och sist väljer kunden
/// vilken valuta mottagaren ska få (bland kontorets valutor, samma valuta
/// går också) och i vilket land mottagaren hämtar pengarna.
class SendSection extends StatefulWidget {
  const SendSection({super.key});

  @override
  State<SendSection> createState() => _SendSectionState();
}

class _SendSectionState extends State<SendSection> {
  String? _selectedFromCurrency;
  String? _selectedOfficeId;
  String? _selectedToCurrency;
  String? _pickupCountry;
  PayMethod _payMethod = PayMethod.bank;
  final _amountCtrl = TextEditingController();

  bool _loadingOffices = true;
  bool _sending = false;
  String Function(AppLocalizations l10n)? _error;
  List<OfficeListing> _offices = [];

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
        _offices = snap.docs.map(OfficeListing.fromDoc).toList();
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
  List<OfficeListing> get _officesForFromCurrency {
    final from = _selectedFromCurrency;
    if (from == null) return [];
    return _offices.where((o) => o.currencies.contains(from)).toList();
  }

  OfficeListing? get _selectedOffice {
    final id = _selectedOfficeId;
    if (id == null) return null;
    for (final o in _offices) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Valutor mottagaren kan få: kontorets valutor (även den som skickas).
  List<String> get _toCurrencies => _selectedOffice?.currencies ?? const [];

  /// Länder där mottagaren kan hämta pengarna (från kontoret).
  List<String> get _pickupCountries =>
      _selectedOffice?.pickupCountries ?? const [];

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
        (_pickupCountries.isNotEmpty && _pickupCountry == null) ||
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
      // Kundens nivå och avgiftstak följer med så att managern ser dem.
      final tier = (await TierSettings.load()).forCustomer(customer);

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
        if (_pickupCountry != null) 'pickupCountry': _pickupCountry,
        'amountFrom': amount,
        'amountTo': null,
        'feePercent': null,
        'feeAmount': null,
        'paymentMethod': null,
        'payMethod': _payMethod.name,
        'status': 'customer_requested',
        'createAt': FieldValue.serverTimestamp(),
        ...?tier?.toTransactionFields(),
      });

      if (!mounted) return;
      _snack(l10n.requestSentToOffice);

      _amountCtrl.clear();
      setState(() {
        _selectedFromCurrency = null;
        _selectedOfficeId = null;
        _selectedToCurrency = null;
        _pickupCountry = null;
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
                _pickupCountry = null;
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
                      _pickupCountry = null;
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

          // 4. Land där mottagaren hämtar pengarna (om kontoret lagt in länder)
          if (_pickupCountries.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              key: ValueKey('pickup-$_selectedOfficeId-$_pickupCountry'),
              initialValue: _pickupCountry,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.pickupCountryRecipient,
              ),
              items: _pickupCountries
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(countryLabel(c)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _pickupCountry = value),
            ),
            const SizedBox(height: 16),
          ],

          // Kontant på kontoret eller via bank.
          PayMethodPicker(
            value: _payMethod,
            onChanged: (v) => setState(() => _payMethod = v),
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
