import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../forms/create_manager_form.dart';
import '../../l10n/locale_controller.dart';

/// Admin: skapa managers och se vilka som finns och vilket kontor de har.
class AdminManagersPage extends StatelessWidget {
  const AdminManagersPage({super.key});

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
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
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
                    final docs = snap.data!.docs;
                    if (docs.isEmpty) {
                      return Text(
                        l10n.noManagersYet,
                        style: const TextStyle(color: Colors.grey),
                      );
                    }
                    return Column(
                      children: [
                        for (final doc in docs)
                          Builder(builder: (context) {
                            final d = doc.data() as Map<String, dynamic>;
                            final name =
                                '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'
                                    .trim();
                            final email = (d['email'] ?? '').toString();
                            final phone = (d['phone'] ?? '').toString();
                            final officeId = d['officeId']?.toString();
                            final office = officeId == null
                                ? l10n.noOfficeAssigned
                                : officeLabels[officeId] ??
                                    l10n.noOfficeAssigned;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const Icon(Icons.badge_outlined),
                                title: Text(name.isEmpty ? email : name),
                                subtitle: Text([
                                  l10n.officeValue(office),
                                  if (email.isNotEmpty) l10n.emailValue(email),
                                  if (phone.isNotEmpty) l10n.phoneValue(phone),
                                ].join('\n')),
                                isThreeLine: true,
                              ),
                            );
                          }),
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
