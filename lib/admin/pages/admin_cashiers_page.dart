import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../cashier/pages/cashier_overview_page.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/auth_error_text.dart';
import '../../l10n/locale_controller.dart';
import '../../services/account_creator.dart';
import '../../services/cashier_service.dart';
import '../../services/partner_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import '../../utils/currencies.dart';
import '../../utils/merged_query.dart';
import '../../utils/search_match.dart';
import '../../widgets/confirm_delete.dart';
import '../../widgets/partner_exchanges.dart';
import '../../widgets/search_summary.dart';

/// Kassörer och partner skapas, kopplas och får saldo på samma sätt.
enum StaffType { cashier, partner }

/// Texterna som skiljer sig mellan kassörer och partner.
class _StaffTexts {
  final String title;
  final String editTitle;
  final String updated;
  final String deleteTitle;
  final String Function(String name) deleteConfirm;
  final String deleted;
  final String existing;
  final String searchLabel;
  final String createNew;
  final String create;
  final String created;
  final String Function(String error) couldNotCreate;

  const _StaffTexts({
    required this.title,
    required this.editTitle,
    required this.updated,
    required this.deleteTitle,
    required this.deleteConfirm,
    required this.deleted,
    required this.existing,
    required this.searchLabel,
    required this.createNew,
    required this.create,
    required this.created,
    required this.couldNotCreate,
  });

  factory _StaffTexts.of(StaffType type, AppLocalizations l10n) =>
      type == StaffType.cashier
      ? _StaffTexts(
          title: l10n.cashiers,
          editTitle: l10n.editCashierTitle,
          updated: l10n.cashierUpdated,
          deleteTitle: l10n.deleteCashierTitle,
          deleteConfirm: l10n.deleteCashierConfirm,
          deleted: l10n.cashierDeleted,
          existing: l10n.existingCashiers,
          searchLabel: l10n.searchCashiersLabel,
          createNew: l10n.createNewCashier,
          create: l10n.createCashier,
          created: l10n.cashierCreated,
          couldNotCreate: l10n.couldNotCreateCashier,
        )
      : _StaffTexts(
          title: l10n.partners,
          editTitle: l10n.editPartnerTitle,
          updated: l10n.partnerUpdated,
          deleteTitle: l10n.deletePartnerTitle,
          deleteConfirm: l10n.deletePartnerConfirm,
          deleted: l10n.partnerDeleted,
          existing: l10n.existingPartners,
          searchLabel: l10n.searchPartnersLabel,
          createNew: l10n.createNewPartner,
          create: l10n.createPartner,
          created: l10n.partnerCreated,
          couldNotCreate: l10n.couldNotCreatePartner,
        );
}

/// Kontor och managers att koppla kassörer och partner till.
class _Links {
  final Map<String, String> offices; // id → "Land – Stad"
  final Map<String, String> managers; // uid → namn
  final Map<String, String> managerOffices; // uid → managerns kontor
  const _Links(this.offices, this.managers, this.managerOffices);
}

/// Admin: skapa kassörer (eller partner), koppla dem till kontor
/// och/eller manager, fyll på saldo, ta bort och se deras överföringar
/// (eller växlingar).
class AdminCashiersPage extends StatefulWidget {
  final StaffType type;

  const AdminCashiersPage({super.key, this.type = StaffType.cashier});

  @override
  State<AdminCashiersPage> createState() => _AdminCashiersPageState();
}

class _AdminCashiersPageState extends State<AdminCashiersPage> {
  final _db = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  String _query = '';

