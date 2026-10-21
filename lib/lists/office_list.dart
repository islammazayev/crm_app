import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';
import '../models/office.dart';
import '../utils/search_match.dart';
import '../widgets/search_summary.dart';

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

  CollectionReference get usersRef =>
      FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
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
    final l10n = context.l10n;

    if (widget.offices.isEmpty) {
      return Center(child: Text(l10n.noOfficesYet));
    }

    final empty = isEmptySearch(_searchQuery);
    final matches = <MapEntry<int, Office>>[];
    if (!empty) {
      for (int i = 0; i < widget.offices.length; i++) {
        final office = widget.offices[i];
        if (matchesSearch(
          _searchQuery,
          texts: [office.country, office.city, ...office.currencies],
        )) {
          matches.add(MapEntry(i, office));
        }
      }
    }
    final filtered = matches.take(maxSearchResults).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Sökfält ───────────────────────────────────────────────
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: l10n.searchOfficesLabel,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
        ),
        SearchSummary(
          empty: empty,
          total: widget.offices.length,
          matches: matches.length,
          shown: filtered.length,
        ),
        if (filtered.isNotEmpty)
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
                      Text(l10n.balanceValue(balancesText)),
                      StreamBuilder<QuerySnapshot>(
                        stream: usersRef
                            .where('officeId', isEqualTo: officeId)
                            .where('role', isEqualTo: 'manager')
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(l10n.managerLoading);
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Text(l10n.managerNone);
                          }
                          final doc = snapshot.data!.docs.first;
                          final data = doc.data() as Map<String, dynamic>;
                          final firstName = (data['firstName'] ?? '')
                              .toString();
                          final lastName = (data['lastName'] ?? '').toString();
                          final email = (data['email'] ?? '').toString();
                          final phone = (data['phone'] ?? '').toString();
                          final fullName = [
                            firstName,
                            lastName,
                          ].where((s) => s.isNotEmpty).join(' ');
                          final managerLine = fullName.isNotEmpty
                              ? l10n.managerValue(fullName)
                              : l10n.managerUnknown;
                          final contactParts = <String>[];
                          if (email.isNotEmpty) {
                            contactParts.add(l10n.emailValue(email));
                          }
                          if (phone.isNotEmpty) {
                            contactParts.add(l10n.phoneValue(phone));
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
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                          ),
                          tooltip: l10n.editOffice,
                          onPressed: () => widget.onEdit!(originalIndex),
                        ),
                      // ─ Fyll på saldo-knapp ───────────────────
                      if (widget.onTopUp != null)
                        IconButton(
                          icon: const Icon(Icons.add_card),
                          tooltip: l10n.topUpBalance,
                          onPressed: () => widget.onTopUp!(originalIndex),
                        ),
                      // ─ Radera-knapp ─────────────────────────
                      if (widget.onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: l10n.deleteOffice,
                          onPressed: () => widget.onDelete!(originalIndex),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
