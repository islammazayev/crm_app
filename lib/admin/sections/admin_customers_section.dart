import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../forms/customer_form.dart';
import '../../l10n/locale_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/customer_search.dart';
import '../../services/customer_invite_service.dart';
import '../../utils/customer_filter.dart';
import '../../utils/customer_tiers.dart';
import '../../widgets/admin_list.dart';
import '../../widgets/overview_widgets.dart';
import '../../widgets/phone_field.dart';

class AdminCustomersSection extends StatefulWidget {
  /// Nivå att filtrera på från början (t.ex. från Kundnivåer).
  final String? initialTier;

  const AdminCustomersSection({super.key, this.initialTier});

  @override
  State<AdminCustomersSection> createState() => _AdminCustomersSectionState();
}

class _AdminCustomersSectionState extends State<AdminCustomersSection> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late CustomerFilter _filter = CustomerFilter(tier: widget.initialTier);
  bool _showAdvanced = false;
  int _page = 0;

  /// Så många kunder per sida i listan.
  static const _pageSize = 20;

  final _db = FirebaseFirestore.instance;
  late final _customerStream = _db.collection('customers').snapshots();
  late final _transactionStream = _db.collection('transactions').snapshots();
  late final _officeStream = _db.collection('offices').snapshots();

  CollectionReference get customersRef =>
      FirebaseFirestore.instance.collection('customers');

  final DocumentReference metaCustomersRef = FirebaseFirestore.instance
      .collection('meta')
      .doc('customers');

  TierSettings _tiers = const TierSettings();
  late final StreamSubscription<TierSettings> _tiersSub;

  @override
  void initState() {
    super.initState();
    _tiersSub = TierSettings.watch().listen(
      (t) => setState(() => _tiers = t),
      onError: (Object e) => debugPrint('Kundnivåer kunde inte läsas: $e'),
    );
  }

  @override
  void dispose() {
    _tiersSub.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Ge kunden en nivå (eller ingen) och ev. en egen rabatt.
  Future<void> _openTierDialog(CustomerSearchEntry c) async {
    final l10n = context.l10n;
    CustomerTier? tier = parseTier(c.tier);
    final customCtrl = TextEditingController(
      text: c.tierDiscount == null ? '' : formatPercent(c.tierDiscount!),
    );

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final custom = double.tryParse(
            customCtrl.text.trim().replaceAll(',', '.'),
          );
          final customInvalid =
              customCtrl.text.trim().isNotEmpty &&
              (custom == null || custom < 0 || custom > 100);
          final discount = tier == null
              ? null
              : (custom ?? _tiers.discounts[tier]!);
          return AlertDialog(
            title: Text(l10n.customerTierTitle(c.fullName)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<CustomerTier?>(
                    initialValue: tier,
                    decoration: InputDecoration(labelText: l10n.tierLabel),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.tierNone)),
                      for (final t in CustomerTier.values)
                        DropdownMenuItem(
                          value: t,
                          child: Text(
                            '${t.emoji} ${t.label(l10n)} – '
                            '${formatPercent(_tiers.discounts[t]!)} %',
                          ),
                        ),
                    ],
                    onChanged: (v) => setDialogState(() => tier = v),
                  ),
                  if (tier != null) ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: customCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: l10n.customDiscountLabel,
                        helperText: l10n.customDiscountHelper,
                        helperMaxLines: 3,
                        errorText: customInvalid
                            ? l10n.tierInvalidValues
                            : null,
                        suffixText: '%',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.tierFeeSummary(
                        formatPercent(discount!),
                        formatPercent(
                          CustomerTierInfo(
                            tier: tier!,
                            discount: discount,
                          ).feeAfterDiscount(5),
                        ),
                      ),
                    ),
                  ],
                  if (!c.hasAccount) ...[
                    const SizedBox(height: 14),
                    Text(
                      l10n.tierNoAccountNote,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: customInvalid
                    ? null
                    : () async {
                        await customersRef.doc(c.docId).update({
                          'tier': tier?.name ?? FieldValue.delete(),
                          'tierDiscount': tier == null || custom == null
                              ? FieldValue.delete()
                              : custom,
                          'updatedAt': FieldValue.serverTimestamp(),
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.customerTierSaved)),
                          );
                        }
                      },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );

    customCtrl.dispose();
  }

  Future<int> _nextClientId() async {
    return FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(metaCustomersRef);
      int lastId = 0;
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        lastId = (data['lastClientId'] ?? 0) as int;
      }
      final nextId = lastId + 1;
      tx.set(metaCustomersRef, {
        'lastClientId': nextId,
      }, SetOptions(merge: true));
      return nextId;
    });
  }

  /// Sparar kunden och returnerar kundpostens ID.
  Future<String> _addCustomer({
    int? clientId,
    required String firstName,
    required String lastName,
    required String phone,
    String email = '',
  }) async {
    final id = clientId ?? await _nextClientId();
    if (clientId != null) {
      final existing = await customersRef
          .where('clientId', isEqualTo: clientId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        await customersRef.doc(existing.docs.first.id).update({
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'email': email,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return existing.docs.first.id;
      }
    }
    final ref = await customersRef.add({
      'clientId': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Skickar en länk via SMS eller e-post så att kunden kan skapa konto i
  /// appen och behålla sitt klient-ID. Kunden skapar bara lösenord.
  Future<void> _sendInvite(String docId, {bool email = false}) async {
    final l10n = context.l10n;
    try {
      final snap = await customersRef.doc(docId).get();
      final d = snap.data() as Map<String, dynamic>?;
      if (d == null || d['userId'] != null) return;
      final phone = '${d['phone'] ?? ''}'.trim();
      final address = '${d['email'] ?? ''}'.trim();
      if (!email && phone.isEmpty) {
        _snack(l10n.invitePhoneRequired);
        return;
      }
      if (email && !address.contains('@')) {
        _snack(l10n.inviteEmailRequired);
        return;
      }
      // Admins inbjudan: kunden har redan sina uppgifter och skapar bara
      // lösenord (se kundens registreringssida).
      await customersRef.doc(docId).update({'inviteByAdmin': true});
      final code = await CustomerInviteService.inviteExisting(
        docId,
        d['inviteCode'] as String?,
      );
      final message = l10n.inviteSmsText(
        '${d['firstName'] ?? ''}'.trim(),
        CustomerInviteService.inviteLink(docId, code),
      );
      if (email) {
        await CustomerInviteService.openEmail(
          address,
          l10n.inviteEmailSubject,
          message,
        );
      } else {
        await CustomerInviteService.openSms(phone, message);
      }
    } catch (e) {
      _snack(l10n.errorWithDetails('$e'));
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Öppna redigeringsdialog med förifyllda fält
  Future<void> _openEditDialog(CustomerSearchEntry c) async {
    final firstNameCtrl = TextEditingController(text: c.firstName);
    final lastNameCtrl = TextEditingController(text: c.lastName);
    final phoneCtrl = TextEditingController(text: c.phone);
    final emailCtrl = TextEditingController(text: c.email);
    final l10n = context.l10n;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editCustomerTitle(c.formattedClientId)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameCtrl,
                decoration: InputDecoration(labelText: l10n.firstName),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: lastNameCtrl,
                decoration: InputDecoration(labelText: l10n.lastName),
              ),
              const SizedBox(height: 14),
              PhoneField(
                controller: phoneCtrl,
                decoration: InputDecoration(labelText: l10n.phone),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: l10n.email),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await customersRef.doc(c.docId).update({
                'firstName': firstNameCtrl.text.trim(),
                'lastName': lastNameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.customerUpdated)));
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
  }

  // Bekräfta och ta bort kund
  Future<void> _deleteCustomer(CustomerSearchEntry c) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCustomerTitle),
        content: Text(
          l10n.deleteCustomerConfirm(c.formattedClientId, c.fullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await customersRef.doc(c.docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.customerDeleted)));
      }
    }
  }

  /// Bygger kundlistan. Ort och senaste transaktion kommer från kundens
  /// transaktioner: de kunden skickat själv (customerId = kundens userId)
  /// och de managern skapat på kontoret med kundens klient-ID.
  List<CustomerSearchEntry> _entries(
    List<QueryDocumentSnapshot> customerDocs,
    List<QueryDocumentSnapshot> transactionDocs,
    List<QueryDocumentSnapshot> officeDocs,
  ) {
    final officePlace = <String, String>{
      for (final d in officeDocs)
        d.id: () {
          final o = d.data() as Map<String, dynamic>;
          return '${o['country'] ?? ''} ${o['city'] ?? ''}'.trim();
        }(),
    };

    final places = <String, Set<String>>{};
    final last = <String, DateTime>{};
    void note(String key, String? place, DateTime? at) {
      if (key.isEmpty) return;
      if (place != null && place.isNotEmpty) {
        places.putIfAbsent(key, () => <String>{}).add(place);
      }
      if (at != null && (last[key] == null || at.isAfter(last[key]!))) {
        last[key] = at;
      }
    }

    for (final d in transactionDocs) {
      final t = d.data() as Map<String, dynamic>;
      final place = officePlace['${t['officeId'] ?? ''}'];
      final at = (t['createAt'] as Timestamp?)?.toDate();
      note(
        'u:${t['customerId'] ?? ''}'.replaceAll(RegExp(r'^u:$'), ''),
        place,
        at,
      );
      if ('${t['customerId'] ?? ''}'.isEmpty) {
        note(
          'c:${t['clientId'] ?? ''}'.replaceAll(RegExp(r'^c:$'), ''),
          place,
          at,
        );
      }
    }

    return customerDocs.map((d) {
      final c = d.data() as Map<String, dynamic>;
      final userKey = 'u:${c['userId'] ?? d.id}';
      final clientKey = 'c:${c['clientId'] ?? ''}';
      final userLast = last[userKey];
      final clientLast = last[clientKey];
      return CustomerSearchEntry(
        docId: d.id,
        clientId: c['clientId'],
        firstName: (c['firstName'] ?? '').toString(),
        lastName: (c['lastName'] ?? '').toString(),
        phone: (c['phone'] ?? '').toString(),
        email: (c['email'] ?? '').toString(),
        places: {...?places[userKey], ...?places[clientKey]}.toList()..sort(),
        tier: c['tier'] as String?,
        tierDiscount: (c['tierDiscount'] as num?)?.toDouble(),
        hasAccount: c['userId'] != null,
        createdAt: ((c['createdAt'] ?? c['createAt']) as Timestamp?)?.toDate(),
        lastActivity: userLast == null
            ? clientLast
            : clientLast == null || userLast.isAfter(clientLast)
            ? userLast
            : clientLast,
      );
    }).toList();
  }

  void _setFilter(CustomerFilter f) => setState(() {
    _filter = f;
    _page = 0;
  });

  /// "Lägg till kund" i en ruta mitt på skärmen.
  Future<void> _openAddDialog() => showFormDialog(
    context,
    (ctx, close) => CustomerForm(
      onSubmit:
          ({
            int? clientId,
            required String firstName,
            required String lastName,
            required String phone,
            String email = '',
            bool sendInvite = false,
            bool sendEmailInvite = false,
          }) async {
            final docId = await _addCustomer(
              clientId: clientId,
              firstName: firstName,
              lastName: lastName,
              phone: phone,
              email: email,
            );
            close();
            // Bara när admin själv gav klient-ID:t och bockade i SMS.
            if (clientId != null && sendInvite) await _sendInvite(docId);
            if (clientId != null && sendEmailInvite) {
              await _sendInvite(docId, email: true);
            }
          },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<QuerySnapshot>(
      stream: _customerStream,
      builder: (context, customerSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: _transactionStream,
          builder: (context, txSnap) {
            return StreamBuilder<QuerySnapshot>(
              stream: _officeStream,
              builder: (context, officeSnap) {
                final error =
                    customerSnap.error ?? txSnap.error ?? officeSnap.error;
                if (error != null) {
                  return Text(l10n.errorWithDetails('$error'));
                }
                if (!customerSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = _entries(
                  customerSnap.data!.docs,
                  txSnap.data?.docs ?? const [],
                  officeSnap.data?.docs ?? const [],
                );
                return _content(all);
              },
            );
          },
        );
      },
    );
  }

  Widget _content(List<CustomerSearchEntry> all) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final withAccount = all.where((e) => e.hasAccount).length;
    final withTier = all.where((e) => e.tier != null).length;
    final newThisMonth = all
        .where((e) => e.createdAt != null && !e.createdAt!.isBefore(monthStart))
        .length;
    final results = _filter.apply(all, _query, now: now);
    final pages = (results.length / _pageSize).ceil().clamp(1, 1 << 20);
    final page = _page.clamp(0, pages - 1);
    final shown = results.skip(page * _pageSize).take(_pageSize).toList();
    final places = {for (final e in all) ...e.places}.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminListHeader(
          summary: l10n.customersSummary(all.length, withAccount),
          addLabel: l10n.addCustomer,
          onAdd: _openAddDialog,
        ),
        const SizedBox(height: 16),
        StatRow(
          stats: [
            StatData(
              l10n.statAll,
              '${all.length}',
              AppColors.textPrimary,
              onTap: () => _setFilter(const CustomerFilter()),
            ),
            StatData(
              l10n.filterWithAccount,
              '$withAccount',
              AppColors.primary,
              onTap: () => _setFilter(_filter.copyWith(account: true)),
            ),
            StatData(
              l10n.filterWithTier,
              '$withTier',
              AppColors.warning,
              onTap: () => _setFilter(_filter.copyWith(tier: 'any')),
            ),
            StatData(
              l10n.newThisMonth,
              '$newThisMonth',
              AppColors.info,
              onTap: () => _setFilter(
                _filter.copyWith(createdFrom: monthStart, createdTo: null),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.all(12), child: _searchBar()),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: _quickFilters(),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: _showAdvanced
                    ? _advancedPanel(places)
                    : const SizedBox(width: double.infinity),
              ),
              Divider(height: 1, color: AppColors.surfaceBorder),
              if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.noCustomersMatch,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              for (final c in shown) _row(c),
              if (results.isNotEmpty)
                AdminPager(
                  page: page,
                  pageSize: _pageSize,
                  total: results.length,
                  onPage: (p) => setState(() => _page = p),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    final l10n = context.l10n;
    final count = _filter.advancedCount;
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() {
        _query = v;
        _page = 0;
      }),
      decoration: InputDecoration(
        hintText: l10n.searchCustomersHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_query.isNotEmpty)
              IconButton(
                tooltip: l10n.clearSearch,
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() {
                  _searchController.clear();
                  _query = '';
                  _page = 0;
                }),
              ),
            IconButton(
              tooltip: l10n.advancedFilters,
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: Icon(
                  Icons.tune,
                  color: _showAdvanced || count > 0
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ),
              onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickFilters() {
    final l10n = context.l10n;
    Widget chip(String label, bool selected, CustomerFilter Function() next) =>
        ChoiceChip(
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) => _setFilter(next()),
        );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(
          l10n.statAll,
          _filter.account == null && _filter.tier == null,
          () => _filter.copyWith(account: null, tier: null),
        ),
        chip(
          l10n.filterWithAccount,
          _filter.account == true,
          () =>
              _filter.copyWith(account: _filter.account == true ? null : true),
        ),
        chip(
          l10n.filterWithoutAccount,
          _filter.account == false,
          () => _filter.copyWith(
            account: _filter.account == false ? null : false,
          ),
        ),
        for (final t in CustomerTier.values)
          chip(
            '${t.emoji} ${t.label(l10n)}',
            _filter.tier == t.name,
            () =>
                _filter.copyWith(tier: _filter.tier == t.name ? null : t.name),
          ),
      ],
    );
  }

  Widget _advancedPanel(List<String> places) {
    final l10n = context.l10n;
    final f = _filter;
    String day(DateTime d) => formatDay(context, d);
    final created = f.createdFrom == null && f.createdTo == null
        ? l10n.filterAnyDate
        : '${f.createdFrom == null ? '…' : day(f.createdFrom!)} – '
              '${f.createdTo == null ? '…' : day(f.createdTo!)}';
    Widget field(String label, Widget child) => SizedBox(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
    return Container(
      width: double.infinity,
      color: AppColors.surface2,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 14,
            children: [
              field(
                l10n.filterTier,
                DropdownButtonFormField<String?>(
                  key: ValueKey('tier-${f.tier}'),
                  initialValue: f.tier,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.statAll)),
                    DropdownMenuItem(
                      value: 'any',
                      child: Text(l10n.filterWithTier),
                    ),
                    DropdownMenuItem(value: 'none', child: Text(l10n.tierNone)),
                    for (final t in CustomerTier.values)
                      DropdownMenuItem(
                        value: t.name,
                        child: Text('${t.emoji} ${t.label(l10n)}'),
                      ),
                  ],
                  onChanged: (v) => _setFilter(f.copyWith(tier: v)),
                ),
              ),
              field(
                l10n.filterPlace,
                DropdownButtonFormField<String?>(
                  key: ValueKey('place-${f.place}'),
                  initialValue: f.place,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.statAll)),
                    for (final p in places)
                      DropdownMenuItem(value: p, child: Text(p)),
                  ],
                  onChanged: (v) => _setFilter(f.copyWith(place: v)),
                ),
              ),
              field(
                l10n.filterLastTransaction,
                DropdownButtonFormField<int?>(
                  key: ValueKey('active-${f.activeWithinDays}'),
                  initialValue: f.activeWithinDays,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.filterAnyDate),
                    ),
                    for (final days in const [7, 30, 90])
                      DropdownMenuItem(
                        value: days,
                        child: Text(l10n.filterWithinDays(days)),
                      ),
                    DropdownMenuItem(value: 0, child: Text(l10n.filterNever)),
                  ],
                  onChanged: (v) => _setFilter(f.copyWith(activeWithinDays: v)),
                ),
              ),
              field(
                l10n.filterCreated,
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(created, overflow: TextOverflow.ellipsis),
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange:
                          f.createdFrom != null && f.createdTo != null
                          ? DateTimeRange(
                              start: f.createdFrom!,
                              end: f.createdTo!,
                            )
                          : null,
                    );
                    if (range != null) {
                      _setFilter(
                        f.copyWith(
                          createdFrom: range.start,
                          createdTo: range.end,
                        ),
                      );
                    }
                  },
                ),
              ),
              field(
                l10n.sortBy,
                DropdownButtonFormField<CustomerSort>(
                  key: ValueKey('sort-${f.sort}'),
                  initialValue: f.sort,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: CustomerSort.newest,
                      child: Text(l10n.sortNewest),
                    ),
                    DropdownMenuItem(
                      value: CustomerSort.name,
                      child: Text(l10n.sortName),
                    ),
                    DropdownMenuItem(
                      value: CustomerSort.clientId,
                      child: Text(l10n.sortClientId),
                    ),
                  ],
                  onChanged: (v) => _setFilter(f.copyWith(sort: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            icon: const Icon(Icons.filter_alt_off_outlined),
            label: Text(l10n.clearFilters),
            onPressed: f.isEmpty && f.sort == CustomerSort.newest
                ? null
                : () => _setFilter(const CustomerFilter()),
          ),
        ],
      ),
    );
  }

  /// En kund i listan.
  Widget _row(CustomerSearchEntry c) {
    final l10n = context.l10n;
    final tierInfo = _tiers.forCustomer({
      'tier': c.tier,
      'tierDiscount': c.tierDiscount,
    });
    final pill = tierInfo != null
        ? AdminPill(
            '${tierInfo.tier.emoji} ${tierInfo.tier.label(l10n)}',
            AppColors.warning,
          )
        : c.hasAccount
        ? AdminPill(l10n.hasAppAccount, AppColors.primary)
        : AdminPill(l10n.noAppAccount, AppColors.textMuted);
    return AdminRow(
      avatar: AdminAvatar(name: c.fullName),
      title: c.fullName.isEmpty ? l10n.unknownClient : c.fullName,
      subtitle: [
        'ID ${c.formattedClientId}',
        if (c.lastActivity != null)
          l10n.lastActivityValue(formatDay(context, c.lastActivity!)),
      ].join(' · '),
      columns: [c.phone, c.places.join(', ')],
      pill: pill,
      onTap: () => _openEditDialog(c),
      actions: [
        AdminAction(l10n.edit, Icons.edit_outlined, () => _openEditDialog(c)),
        if (!c.hasAccount && c.phone.trim().isNotEmpty)
          AdminAction(
            l10n.sendAppInvite,
            Icons.sms_outlined,
            () => _sendInvite(c.docId),
          ),
        if (!c.hasAccount && c.email.contains('@'))
          AdminAction(
            l10n.sendAppInviteEmail,
            Icons.email_outlined,
            () => _sendInvite(c.docId, email: true),
          ),
        AdminAction(
          l10n.tierLabel,
          Icons.workspace_premium_outlined,
          () => _openTierDialog(c),
        ),
        AdminAction(
          l10n.delete,
          Icons.delete_outline,
          () => _deleteCustomer(c),
          danger: true,
        ),
      ],
    );
  }
}