  bool get _isPartner => widget.type == StaffType.partner;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection(_isPartner ? 'partners' : 'cashiers');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Kontor och managers, uppdateras när någon av listorna ändras.
  Stream<_Links> _links() {
    late final StreamController<_Links> controller;
    QuerySnapshot<Map<String, dynamic>>? offices;
    QuerySnapshot<Map<String, dynamic>>? managers;
    final subs = <StreamSubscription>[];

    void emit() {
      if (offices == null || managers == null) return;
      controller.add(
        _Links(
          {
            for (final d in offices!.docs)
              d.id: '${d.data()['country'] ?? ''} – ${d.data()['city'] ?? ''}',
          },
          {
            for (final d in managers!.docs)
              d.id:
                  '${d.data()['firstName'] ?? ''} ${d.data()['lastName'] ?? ''}'
                      .trim(),
          },
          {
            for (final d in managers!.docs)
              if (d.data()['officeId'] != null) d.id: '${d.data()['officeId']}',
          },
        ),
      );
    }

    controller = StreamController<_Links>(
      onListen: () {
        subs.add(
          _db.collection('offices').snapshots().listen((s) {
            offices = s;
            emit();
          }, onError: controller.addError),
        );
        subs.add(
          _db
              .collection('users')
              .where('role', isEqualTo: 'manager')
              .snapshots()
              .listen((s) {
                managers = s;
                emit();
              }, onError: controller.addError),
        );
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );
    return controller.stream;
  }

  late final Stream<_Links> _linksStream = _links();

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Skriver koppling och namn till både den privata posten och katalogen.
  Future<void> _saveLinks({
    required String uid,
    required String firstName,
    required String lastName,
    required String phone,
    required String? officeId,
    required String? managerId,
    required _Links links,
  }) async {
    final name = '$firstName $lastName'.trim();
    final batch = _db.batch();
    batch.update(_db.collection('users').doc(uid), {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    });
    if (_isPartner) {
      // Växlingarna går mot det kopplade kontoret, annars mot den kopplade
      // managerns kontor.
      final exchangeOfficeId =
          officeId ??
          (managerId == null ? null : links.managerOffices[managerId]);
      batch.update(PartnerService.partner(uid), {
        'firstName': firstName,
        'lastName': lastName,
        'officeId': officeId ?? FieldValue.delete(),
        'managerId': managerId ?? FieldValue.delete(),
        'exchangeOfficeId': exchangeOfficeId ?? FieldValue.delete(),
        'exchangeOfficeLabel': exchangeOfficeId == null
            ? FieldValue.delete()
            : (links.offices[exchangeOfficeId] ?? ''),
      });
      await batch.commit();
      return;
    }
    // Kassören bekräftar kontanta inbetalningar på det kopplade kontoret,
    // annars på den kopplade managerns kontor.
    final cashOfficeId =
        officeId ??
        (managerId == null ? null : links.managerOffices[managerId]);
    batch.update(CashierService.cashier(uid), {
      'cashOfficeId': cashOfficeId ?? FieldValue.delete(),
      'firstName': firstName,
      'lastName': lastName,
      'officeId': officeId ?? FieldValue.delete(),
      'managerId': managerId ?? FieldValue.delete(),
    });
    batch.set(CashierService.directory(uid), {
      'name': name,
      'officeId': officeId,
      'officeLabel': officeId == null ? '' : (links.offices[officeId] ?? ''),
      'managerId': managerId,
      'managerName': managerId == null ? '' : (links.managers[managerId] ?? ''),
    });
    await batch.commit();
  }

  Future<void> _edit(
    DocumentSnapshot<Map<String, dynamic>> doc,
    _Links links,
  ) async {
    final l10n = context.l10n;
    final d = doc.data() ?? const {};
    final user = await _db.collection('users').doc(doc.id).get();
    final firstCtrl = TextEditingController(text: '${d['firstName'] ?? ''}');
    final lastCtrl = TextEditingController(text: '${d['lastName'] ?? ''}');
    final phoneCtrl = TextEditingController(
      text: '${user.data()?['phone'] ?? ''}',
    );
    String? officeId = d['officeId'] as String?;
    String? managerId = d['managerId'] as String?;
    if (!links.offices.containsKey(officeId)) officeId = null;
    if (!links.managers.containsKey(managerId)) managerId = null;
    if (!mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(_StaffTexts.of(widget.type, l10n).editTitle),
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
                  decoration: InputDecoration(labelText: l10n.phone),
                ),
                const SizedBox(height: 14),
                _LinkDropdowns(
                  links: links,
                  officeId: officeId,
                  managerId: managerId,
                  onOffice: (v) => setLocal(() => officeId = v),
                  onManager: (v) => setLocal(() => managerId = v),
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
    if (ok == true) {
      try {
        await _saveLinks(
          uid: doc.id,
          firstName: firstCtrl.text.trim(),
          lastName: lastCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          officeId: officeId,
          managerId: managerId,
          links: links,
        );
        _snack(_StaffTexts.of(widget.type, l10n).updated);
      } catch (e) {
        _snack(l10n.errorWithDetails('$e'));
      }
    }
    firstCtrl.dispose();
    lastCtrl.dispose();
    phoneCtrl.dispose();
  }

  /// Fyll på (eller dra av, med minus) saldo i en valuta.
  Future<void> _adjust(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final l10n = context.l10n;
    final balances = parseBalances(doc.data()?['balances'], officeId: doc.id);
    String currency = kSupportedCurrencies.first;
    final amountCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l10n.adjustBalance),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: currency,
                decoration: InputDecoration(labelText: l10n.currency),
                items: [
                  for (final c in kSupportedCurrencies)
                    DropdownMenuItem(
                      value: c,
                      child: Text(
                        '$c  (${(balances[c] ?? 0).toStringAsFixed(2)})',
                      ),
                    ),
                ],
                onChanged: (v) => setLocal(() => currency = v ?? currency),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  helperText: l10n.adjustBalanceHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.ok),
            ),
          ],
        ),
      ),
    );
    final amount =
        double.tryParse(amountCtrl.text.trim().replaceAll(',', '.')) ?? 0;
    amountCtrl.dispose();
    if (ok != true || amount == 0) return;
    if ((balances[currency] ?? 0) + amount < 0) {
      _snack(l10n.balanceWouldBeNegative);
      return;
    }
    try {
      await doc.reference.update({
        'balances.$currency': FieldValue.increment(amount),
      });
      _snack(l10n.balanceUpdated);
    } catch (e) {
      _snack(l10n.errorWithDetails('$e'));
    }
  }

  /// Tar bort kassörens profil, saldo och katalogpost. Inloggningskontot
  /// finns kvar och tas bort i Firebase-konsolen (Authentication).
  Future<void> _delete(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String name,
  ) async {
    final l10n = context.l10n;
    final texts = _StaffTexts.of(widget.type, l10n);
    final ok = await confirmDelete(
      context,
      title: texts.deleteTitle,
      message: texts.deleteConfirm(name),
    );
    if (!ok) return;
    try {
      final batch = _db.batch();
      batch.delete(_db.collection('users').doc(doc.id));
      batch.delete(doc.reference);
      if (!_isPartner) batch.delete(CashierService.directory(doc.id));
      await batch.commit();
      _snack(texts.deleted);
    } catch (e) {
      _snack(l10n.errorWithDetails('$e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final texts = _StaffTexts.of(widget.type, l10n);
    return Scaffold(
      appBar: AppBar(title: Text(texts.title)),
      body: StreamBuilder<_Links>(
        stream: _linksStream,
        builder: (context, linkSnap) {
          if (linkSnap.hasError) {
            return Center(
              child: Text(l10n.errorWithDetails('${linkSnap.error}')),
            );
          }
          if (!linkSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final links = linkSnap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CreateCashierForm(
                  type: widget.type,
                  links: links,
                  saveLinks: _saveLinks,
                ),
                const SizedBox(height: 32),
                Text(
                  texts.existing,
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
                    labelText: texts.searchLabel,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _collection.snapshots(),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Text(l10n.errorWithDetails('${snap.error}'));
                    }
                    if (!snap.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final all = snap.data!.docs;
                    String nameOf(Map<String, dynamic> d) =>
                        '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
                    final empty = isEmptySearch(_query);
                    final matches = empty
                        ? <QueryDocumentSnapshot<Map<String, dynamic>>>[]
                        : all.where((doc) {
                            final d = doc.data();
                            return matchesSearch(
                              _query,
                              texts: [
                                nameOf(d),
                                links.offices[d['officeId']] ?? '',
                                links.managers[d['managerId']] ?? '',
                              ],
                            );
                          }).toList();
                    final shown = matches.take(maxSearchResults).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SearchSummary(
                          empty: empty,
                          total: all.length,
                          matches: matches.length,
                          shown: shown.length,
                        ),
                        for (final doc in shown)
                          _CashierTile(
                            icon: _isPartner
                                ? Icons.handshake_outlined
                                : Icons.point_of_sale,
                            doc: doc,
                            name: nameOf(doc.data()),
                            office: links.offices[doc.data()['officeId']] ?? '',
                            manager:
                                links.managers[doc.data()['managerId']] ?? '',
                            onOpen: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _isPartner
                                    ? _PartnerExchangesPage(
                                        partnerId: doc.id,
                                        name: nameOf(doc.data()),
                                      )
                                    : CashierOverviewPage(
                                        cashierId: doc.id,
                                        name: nameOf(doc.data()),
                                        transfers: mergedQuery([
                                          CashierService.transfers.where(
                                            'fromId',
                                            isEqualTo: doc.id,
                                          ),
                                          CashierService.transfers.where(
                                            'toId',
                                            isEqualTo: doc.id,
                                          ),
                                        ]),
                                      ),
                              ),
                            ),
                            onEdit: () => _edit(doc, links),
                            onAdjust: () => _adjust(doc),
                            onDelete: () => _delete(doc, nameOf(doc.data())),
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

/// Admin: alla växlingar för en partner (bara läsa).
class _PartnerExchangesPage extends StatelessWidget {
  final String partnerId;
  final String name;

  const _PartnerExchangesPage({required this.partnerId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PartnerExchangeList(
            stream: PartnerService.exchangesForPartner(partnerId),
            side: null,
          ),
        ],
      ),
    );
  }
}

class _CashierTile extends StatelessWidget {
  final IconData icon;
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final String name;
  final String office;
  final String manager;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onAdjust;
  final VoidCallback onDelete;

  const _CashierTile({
    required this.icon,
    required this.doc,
    required this.name,
    required this.office,
    required this.manager,
    required this.onOpen,
    required this.onEdit,
    required this.onAdjust,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final balances = parseBalances(doc.data()['balances'], officeId: doc.id);
    final balanceText = balances.entries
        .where((e) => e.value != 0)
        .map((e) => '${e.value.toStringAsFixed(2)} ${e.key}')
        .join(', ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onOpen,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(name),
        subtitle: Text(
          [
            l10n.officeValue(office.isEmpty ? l10n.noOfficeAssigned : office),
            l10n.managerValue(manager.isEmpty ? '–' : manager),
            l10n.balanceValue(balanceText.isEmpty ? '0' : balanceText),
          ].join('\n'),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.edit,
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: l10n.adjustBalance,
              icon: const Icon(Icons.add_card),
              onPressed: onAdjust,
            ),
            IconButton(
              tooltip: l10n.deleteAction,
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// Val av kontor och manager; båda kan lämnas tomma.
class _LinkDropdowns extends StatelessWidget {
  final _Links links;
  final String? officeId;
  final String? managerId;
  final ValueChanged<String?> onOffice;
  final ValueChanged<String?> onManager;

  const _LinkDropdowns({
    required this.links,
    required this.officeId,
    required this.managerId,
    required this.onOffice,
    required this.onManager,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        DropdownButtonFormField<String?>(
          initialValue: officeId,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.officeOptional),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(l10n.noOfficeAssigned),
            ),
            for (final e in links.offices.entries)
              DropdownMenuItem<String?>(value: e.key, child: Text(e.value)),
          ],
          onChanged: onOffice,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String?>(
          initialValue: managerId,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.managerOptional),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(l10n.noManagerAssigned),
            ),
            for (final e in links.managers.entries)
              DropdownMenuItem<String?>(
                value: e.key,
                child: Text(e.value.isEmpty ? e.key : e.value),
              ),
          ],
          onChanged: onManager,
        ),
      ],
    );
  }
}

class _CreateCashierForm extends StatefulWidget {
  final StaffType type;
  final _Links links;
  final Future<void> Function({
    required String uid,
    required String firstName,
    required String lastName,
    required String phone,
    required String? officeId,
    required String? managerId,
    required _Links links,
  })
  saveLinks;

  const _CreateCashierForm({
    required this.type,
    required this.links,
    required this.saveLinks,
  });

  @override
  State<_CreateCashierForm> createState() => _CreateCashierFormState();
}

class _CreateCashierFormState extends State<_CreateCashierForm> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  String? _officeId;
  String? _managerId;
  bool _creating = false;

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    final texts = _StaffTexts.of(widget.type, l10n);
    final isPartner = widget.type == StaffType.partner;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _creating = true);
    final db = FirebaseFirestore.instance;
    try {
      await createAccountAsAdmin(
        email: _email.text.trim(),
        password: _password.text.trim(),
        writeProfile: (uid) async {
          final batch = db.batch();
          batch.set(db.collection('users').doc(uid), {
            'email': _email.text.trim(),
            'role': widget.type.name,
            'firstName': _first.text.trim(),
            'lastName': _last.text.trim(),
            'phone': _phone.text.trim(),
            'createAt': FieldValue.serverTimestamp(),
          });
          batch.set(
            isPartner
                ? PartnerService.partner(uid)
                : CashierService.cashier(uid),
            {
              'firstName': _first.text.trim(),
              'lastName': _last.text.trim(),
              'balances': <String, double>{},
              'createdAt': FieldValue.serverTimestamp(),
            },
          );
          await batch.commit();
          await widget.saveLinks(
            uid: uid,
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            phone: _phone.text.trim(),
            officeId: _officeId,
            managerId: _managerId,
            links: widget.links,
          );
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(texts.created)));
      _formKey.currentState!.reset();
      for (final c in [_first, _last, _email, _phone, _password]) {
        c.clear();
      }
      setState(() {
        _officeId = null;
        _managerId = null;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texts.couldNotCreate(authErrorText(l10n, e)))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.unexpectedError('$e'))));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final texts = _StaffTexts.of(widget.type, l10n);
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.requiredField : null;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts.createNew,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _first,
                  decoration: InputDecoration(labelText: l10n.firstName),
                  validator: required,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _last,
                  decoration: InputDecoration(labelText: l10n.lastName),
                  validator: required,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.email),
            validator: required,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.phone),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.password),
            validator: (v) =>
                (v == null || v.length < 6) ? l10n.passwordMinLength : null,
          ),
          const SizedBox(height: 14),
          _LinkDropdowns(
            links: widget.links,
            officeId: _officeId,
            managerId: _managerId,
            onOffice: (v) => setState(() => _officeId = v),
            onManager: (v) => setState(() => _managerId = v),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _creating ? null : _create,
            icon: _creating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_add),
            label: Text(texts.create),
          ),
        ],
      ),
    );
  }
}
