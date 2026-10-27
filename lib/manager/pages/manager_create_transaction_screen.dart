import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/locale_controller.dart';
import '../../l10n/rate_error_text.dart';
import '../../services/customer_invite_service.dart';
import '../../services/exchange_rate_service.dart';
import '../../services/transaction_number_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/customer_search.dart';
import '../../utils/fee_calc.dart';
import '../../widgets/rate_field.dart';
import 'manager_transactions_detail_screen.dart';

/// Manager registrerar en kund som kommer in på kontoret. Managern väljer en
/// befintlig kund ur kundregistret eller skriver in en ny, och kan bjuda in
/// kunden till appen (länk via SMS). Villkoren räknas ut direkt och
/// transaktionen skapas som redan accepterad, så nästa steg är att skicka
/// betalningsuppgifter och markera som genomförd.
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

  /// Marknadskursen fylls i när båda valutorna är valda; managern kan ändra.
  final _rateCtrl = TextEditingController();
  double? _marketRate;
  bool _loadingRate = false;

  List<String> _currencies = [];
  String? _from;
  String? _to;
  bool _loading = true;
  bool _saving = false;
  String Function(AppLocalizations l10n)? _error;

  /// Kundregistret (managers får läsa det) och vald kund.
  final _searchCtrl = TextEditingController();
  final _customerStream = FirebaseFirestore.instance
      .collection('customers')
      .snapshots();
  QueryDocumentSnapshot<Map<String, dynamic>>? _selected;

  /// Kunden vill bli kund hos oss: skapa/bjud in och skicka länk via SMS.
  bool _invite = false;

  bool get _selectedHasAccount => _selected?.data()['userId'] != null;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _searchCtrl.dispose();
    _amountCtrl.dispose();
    _feeCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRate() async {
    final from = _from, to = _to;
    setState(() {
      _marketRate = null;
      _rateCtrl.clear();
      _loadingRate = from != null && to != null && from != to;
    });
    if (!_loadingRate) return;
    try {
      final rate = await ExchangeRateService.getRate(from!, to!);
      if (!mounted || from != _from || to != _to) return;
      setState(() {
        _marketRate = rate;
        _rateCtrl.text = formatRate(rate);
      });
    } catch (e) {
      if (mounted) {
        _snack(context.l10n.errorWithDetails(rateErrorText(context.l10n, e)));
      }
    } finally {
      if (mounted && from == _from && to == _to) {
        setState(() => _loadingRate = false);
      }
    }
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
    final selected = _selected?.data();
    final name = selected != null
        ? '${selected['firstName'] ?? ''} ${selected['lastName'] ?? ''}'.trim()
        : _nameCtrl.text.trim();
    final phone = selected != null
        ? '${selected['phone'] ?? ''}'.trim()
        : _phoneCtrl.text.trim();
    final invite = _invite && !_selectedHasAccount;

    if (name.isEmpty) {
      _snack(l10n.enterCustomerName);
      return;
    }
    if (invite && phone.isEmpty) {
      _snack(l10n.invitePhoneRequired);
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
    final rate = parseRate(_rateCtrl.text);
    if (rate == null) {
      _snack(l10n.invalidRate);
      return;
    }

    setState(() => _saving = true);
    try {
      final a = ExchangeAmounts.fromPaid(
        amountFrom: amount,
        feePercent: feePercent,
        rate: rate,
      );

      // Kunden i kundregistret: vald, eller ny om kunden vill bli kund.
      String? customerDocId = _selected?.id;
      String? clientId = selected == null ? null : '${selected['clientId']}';
      String? inviteCode;
      if (invite && selected != null) {
        inviteCode = await CustomerInviteService.inviteExisting(
          _selected!.id,
          selected['inviteCode'] as String?,
        );
      } else if (invite) {
        final created = await CustomerInviteService.createCustomer(
          managerId: FirebaseAuth.instance.currentUser?.uid ?? '',
          name: name,
          phone: phone,
        );
        customerDocId = created.docId;
        clientId = '${created.clientId}';
        inviteCode = created.code;
      }

      final ref = await TransactionNumberService.create({
        'customerId': '',
        'customerName': name,
        'customerPhone': phone,
        if (customerDocId != null && clientId != null) ...{
          'customerDocId': customerDocId,
          'clientId': clientId,
        },
        'officeId': widget.officeId,
        'fromCurrency': _from,
        'toCurrency': _to,
        'amountFrom': amount,
        'feePercent': feePercent,
        'rateFromTo': rate,
        ...a.toMap(),
        'status': 'customer_accepted',
        'createdByManager': true,
        'createAt': FieldValue.serverTimestamp(),
      });

      // SMS-appen öppnas med kundens nummer och länken; managern trycker
      // Skicka.
      if (inviteCode != null && customerDocId != null) {
        await CustomerInviteService.openSms(
          phone,
          l10n.inviteSmsText(
            name,
            CustomerInviteService.inviteLink(customerDocId, inviteCode),
          ),
        );
      }

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
                _customerSection(l10n),
                if (!_selectedHasAccount)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _invite,
                    onChanged: (v) => setState(() => _invite = v),
                    title: Text(l10n.inviteCustomerQuestion),
                    subtitle: Text(
                      l10n.inviteCustomerHint,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _from,
                  decoration: InputDecoration(
                    labelText: l10n.customerGivesCurrency,
                    border: const OutlineInputBorder(),
                  ),
                  items: _currencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    _from = v;
                    if (_to == v) _to = null;
                    _loadRate();
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _to,
                  decoration: InputDecoration(
                    labelText: l10n.customerGetsCurrency,
                    border: const OutlineInputBorder(),
                  ),
                  items: _currencies
                      .where((c) => c != _from)
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    _to = v;
                    _loadRate();
                  },
                ),
                if (_loadingRate) ...[
                  const SizedBox(height: 14),
                  Text(l10n.calculating),
                ] else if (_from != null && _to != null) ...[
                  const SizedBox(height: 14),
                  RateField(
                    controller: _rateCtrl,
                    fromCurrency: _from!,
                    toCurrency: _to!,
                    marketRate: _marketRate,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
                const SizedBox(height: 14),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.amountCustomerGives,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _feeCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.feePercentLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                ..._resultLines(l10n),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saving ? null : _create,
                  child: Text(_saving ? l10n.creating : l10n.createTransaction),
                ),
              ],
            ),
    );
  }

  /// Vad kunden får, räknat medan managern skriver.
  List<Widget> _resultLines(AppLocalizations l10n) {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    final fee = double.tryParse(_feeCtrl.text.replaceAll(',', '.'));
    final rate = parseRate(_rateCtrl.text);
    if (amount == null ||
        amount <= 0 ||
        fee == null ||
        fee < 0 ||
        fee >= 100 ||
        rate == null ||
        _from == null ||
        _to == null) {
      return const [];
    }
    final a = ExchangeAmounts.fromPaid(
      amountFrom: amount,
      feePercent: fee,
      rate: rate,
    );
    return [
      const SizedBox(height: 14),
      Text(
        l10n.feeValue(
          fee.toStringAsFixed(2),
          a.feeAmountFrom.toStringAsFixed(2),
          _from!,
          a.feeAmountTo.toStringAsFixed(2),
          _to!,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        l10n.customerReceives(a.amountToNet.toStringAsFixed(2), _to!),
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ];
  }

  /// Sök och välj en befintlig kund, eller skriv in en ny.
  Widget _customerSection(AppLocalizations l10n) {
    final selected = _selected;
    if (selected != null) {
      final d = selected.data();
      final entry = _entry(selected);
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.person, color: AppColors.primary),
          title: Text(entry.fullName),
          subtitle: Text(
            [
              l10n.clientIdValue(entry.formattedClientId),
              if (entry.phone.isNotEmpty) l10n.phoneValue(entry.phone),
              d['userId'] != null ? l10n.hasAppAccount : l10n.noAppAccount,
            ].join('\n'),
          ),
          isThreeLine: true,
          trailing: TextButton(
            onPressed: () => setState(() {
              _selected = null;
              _invite = false;
            }),
            child: Text(l10n.changeCustomer),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.searchExistingCustomer,
            hintText: l10n.searchCustomersHint,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
        ),
        if (_searchCtrl.text.trim().isNotEmpty)
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _customerStream,
            builder: (context, snap) {
              if (snap.hasError) {
                return Text(l10n.errorWithDetails('${snap.error}'));
              }
              if (!snap.hasData) return const LinearProgressIndicator();
              final byId = {for (final d in snap.data!.docs) d.id: d};
              final results = searchCustomers(
                byId.values.map(_entry),
                _searchCtrl.text,
              ).take(5).toList();
              if (results.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.noCustomerFoundNew,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                );
              }
              return Column(
                children: [
                  for (final e in results)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(
                        e.formattedClientId,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      title: Text(e.fullName),
                      subtitle: Text(
                        [
                          if (e.phone.isNotEmpty) e.phone,
                          e.hasAccount ? l10n.hasAppAccount : l10n.noAppAccount,
                        ].join(' · '),
                      ),
                      onTap: () => setState(() {
                        _selected = byId[e.docId];
                        _searchCtrl.clear();
                        _invite = false;
                      }),
                    ),
                ],
              );
            },
          ),
        const SizedBox(height: 14),
        Text(
          l10n.orNewCustomer,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            labelText: l10n.customerName,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.phoneOptional,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  CustomerSearchEntry _entry(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final c = d.data();
    return CustomerSearchEntry(
      docId: d.id,
      clientId: c['clientId'],
      firstName: '${c['firstName'] ?? ''}',
      lastName: '${c['lastName'] ?? ''}',
      phone: '${c['phone'] ?? ''}',
      email: '${c['email'] ?? ''}',
      hasAccount: c['userId'] != null,
    );
  }
}
