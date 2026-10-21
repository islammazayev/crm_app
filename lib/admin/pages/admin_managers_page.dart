import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../forms/create_manager_form.dart';
import '../../l10n/locale_controller.dart';
import '../../utils/search_match.dart';
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
                const SizedBox(height: 8),
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
                                  leading: const Icon(Icons.badge_outlined),
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
