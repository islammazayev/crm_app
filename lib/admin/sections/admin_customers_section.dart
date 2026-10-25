import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../forms/customer_form.dart';
import '../../l10n/locale_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/customer_search.dart';
import '../../utils/customer_tiers.dart';

class AdminCustomersSection extends StatefulWidget {
  const AdminCustomersSection({super.key});

  @override
  State<AdminCustomersSection> createState() => _AdminCustomersSectionState();
}

class _AdminCustomersSectionState extends State<AdminCustomersSection> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  /// Fler träffar än så visas inte; admin får skriva mer för att begränsa.
  static const _maxResults = 50;

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
                      style: const TextStyle(
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

  Future<void> _addCustomer({
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
        return;
      }
    }
    await customersRef.add({
      'clientId': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(labelText: l10n.phone),
                keyboardType: TextInputType.phone,
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

  /// Bygger söklistan. Land och stad hämtas från de kontor kunden har gjort
  /// transaktioner via (kopplas på kundens userId, som transaktionen sparar
  /// som customerId). Kunder som admin skapat utan konto saknar sådana.
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

    final placesByUser = <String, Set<String>>{};
    for (final d in transactionDocs) {
      final t = d.data() as Map<String, dynamic>;
      final userId = (t['customerId'] ?? '').toString();
      final place = officePlace[(t['officeId'] ?? '').toString()];
      if (userId.isEmpty || place == null || place.isEmpty) continue;
      placesByUser.putIfAbsent(userId, () => <String>{}).add(place);
    }

    return customerDocs.map((d) {
      final c = d.data() as Map<String, dynamic>;
      final userId = (c['userId'] ?? d.id).toString();
      return CustomerSearchEntry(
        docId: d.id,
        clientId: c['clientId'],
        firstName: (c['firstName'] ?? '').toString(),
        lastName: (c['lastName'] ?? '').toString(),
        phone: (c['phone'] ?? '').toString(),
        email: (c['email'] ?? '').toString(),
        places: (placesByUser[userId] ?? const <String>{}).toList()..sort(),
        tier: c['tier'] as String?,
        tierDiscount: (c['tierDiscount'] as num?)?.toDouble(),
        hasAccount: c['userId'] != null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final db = FirebaseFirestore.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomerForm(
          onSubmit:
              ({
                int? clientId,
                required String firstName,
                required String lastName,
                required String phone,
                String email = '',
              }) async {
                await _addCustomer(
                  clientId: clientId,
                  firstName: firstName,
                  lastName: lastName,
                  phone: phone,
                  email: email,
                );
              },
        ),
        const SizedBox(height: 24),
        Text(
          l10n.searchCustomers,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            labelText: l10n.searchCustomersLabel,
            hintText: l10n.searchCustomersHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.clearSearch,
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _searchController.clear();
                      _query = '';
                    }),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: customersRef.snapshots(),
          builder: (context, customerSnap) {
            return StreamBuilder<QuerySnapshot>(
              stream: db.collection('transactions').snapshots(),
              builder: (context, txSnap) {
                return StreamBuilder<QuerySnapshot>(
                  stream: db.collection('offices').snapshots(),
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
                    const muted = TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    );

                    // Ingen lista förrän admin skriver något, annars blir den
                    // lång när det finns många kunder.
                    if (_query.trim().isEmpty) {
                      return Text(
                        l10n.typeToSearchCustomers(all.length),
                        style: muted,
                      );
                    }

                    final results = searchCustomers(all, _query);
                    final shown = results.take(_maxResults).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          results.length > shown.length
                              ? l10n.customersShownLimited(
                                  shown.length,
                                  results.length,
                                )
                              : l10n.customersShown(results.length, all.length),
                          style: muted,
                        ),
                        const SizedBox(height: 8),
                        if (results.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              l10n.noCustomersMatch,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        for (final c in shown) _resultCard(c),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _resultCard(CustomerSearchEntry c) {
    final l10n = context.l10n;
    final id = c.formattedClientId;
    final tierInfo = _tiers.forCustomer({
      'tier': c.tier,
      'tierDiscount': c.tierDiscount,
    });
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryDim,
          child: Text(
            id.isEmpty ? '?' : id,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(c.fullName.isEmpty ? l10n.unknownClient : c.fullName),
        subtitle: Text(
          [
            if (tierInfo != null)
              '${tierInfo.tier.emoji} ${tierInfo.tier.label(l10n)} – '
                  '${l10n.tierDiscountShort(formatPercent(tierInfo.discount))}',
            if (c.phone.isNotEmpty) l10n.phoneValue(c.phone),
            if (c.email.isNotEmpty) l10n.emailValue(c.email),
            if (c.places.isNotEmpty) l10n.placesValue(c.places.join(', ')),
          ].join('\n'),
        ),
        isThreeLine:
            c.email.isNotEmpty || c.places.isNotEmpty || tierInfo != null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.tierLabel,
              icon: Icon(
                Icons.workspace_premium_outlined,
                color: tierInfo == null
                    ? AppColors.textMuted
                    : AppColors.warning,
              ),
              onPressed: () => _openTierDialog(c),
            ),
            IconButton(
              tooltip: l10n.edit,
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _openEditDialog(c),
            ),
            IconButton(
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCustomer(c),
            ),
          ],
        ),
      ),
    );
  }
}
