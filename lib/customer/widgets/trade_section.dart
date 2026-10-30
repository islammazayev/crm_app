import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/locale_controller.dart';
import '../../services/transaction_number_service.dart';
import '../../utils/customer_tiers.dart';
import '../../widgets/pay_method.dart';
import 'office_listing.dart';

/// Hur kunden vill få valutan hen köper.
enum DeliveryMethod { cash, bank }

/// Köpa eller sälja valuta.
enum TradeKind { buy, sell }

/// Köp- och säljflödet. Kunden väljer först valutan hen köper (eller
/// säljer), sedan valutan hen betalar med (eller vill få), kontant eller
/// bank, kontor och belopp.
///
/// Köp: beloppet är det kunden vill få; vad det kostar räknar managern ut.
/// Sälj: beloppet är det kunden säljer; managern räknar ut vad hen får.
class TradeSection extends StatefulWidget {
  final TradeKind kind;

  const TradeSection({super.key, required this.kind});

  @override
  State<TradeSection> createState() => _TradeSectionState();
}

class _TradeSectionState extends State<TradeSection> {
  bool get _isBuy => widget.kind == TradeKind.buy;

  /// Valutan som väljs först: den kunden köper eller säljer.
  String? _buyCurrency;

  /// Valutan som väljs sedan: den kunden betalar med eller vill få.
  String? _payCurrency;
  DeliveryMethod _delivery = DeliveryMethod.cash;
  PayMethod _payMethod = PayMethod.bank;
  String? _officeId;
  final _amountCtrl = TextEditingController();

  bool _loading = true;
  bool _sending = false;
  String Function(AppLocalizations l10n)? _error;
  List<OfficeListing> _offices = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final offices = await loadOfficeListings();
      if (!mounted) return;
      setState(() {
        _offices = offices;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = (l10n) => l10n.couldNotLoadOffices('$e');
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  List<String> get _allCurrencies {
    final set = <String>{for (final o in _offices) ...o.currencies};
    return set.toList()..sort();
  }

  /// Valutor att betala med (eller få): de som något kontor hanterar
  /// tillsammans med valutan som valdes först.
  List<String> get _payCurrencies {
    final buy = _buyCurrency;
    if (buy == null) return [];
    final set = <String>{
      for (final o in _offices)
        if (o.currencies.contains(buy)) ...o.currencies,
    }..remove(buy);
    return set.toList()..sort();
  }

  /// Kontor som hanterar båda valutorna.
  List<OfficeListing> get _officeChoices {
    final buy = _buyCurrency;
    final pay = _payCurrency;
    if (buy == null || pay == null) return [];
    return _offices
        .where((o) => o.currencies.contains(buy) && o.currencies.contains(pay))
        .toList();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final amount = double.tryParse(
      _amountCtrl.text.trim().replaceAll(',', '.'),
    );
    if (_buyCurrency == null ||
        _payCurrency == null ||
        _officeId == null ||
        amount == null ||
        amount <= 0) {
      _snack(l10n.fillAllFieldsValidAmount);
      return;
    }

    setState(() => _sending = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final customerSnap = await FirebaseFirestore.instance
          .collection('customers')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (customerSnap.docs.isEmpty) {
        throw Exception(l10n.noCustomerProfile);
      }
      final customer = customerSnap.docs.first.data();
      final tier = (await TierSettings.load()).forCustomer(customer);

      await TransactionNumberService.create({
        'customerId': user.uid,
        'clientId': (customer['clientId'] ?? '').toString(),
        'customerName':
            '${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}'
                .trim(),
        'customerPhone': (customer['phone'] ?? '').toString(),
        'officeId': _officeId,
        'kind': widget.kind.name,
        'deliveryMethod': _delivery.name,
        // Kunden betalar med fromCurrency och får toCurrency.
        if (_isBuy) ...{
          'fromCurrency': _payCurrency,
          'toCurrency': _buyCurrency,
          'buyAmount': amount,
          'amountFrom': null,
        } else ...{
          'fromCurrency': _buyCurrency,
          'toCurrency': _payCurrency,
          'amountFrom': amount,
        },
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
      _snack(_isBuy ? l10n.buyRequestSent : l10n.sellRequestSent);
      _amountCtrl.clear();
      setState(() {
        _buyCurrency = null;
        _payCurrency = null;
        _officeId = null;
        _delivery = DeliveryMethod.cash;
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

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!(l10n)));
    if (_offices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.noOfficesAvailable),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Valutan kunden vill köpa (eller sälja)
          DropdownButtonFormField<String>(
            key: ValueKey('buy-$_buyCurrency'),
            initialValue: _buyCurrency,
            decoration: InputDecoration(
              labelText: _isBuy ? l10n.currencyToBuy : l10n.currencyToSell,
            ),
            items: _allCurrencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() {
              _buyCurrency = v;
              _payCurrency = null;
              _officeId = null;
            }),
          ),
          const SizedBox(height: 16),

          // 2. Valutan kunden betalar med (eller vill få)
          DropdownButtonFormField<String>(
            key: ValueKey('pay-$_buyCurrency-$_payCurrency'),
            initialValue: _payCurrency,
            decoration: InputDecoration(
              labelText: _isBuy
                  ? l10n.currencyToPayWith
                  : l10n.currencyToReceive,
            ),
            items: _payCurrencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: _buyCurrency == null
                ? null
                : (v) => setState(() {
                    _payCurrency = v;
                    _officeId = null;
                  }),
          ),
          const SizedBox(height: 20),

          // 3. Kontant eller bank
          Text(
            l10n.howToReceive,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SegmentedButton<DeliveryMethod>(
            segments: [
              ButtonSegment(
                value: DeliveryMethod.cash,
                icon: const Icon(Icons.payments_outlined),
                label: Text(l10n.deliveryCash),
              ),
              ButtonSegment(
                value: DeliveryMethod.bank,
                icon: const Icon(Icons.account_balance_outlined),
                label: Text(l10n.deliveryBank),
              ),
            ],
            selected: {_delivery},
            onSelectionChanged: (v) => setState(() => _delivery = v.first),
          ),
          const SizedBox(height: 8),
          Text(
            _delivery == DeliveryMethod.cash
                ? l10n.deliveryCashHint
                : l10n.deliveryBankHint,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Hur kunden betalar: kontant på kontoret eller via bank.
          PayMethodPicker(
            value: _payMethod,
            onChanged: (v) => setState(() => _payMethod = v),
          ),
          const SizedBox(height: 20),

          // 4. Kontor
          DropdownButtonFormField<String>(
            key: ValueKey('office-$_buyCurrency-$_payCurrency-$_officeId'),
            initialValue: _officeId,
            decoration: InputDecoration(
              labelText: _payCurrency == null
                  ? l10n.chooseCurrenciesFirst
                  : _delivery == DeliveryMethod.cash
                  ? l10n.officeForPickup
                  : l10n.officeForBankPayout,
            ),
            items: _officeChoices
                .map(
                  (o) =>
                      DropdownMenuItem(value: o.id, child: Text(o.label(l10n))),
                )
                .toList(),
            onChanged: _payCurrency == null
                ? null
                : (v) => setState(() => _officeId = v),
          ),
          const SizedBox(height: 16),

          // 5. Hur mycket kunden vill köpa (eller sälja)
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _isBuy ? l10n.amountToBuy : l10n.amountToSell,
              suffixText: _buyCurrency,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isBuy ? l10n.sendBuyRequest : l10n.sendSellRequest),
            ),
          ),
        ],
      ),
    );
  }
}
