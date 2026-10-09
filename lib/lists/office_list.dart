import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/office.dart';

class OfficeList extends StatefulWidget {
  final List<Office> offices;
  final List<DocumentSnapshot> officeDocs;
  final void Function(int index)? onDelete;
  final void Function(int index)? onTopUp;
  final void Function(int index)? onEdit;

  const OfficeList({
    super.key,
    required this.offices,
    required this.officeDocs,
    this.onDelete,
    this.onTopUp,
    this.onEdit,
  });

  @override
  State<OfficeList> createState() => _OfficeListState();
}

class _OfficeListState extends State<OfficeList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasSearched = false;

  CollectionReference get usersRef =>
      FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
        _hasSearched = _searchQuery.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offices.isEmpty) {
      return const Center(child: Text('Inga kontor skapade ännu.'));
    }

    final filtered = <MapEntry<int, Office>>[];
    for (int i = 0; i < widget.offices.length; i++) {
      final office = widget.offices[i];
      if (_searchQuery.isEmpty ||
          office.country.toLowerCase().contains(_searchQuery) ||
          office.city.toLowerCase().contains(_searchQuery)) {
        filtered.add(MapEntry(i, office));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Sökfält ───────────────────────────────────────────────
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Sök på land eller stad...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        if (_hasSearched) ...[  
          const SizedBox(height: 8),
          Text(
            '${filtered.length} kontor hittade',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Inga kontor matchar sökningen.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, listIndex) {
              final originalIndex = filtered[listIndex].key;
              final office = filtered[listIndex].value;
              final officeDoc = widget.officeDocs[originalIndex];
              final officeId = officeDoc.id;

              final balancesText = office.balances.entries
                  .map((e) => '${e.key}: ${e.value.toStringAsFixed(2)}')
                  .join(', ');

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    '${office.country} – ${office.city}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saldo: $balancesText'),
                      StreamBuilder<QuerySnapshot>(
                        stream: usersRef
                            .where('officeId', isEqualTo: officeId)
                            .where('role', isEqualTo: 'manager')
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Manager: laddar …');
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Text('Manager: –');
                          }
                          final doc = snapshot.data!.docs.first;
                          final data = doc.data() as Map<String, dynamic>;
                          final firstName =
                              (data['firstName'] ?? '').toString();
                          final lastName =
                              (data['lastName'] ?? '').toString();
                          final email = (data['email'] ?? '').toString();
                          final phone = (data['phone'] ?? '').toString();
                          final fullName = [firstName, lastName]
                              .where((s) => s.isNotEmpty)
                              .join(' ');
                          final managerLine = fullName.isNotEmpty
                              ? 'Manager: $fullName'
                              : 'Manager: (okänd)';
                          final contactParts = <String>[];
                          if (email.isNotEmpty) {
                            contactParts.add('E-post: $email');
                          }
                          if (phone.isNotEmpty) {
                            contactParts.add('Telefon: $phone');
                          }
                          final contactLine = contactParts.join(' · ');
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(managerLine),
                              if (contactLine.isNotEmpty) Text(contactLine),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ─ Ändra-knapp ───────────────────────────
                      if (widget.onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.blue),
                          tooltip: 'Ändra kontor',
                          onPressed: () => widget.onEdit!(originalIndex),
                        ),
                      // ─ Fyll på saldo-knapp ───────────────────
                      if (widget.onTopUp != null)
                        IconButton(
                          icon: const Icon(Icons.add_card),
                          tooltip: 'Fyll på saldo',
                          onPressed: () => widget.onTopUp!(originalIndex),
                        ),
                      // ─ Radera-knapp ─────────────────────────
                      if (widget.onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Radera kontor',
                          onPressed: () => widget.onDelete!(originalIndex),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ], // end if (_hasSearched)
      ],
    );
  }
}
