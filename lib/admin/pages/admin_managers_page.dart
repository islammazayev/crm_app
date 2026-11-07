import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../forms/create_manager_form.dart';
import '../../l10n/locale_controller.dart';
import '../../services/cashier_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/search_match.dart';
import '../../widgets/admin_list.dart';
import '../../widgets/confirm_delete.dart';
import '../../widgets/overview_widgets.dart';
import '../../widgets/phone_field.dart';

/// Admin: skapa managers och se vilka som finns och vilket kontor de har.
class AdminManagersPage extends StatefulWidget {
  const AdminManagersPage({super.key});

  @override
  State<AdminManagersPage> createState() => _AdminManagersPageState();
}

class _AdminManagersPageState extends State<AdminManagersPage> {
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
    final wasCashier = d['alsoCashier'] == true;
    bool alsoCashier = wasCashier;

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
                PhoneField(
                  controller: phoneCtrl,
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
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: alsoCashier,
                  onChanged: (v) => setLocal(() => alsoCashier = v ?? false),
                  title: Text(l10n.alsoCashier),
                  subtitle: Text(l10n.alsoCashierHint),
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
        // Kassan följer managerns namn och kontor; slås av om bocken tas bort.
        if (alsoCashier || wasCashier) {
          await CashierService.setManagerAlsoCashier(
            uid: doc.id,
            enabled: alsoCashier,
            firstName: firstCtrl.text.trim(),
            lastName: lastCtrl.text.trim(),
            officeId: officeId,
            officeLabel: officeLabelOf(officeDocs, officeId),
          );
        }
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

  late final _officeStream = FirebaseFirestore.instance
      .collection('offices')
      .snapshots();
  late final _managerStream = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'manager')
      .snapshots();

  /// Valt snabbfilter (index), null = alla.
  int? _filter;

  // Avancerade filter (⚙). _office: kontors-id, '' = inget kontor.
  String? _office;
  bool? _alsoCashier;
  String _sort = 'name';

