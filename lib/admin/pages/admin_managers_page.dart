import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../forms/create_manager_form.dart';
import '../../l10n/locale_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/search_match.dart';
import '../../widgets/confirm_delete.dart';
import '../../widgets/search_summary.dart';

/// Admin: skapa managers och se vilka som finns och vilket kontor de har.
class AdminManagersPage extends StatefulWidget {
  const AdminManagersPage({super.key});

  @override
  State<AdminManagersPage> createState() => _AdminManagersPageState();
}

class _AdminManagersPageState extends State<AdminManagersPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _editManager(
    QueryDocumentSnapshot doc,
    List<QueryDocumentSnapshot> officeDocs,
  ) async {
    final l10n = context.l10n;
    final d = doc.data() as Map<String, dynamic>;
    final firstCtrl = TextEditingController(text: '${d['firstName'] ?? ''}');
    final lastCtrl = TextEditingController(text: '${d['lastName'] ?? ''}');
    final phoneCtrl = TextEditingController(text: '${d['phone'] ?? ''}');
    String? officeId = d['officeId']?.toString();
    if (officeId != null && !officeDocs.any((o) => o.id == officeId)) {
      officeId = null;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l10n.editManagerTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstCtrl,
                  decoration: InputDecoration(labelText: l10n.firstName),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: lastCtrl,
                  decoration: InputDecoration(labelText: l10n.lastName),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.phone),
                ),
                const SizedBox(height: 8),
                // E-post hör till inloggningskontot och kan inte ändras här.
                TextField(
                  controller: TextEditingController(
                    text: '${d['email'] ?? ''}',
                  ),
                  enabled: false,
                  decoration: InputDecoration(labelText: l10n.email),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String?>(
                  initialValue: officeId,
                  decoration: InputDecoration(labelText: l10n.office),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.noOfficeAssigned),
                    ),
                    for (final o in officeDocs)
                      DropdownMenuItem<String?>(
                        value: o.id,
                        child: Text(() {
                          final od = o.data() as Map<String, dynamic>;
                          return '${od['country'] ?? ''} – ${od['city'] ?? ''}';
                        }()),
                      ),
                  ],
                  onChanged: (v) => setLocal(() => officeId = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      try {
        await doc.reference.update({
          'firstName': firstCtrl.text.trim(),
          'lastName': lastCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'officeId': officeId ?? FieldValue.delete(),
        });
        _snack(l10n.managerUpdated);
      } catch (e) {
        _snack(l10n.errorWithDetails('$e'));
      }
    }
    firstCtrl.dispose();
    lastCtrl.dispose();
    phoneCtrl.dispose();
  }

  /// Tar bort managerns profil (users/{uid}). Då har kontot ingen roll och
  /// kommer inte åt något. Själva inloggningskontot kan bara tas bort i
  /// Firebase-konsolen (Authentication), inte från appen.
  Future<void> _deleteManager(QueryDocumentSnapshot doc, String name) async {
    final l10n = context.l10n;
    final ok = await confirmDelete(
      context,
      title: l10n.deleteManagerTitle,
      message: l10n.deleteManagerConfirm(name),
    );
    if (!ok) return;
    try {
      await doc.reference.delete();
      _snack(l10n.managerDeleted);
    } catch (e) {
      _snack(l10n.errorWithDetails('$e'));
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.managers)),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('offices').snapshots(),
        builder: (context, officeSnap) {
          if (!officeSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final officeDocs = officeSnap.data!.docs;
          final officeLabels = {
            for (final d in officeDocs)
              d.id: () {
                final data = d.data() as Map<String, dynamic>;
                return '${data['country'] ?? ''} – ${data['city'] ?? ''}';
              }(),
          };

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CreateManagerForm(officeDocs: officeDocs),
                const SizedBox(height: 32),
                Text(
                  l10n.existingManagers,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    labelText: l10n.searchManagersLabel,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: db
                      .collection('users')
                      .where('role', isEqualTo: 'manager')
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Text(l10n.errorWithDetails('${snap.error}'));
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final all = snap.data!.docs;
                    if (all.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.noManagersYet,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    String officeOf(Map<String, dynamic> d) {
                      final officeId = d['officeId']?.toString();
                      return officeLabels[officeId] ?? l10n.noOfficeAssigned;
                    }

                    final empty = isEmptySearch(_query);
                    final matches = empty
                        ? <QueryDocumentSnapshot>[]
                        : all.where((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            return matchesSearch(
                              _query,
                              phones: ['${d['phone'] ?? ''}'],
                              texts: [
                                '${d['firstName'] ?? ''}',
                                '${d['lastName'] ?? ''}',
                                '${d['email'] ?? ''}',
                                '${d['phone'] ?? ''}',
                                officeOf(d),
                              ],
                            );
                          }).toList();
                    final docs = matches.take(maxSearchResults).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SearchSummary(
                          empty: empty,
                          total: all.length,
                          matches: matches.length,
                          shown: docs.length,
                        ),
                        for (final doc in docs)
                          Builder(
                            builder: (context) {
                              final d = doc.data() as Map<String, dynamic>;
                              final name =
                                  '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'
                                      .trim();
                              final email = (d['email'] ?? '').toString();
                              final phone = (d['phone'] ?? '').toString();
                              final office = officeOf(d);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.badge_outlined,
                                    color: AppColors.warning,
                                  ),
                                  title: Text(name.isEmpty ? email : name),
                                  subtitle: Text(
                                    [
                                      l10n.officeValue(office),
                                      if (email.isNotEmpty)
                                        l10n.emailValue(email),
                                      if (phone.isNotEmpty)
                                        l10n.phoneValue(phone),
                                    ].join('\n'),
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: l10n.edit,
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () =>
                                            _editManager(doc, officeDocs),
                                      ),
                                      IconButton(
                                        tooltip: l10n.deleteAction,
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteManager(
                                          doc,
                                          name.isEmpty ? email : name,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
