import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../forms/office_form.dart';
import '../../l10n/locale_controller.dart';
import '../../models/office.dart';
import '../../services/office_listing_service.dart';
import '../../utils/balances.dart';
import '../../utils/currencies.dart';
import '../../theme/app_theme.dart';
import '../../utils/money_format.dart';
import '../../utils/search_match.dart';
import '../../widgets/admin_list.dart';
import '../../widgets/overview_widgets.dart';
import '../../widgets/confirm_delete.dart';
import '../sections/admin_offices_section.dart' show EditOfficeDialog;

/// Admin: skapa kontor och hantera befintliga (ändra, fyll på saldo, radera).
class AdminOfficesPage extends StatefulWidget {
  const AdminOfficesPage({super.key});

  @override
  State<AdminOfficesPage> createState() => _AdminOfficesPageState();
}

class _AdminOfficesPageState extends State<AdminOfficesPage> {
  CollectionReference get officesRef =>
      FirebaseFirestore.instance.collection('offices');

  Future<void> _addOffice({
    required String country,
    required String city,
    required List<String> currencies,
    required List<OfficePaymentMethod> paymentMethods,
  }) async {
    final Map<String, double> balances = {for (final c in currencies) c: 0.0};

    final ref = await officesRef.add({
      'country': country,
      'city': city,
      'currencies': currencies,
      'balances': balances,
      'paymentMethods': paymentMethods.map((m) => m.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Publik post som kunder får läsa (utan saldon och betalningsuppgifter).
    await OfficeListingService.upsert(ref.id, {
      'country': country,
      'city': city,
      'currencies': currencies,
    });
  }

  Future<void> _deleteOffice(String id) async {
    // Koppla loss managers så att de inte pekar på ett borttaget kontor.
    final managers = await FirebaseFirestore.instance
        .collection('users')
        .where('officeId', isEqualTo: id)
        .get();
    for (final doc in managers.docs) {
      await doc.reference.update({'officeId': FieldValue.delete()});
    }

    await officesRef.doc(id).delete();
    await OfficeListingService.remove(id);
  }

  /// Äldre kontor har `createAt`, nyare `createdAt`. Sortering sker här i
  /// stället för i queryn, annars försvinner kontor som saknar det ena fältet.
  DateTime? _officeCreated(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = (data['createdAt'] ?? data['createAt']) as Timestamp?;
    return ts?.toDate();
  }

  Future<void> _topUpOfficeCurrency(
    String officeId,
    String currency,
    double amount,
  ) async {
    await officesRef.doc(officeId).update({
      'balances.$currency': FieldValue.increment(amount),
    });
  }

  /// Fyll på kontorets saldo i en av dess valutor.
  Future<void> _topUp(QueryDocumentSnapshot officeDoc) async {
    final l10n = context.l10n;
    final data = officeDoc.data() as Map<String, dynamic>;
    final currencies = List<String>.from(data['currencies'] ?? []);
    if (currencies.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.officeHasNoCurrencies)));
      return;
    }
    String selectedCurrency = currencies.first;

    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.topUpBalance),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey(selectedCurrency),
                initialValue: selectedCurrency,
                items: currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    selectedCurrency = v;
                  }
                },
                decoration: InputDecoration(labelText: l10n.currency),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.amount),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      final amount = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
      if (amount > 0) {
        await _topUpOfficeCurrency(officeDoc.id, selectedCurrency, amount);
      }
    }
  }

  void _edit(QueryDocumentSnapshot officeDoc) {
    final data = officeDoc.data() as Map<String, dynamic>;
    final currencies = List<String>.from(data['currencies'] ?? []);
    showDialog(
      context: context,
      builder: (ctx) => EditOfficeDialog(
        officeId: officeDoc.id,
        data: data,
        // Kontorets egna valutor + standardvalutor, så att admin kan lägga
        // till nya valutor också.
        availableCurrencies: <String>{
          ...normalizeCurrencies(currencies),
          ...kSupportedCurrencies,
        }.toList(),
      ),
    );
  }

  Future<void> _openAddDialog() => showFormDialog(
    context,
    (ctx, close) => OfficeForm(
      onSubmit:
          ({
            required country,
            required city,
            required currencies,
            required paymentMethods,
          }) async {
            await _addOffice(
              country: country,
              city: city,
              currencies: currencies,
              paymentMethods: paymentMethods,
            );
            close();
          },
    ),
  );

  late final _officeStream = officesRef.snapshots();
  late final _managerStream = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'manager')
      .snapshots();

  /// Valt snabbfilter (index), null = alla.
  int? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageOffices)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _officeStream,
        builder: (context, snapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: _managerStream,
            builder: (context, managerSnap) {
              final error = snapshot.error ?? managerSnap.error;
              if (error != null) {
                return Center(child: Text(l10n.errorWithDetails('$error')));
              }
              if (!snapshot.hasData || !managerSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              // Managers per kontor, sorterade på namn.
              final managersByOffice = <String, List<String>>{};
              for (final m in managerSnap.data!.docs) {
                final d = m.data() as Map<String, dynamic>;
                final officeId = d['officeId']?.toString();
                if (officeId == null) continue;
                final name = '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'
                    .trim();
                managersByOffice
                    .putIfAbsent(officeId, () => [])
                    .add(name.isEmpty ? '${d['email'] ?? ''}' : name);
              }
              for (final l in managersByOffice.values) {
                l.sort();
              }

              final docs = List<QueryDocumentSnapshot>.from(snapshot.data!.docs)
                ..sort((a, b) {
                  final ta = _officeCreated(a);
                  final tb = _officeCreated(b);
                  if (ta == null && tb == null) return 0;
                  if (ta == null) return 1;
                  if (tb == null) return -1;
                  return ta.compareTo(tb);
                });
              Map<String, dynamic> data(QueryDocumentSnapshot d) =>
                  d.data() as Map<String, dynamic>;
              final filters = [
                AdminFilter<QueryDocumentSnapshot>(
                  l10n.filterWithManager,
                  (d) => managersByOffice[d.id]?.isNotEmpty ?? false,
                ),
                AdminFilter<QueryDocumentSnapshot>(
                  l10n.filterWithoutManager,
                  (d) => managersByOffice[d.id]?.isEmpty ?? true,
                ),
              ];
              int count(int i) => docs.where(filters[i].test).length;
              final currencyCount = {
                for (final d in docs)
                  ...List<String>.from(data(d)['currencies'] ?? []),
              }.length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AdminListHeader(
                      summary: l10n.officesSummary(docs.length, count(1)),
                      addLabel: l10n.addOffice,
                      onAdd: _openAddDialog,
                    ),
                    const SizedBox(height: 16),
                    StatRow(
                      stats: [
                        StatData(
                          l10n.statAll,
                          '${docs.length}',
                          AppColors.textPrimary,
                          onTap: () => setState(() => _filter = null),
                        ),
                        StatData(
                          filters[0].label,
                          '${count(0)}',
                          AppColors.primary,
                          onTap: () => setState(() => _filter = 0),
                        ),
                        StatData(
                          filters[1].label,
                          '${count(1)}',
                          AppColors.warning,
                          onTap: () => setState(() => _filter = 1),
                        ),
                        StatData(
                          l10n.currencies,
                          '$currencyCount',
                          AppColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AdminList<QueryDocumentSnapshot>(
                      items: docs,
                      searchHint: l10n.searchOfficesLabel,
                      filters: filters,
                      filter: _filter,
                      onFilter: (i) => setState(() => _filter = i),
                      emptyText: docs.isEmpty
                          ? l10n.noOfficesYet
                          : l10n.noSearchMatches,
                      matches: (d, q) => matchesSearch(
                        q,
                        texts: [
                          '${data(d)['country'] ?? ''}',
                          '${data(d)['city'] ?? ''}',
                          ...List<String>.from(data(d)['currencies'] ?? []),
                          ...?managersByOffice[d.id],
                        ],
                      ),
                      rowBuilder: (d) {
                        final o = data(d);
                        final balances = parseBalances(
                          o['balances'],
                          officeId: d.id,
                        );
                        final balanceText = balances.entries
                            .where((e) => e.value != 0)
                            .map((e) => '${formatMoney(e.value)} ${e.key}')
                            .join(', ');
                        final managers = managersByOffice[d.id] ?? const [];
                        return AdminRow(
                          avatar: const AdminAvatar(icon: Icons.storefront),
                          title: '${o['country'] ?? ''} – ${o['city'] ?? ''}',
                          subtitle: managers.isEmpty
                              ? l10n.managerNone
                              : managers.join(', '),
                          columns: [
                            balanceText.isEmpty ? '0' : balanceText,
                            List<String>.from(o['currencies'] ?? []).join(', '),
                          ],
                          pill: managers.isEmpty
                              ? AdminPill(
                                  l10n.filterWithoutManager,
                                  AppColors.warning,
                                )
                              : null,
                          onTap: () => _edit(d),
                          actions: [
                            AdminAction(
                              l10n.editOffice,
                              Icons.edit_outlined,
                              () => _edit(d),
                            ),
                            AdminAction(
                              l10n.topUpBalance,
                              Icons.add_card,
                              () => _topUp(d),
                            ),
                            AdminAction(
                              l10n.deleteOffice,
                              Icons.delete_outline,
                              () async {
                                final ok = await confirmDelete(
                                  context,
                                  title: l10n.deleteOfficeQuestion,
                                  message: l10n.deleteOfficeConfirm,
                                );
                                if (ok) await _deleteOffice(d.id);
                              },
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