  int get _advancedCount =>
      [_office, _alsoCashier].where((v) => v != null).length;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.managers)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _officeStream,
        builder: (context, officeSnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: _managerStream,
            builder: (context, snap) {
              final error = officeSnap.error ?? snap.error;
              if (error != null) {
                return Center(child: Text(l10n.errorWithDetails('$error')));
              }
              if (!officeSnap.hasData || !snap.hasData) {
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
              String nameOf(Map<String, dynamic> d) =>
                  '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
              String? officeOf(Map<String, dynamic> d) =>
                  officeLabels[d['officeId']?.toString()];
              Map<String, dynamic> data(QueryDocumentSnapshot doc) =>
                  doc.data() as Map<String, dynamic>;

              final all = List<QueryDocumentSnapshot>.from(snap.data!.docs)
                ..sort(
                  (a, b) => nameOf(
                    data(a),
                  ).toLowerCase().compareTo(nameOf(data(b)).toLowerCase()),
                );
              final filters = [
                AdminFilter<QueryDocumentSnapshot>(
                  l10n.filterWithOffice,
                  (d) => officeOf(data(d)) != null,
                ),
                AdminFilter<QueryDocumentSnapshot>(
                  l10n.filterWithoutOffice,
                  (d) => officeOf(data(d)) == null,
                ),
                AdminFilter<QueryDocumentSnapshot>(
                  l10n.alsoCashier,
                  (d) => data(d)['alsoCashier'] == true,
                ),
              ];
              int count(int i) => all.where(filters[i].test).length;
              final items = all.where((doc) {
                final d = data(doc);
                final officeId = officeOf(d) == null
                    ? ''
                    : d['officeId'].toString();
                if (_office != null && officeId != _office) return false;
                if (_alsoCashier != null &&
                    (d['alsoCashier'] == true) != _alsoCashier) {
                  return false;
                }
                return true;
              }).toList();
              if (_sort == 'office') {
                items.sort(
                  (a, b) => (officeOf(data(a)) ?? '~').compareTo(
                    officeOf(data(b)) ?? '~',
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AdminListHeader(
                      summary: l10n.managersSummary(all.length, count(0)),
                      addLabel: l10n.addManager,
                      onAdd: () => showFormDialog(
                        context,
                        (ctx, close) => CreateManagerForm(
                          officeDocs: officeDocs,
                          onCreated: close,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    StatRow(
                      stats: [
                        StatData(
                          l10n.statAll,
                          '${all.length}',
                          AppColors.textPrimary,
                          onTap: () => setState(() => _filter = null),
                        ),
                        for (final (i, color) in [
                          AppColors.primary,
                          AppColors.warning,
                          AppColors.info,
                        ].indexed)
                          StatData(
                            filters[i].label,
                            '${count(i)}',
                            color,
                            onTap: () => setState(() => _filter = i),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AdminList<QueryDocumentSnapshot>(
                      items: items,
                      advancedCount: _advancedCount,
                      filterKey: (_office, _alsoCashier, _sort),
                      onClearAdvanced: () => setState(() {
                        _office = null;
                        _alsoCashier = null;
                        _sort = 'name';
                      }),
                      advanced: Wrap(
                        spacing: 16,
                        runSpacing: 14,
                        children: [
                          AdminSelect<String>(
                            label: l10n.office,
                            value: _office,
                            options: [
                              (null, l10n.statAll),
                              ('', l10n.noOfficeAssigned),
                              for (final e in officeLabels.entries)
                                (e.key, e.value),
                            ],
                            onChanged: (v) => setState(() => _office = v),
                          ),
                          AdminSelect<bool>(
                            label: l10n.alsoCashier,
                            value: _alsoCashier,
                            options: [
                              (null, l10n.statAll),
                              (true, l10n.filterYes),
                              (false, l10n.filterNo),
                            ],
                            onChanged: (v) => setState(() => _alsoCashier = v),
                          ),
                          AdminSelect<String>(
                            label: l10n.sortBy,
                            value: _sort,
                            options: [
                              ('name', l10n.sortName),
                              ('office', l10n.sortOffice),
                            ],
                            onChanged: (v) =>
                                setState(() => _sort = v ?? 'name'),
                          ),
                        ],
                      ),
                      searchHint: l10n.searchManagersLabel,
                      filters: filters,
                      filter: _filter,
                      onFilter: (i) => setState(() => _filter = i),
                      emptyText: all.isEmpty
                          ? l10n.noManagersYet
                          : l10n.noSearchMatches,
                      matches: (doc, q) {
                        final d = data(doc);
                        return matchesSearch(
                          q,
                          phones: ['${d['phone'] ?? ''}'],
                          texts: [
                            '${d['firstName'] ?? ''}',
                            '${d['lastName'] ?? ''}',
                            '${d['email'] ?? ''}',
                            '${d['phone'] ?? ''}',
                            officeOf(d) ?? '',
                          ],
                        );
                      },
                      rowBuilder: (doc) {
                        final d = data(doc);
                        final email = '${d['email'] ?? ''}';
                        final name = nameOf(d).isEmpty ? email : nameOf(d);
                        final office = officeOf(d);
                        return AdminRow(
                          avatar: AdminAvatar(name: nameOf(d)),
                          title: name,
                          subtitle: email,
                          columns: [
                            '${d['phone'] ?? ''}',
                            office ?? l10n.noOfficeAssigned,
                          ],
                          pill: d['alsoCashier'] == true
                              ? AdminPill(l10n.alsoCashierBadge, AppColors.info)
                              : office == null
                              ? AdminPill(
                                  l10n.noOfficeAssigned,
                                  AppColors.warning,
                                )
                              : null,
                          onTap: () => _editManager(doc, officeDocs),
                          actions: [
                            AdminAction(
                              l10n.edit,
                              Icons.edit_outlined,
                              () => _editManager(doc, officeDocs),
                            ),
                            AdminAction(
                              l10n.deleteAction,
                              Icons.delete_outline,
                              () => _deleteManager(doc, name),
                              danger: true,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
