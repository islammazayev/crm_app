import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../forms/customer_form.dart';
import '../../l10n/locale_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/customer_search.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            if (c.phone.isNotEmpty) l10n.phoneValue(c.phone),
            if (c.email.isNotEmpty) l10n.emailValue(c.email),
            if (c.places.isNotEmpty) l10n.placesValue(c.places.join(', ')),
          ].join('\n'),
        ),
        isThreeLine: c.email.isNotEmpty || c.places.isNotEmpty,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
