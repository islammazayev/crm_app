import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../forms/customer_form.dart';
import '../../l10n/locale_controller.dart';
import '../../models/customer.dart';

class AdminCustomersSection extends StatefulWidget {
  const AdminCustomersSection({super.key});

  @override
  State<AdminCustomersSection> createState() => _AdminCustomersSectionState();
}

class _AdminCustomersSectionState extends State<AdminCustomersSection> {
  final TextEditingController _clientIdSearchController =
      TextEditingController();

  Customer? _clientIdSearchResult;
  String? _foundDocId; // Firestore-dokument-ID för hittad kund

  CollectionReference get customersRef =>
      FirebaseFirestore.instance.collection('customers');

  final DocumentReference metaCustomersRef =
      FirebaseFirestore.instance.collection('meta').doc('customers');

  @override
  void dispose() {
    _clientIdSearchController.dispose();
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
      tx.set(metaCustomersRef, {'lastClientId': nextId},
          SetOptions(merge: true));
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

  Future<void> _searchByClientId() async {
    final raw = _clientIdSearchController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _clientIdSearchResult = null;
        _foundDocId = null;
      });
      return;
    }

    QuerySnapshot q;
    final idAsInt = int.tryParse(raw);
    if (idAsInt != null) {
      q = await customersRef
          .where('clientId', isEqualTo: idAsInt)
          .limit(1)
          .get();
      if (q.docs.isEmpty) {
        q = await customersRef
            .where('clientId', isEqualTo: raw)
            .limit(1)
            .get();
      }
    } else {
      q = await customersRef
          .where('clientId', isEqualTo: raw)
          .limit(1)
          .get();
    }

    if (q.docs.isEmpty) {
      setState(() {
        _clientIdSearchResult = null;
        _foundDocId = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.noCustomerWithClientId(raw))),
        );
      }
      return;
    }

    final doc = q.docs.first;
    final data = doc.data() as Map<String, dynamic>;
    final rawId = data['clientId'];
    final resolvedId =
        rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    setState(() {
      _foundDocId = doc.id;
      _clientIdSearchResult = Customer(
        clientId: resolvedId,
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        phone: data['phone'] ?? '',
        email: data['email'] ?? '',
      );
    });
  }

  // Öppna redigeringsdialog med förifyllda fält
  Future<void> _openEditDialog(Customer c) async {
    final firstNameCtrl = TextEditingController(text: c.firstName);
    final lastNameCtrl = TextEditingController(text: c.lastName);
    final phoneCtrl = TextEditingController(text: c.phone);
    final emailCtrl = TextEditingController(text: c.email);
    final l10n = context.l10n;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editCustomerTitle(c.clientId.toString().padLeft(3, '0'))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameCtrl,
                decoration: InputDecoration(labelText: l10n.firstName),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lastNameCtrl,
                decoration: InputDecoration(labelText: l10n.lastName),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(labelText: l10n.phone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
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
              if (_foundDocId == null) return;
              await customersRef.doc(_foundDocId).update({
                'firstName': firstNameCtrl.text.trim(),
                'lastName': lastNameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
              // Uppdatera sökresultatkort direkt
              setState(() {
                _clientIdSearchResult = Customer(
                  clientId: c.clientId,
                  firstName: firstNameCtrl.text.trim(),
                  lastName: lastNameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                );
              });
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.customerUpdated)),
                );
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
  Future<void> _deleteCustomer(Customer c) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCustomerTitle),
        content: Text(
          l10n.deleteCustomerConfirm(
            c.clientId.toString().padLeft(3, '0'),
            '${c.firstName} ${c.lastName}',
          ),
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

    if (confirmed == true && _foundDocId != null) {
      await customersRef.doc(_foundDocId).delete();
      setState(() {
        _clientIdSearchResult = null;
        _foundDocId = null;
        _clientIdSearchController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.customerDeleted)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.createUpdateCustomer,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        CustomerForm(
          onSubmit: ({
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _clientIdSearchController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.searchClientId,
                  hintText: l10n.clientIdHint,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _searchByClientId,
              child: Text(l10n.search),
            ),
          ],
        ),

        // Sökresultat-kort med ändra + ta bort
        if (_clientIdSearchResult != null) ...[
          const SizedBox(height: 12),
          Card(
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.customerNumber(
                            _clientIdSearchResult!.clientId
                                .toString()
                                .padLeft(3, '0'),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Ändra-knapp
                      IconButton(
                        tooltip: l10n.edit,
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _openEditDialog(_clientIdSearchResult!),
                      ),
                      // Ta bort-knapp
                      IconButton(
                        tooltip: l10n.delete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _deleteCustomer(_clientIdSearchResult!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.nameValue(
                      '${_clientIdSearchResult!.firstName} ${_clientIdSearchResult!.lastName}')),
                  Text(l10n.phoneValue(_clientIdSearchResult!.phone)),
                  if (_clientIdSearchResult!.email.isNotEmpty)
                    Text(l10n.emailValue(_clientIdSearchResult!.email)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
