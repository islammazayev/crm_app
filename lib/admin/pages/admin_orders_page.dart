import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../l10n/app_localizations.dart';
import '../../l10n/locale_controller.dart';
import '../../l10n/status_text.dart';
import '../../models/transaction_model.dart';
import '../../utils/client_id.dart';
import '../../utils/csv.dart';
import '../../utils/search_match.dart';
import '../../utils/transaction_kind.dart';
import '../../utils/transaction_no.dart';
import '../../widgets/confirm_delete.dart';
import '../../theme/app_theme.dart';
import '../../utils/money_format.dart';
import '../../widgets/admin_list.dart';
import '../../widgets/order_report.dart';
import '../../widgets/overview_widgets.dart';
import '../../widgets/phone_field.dart';

/// Admin: orderhistorik med filter på kontor och datum, rapport och export.
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  /// Valt snabbfilter (index i statusfiltren), null = alla.
  int? _filter;

  // Avancerade filter (⚙).
  String? _officeId;
  String? _currency;
  String? _kind; // 'buy', 'sell' eller 'transfer'
  DateTimeRange? _range;
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  String _sort = 'newest';

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.').replaceAll(' ', ''));

  int get _advancedCount => [
    _officeId,
    _currency,
    _kind,
    _range,
    _num(_minCtrl),
    _num(_maxCtrl),
    _showArchived ? true : null,
  ].where((v) => v != null).length;

  void _clearAdvanced() => setState(() {
    _officeId = null;
    _currency = null;
    _kind = null;
    _range = null;
    _minCtrl.clear();
    _maxCtrl.clear();
    _showArchived = false;
    _sort = 'newest';
  });

  late final _officeStream = officesRef.snapshots();
  late final _txStream = transactionsRef.snapshots();

  CollectionReference get officesRef =>
      FirebaseFirestore.instance.collection('offices');
  CollectionReference get transactionsRef =>
      FirebaseFirestore.instance.collection('transactions');

  static const _statuses = [
    'customer_requested',
    'manager_proposed',
    'customer_countered',
    'customer_accepted',
    'customer_paid',
    'payment_confirmed',
    'customer_rejected',
    'completed',
  ];

  /// Admin ändrar kundens namn, telefon och transaktionens status.
  /// Saldon påverkas inte, eftersom bokföringen bara sker när managern
  /// markerar en transaktion som genomförd.
  Future<void> _editTransaction(QueryDocumentSnapshot doc) async {
    final l10n = context.l10n;
    final d = doc.data() as Map<String, dynamic>;
    final nameCtrl = TextEditingController(text: '${d['customerName'] ?? ''}');
    final phoneCtrl = TextEditingController(
      text: '${d['customerPhone'] ?? ''}',
    );
    final oldStatus = '${d['status'] ?? ''}';
    String status = oldStatus;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l10n.editTransactionTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l10n.customerName),
                ),
                const SizedBox(height: 14),
                PhoneField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(labelText: l10n.phone),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _statuses.contains(status) ? status : null,
                  decoration: InputDecoration(labelText: l10n.exportStatus),
                  items: [
                    for (final s in _statuses)
                      DropdownMenuItem(
                        value: s,
                        child: Text(statusText(l10n, s)),
                      ),
                  ],
                  // En genomförd transaktion är bokförd och ska räknas i
                  // vinsten; dess status går inte att ändra (se reglerna).
                  onChanged: oldStatus == 'completed'
                      ? null
                      : (v) => setLocal(() => status = v ?? status),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.statusChangeNoBalance,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
          'customerName': nameCtrl.text.trim(),
          'customerPhone': phoneCtrl.text.trim(),
          if (status != oldStatus) 'status': status,
          'updatedByAdminAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.transactionUpdated)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.errorWithDetails('$e'))));
        }
      }
    }
    nameCtrl.dispose();
    phoneCtrl.dispose();
  }

  bool _showArchived = false;

  static bool _isArchived(QueryDocumentSnapshot d) =>
      (d.data() as Map<String, dynamic>)['archived'] == true;

  /// Genomförda transaktioner är bokförda affärer: de arkiveras (döljs men
  /// räknas i vinst och export) och kan inte raderas (se reglerna).
  /// Övriga, t.ex. testförfrågningar, raderas.
  Future<void> _deleteOrArchive(QueryDocumentSnapshot doc) async {
    final l10n = context.l10n;
    final completed =
        (doc.data() as Map<String, dynamic>)['status'] == 'completed';
    if (completed) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.archiveTransactionTitle),
          content: Text(l10n.archiveTransactionConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.archiveAction),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await doc.reference.update({
        'archived': true,
        'archivedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.transactionArchived)));
      return;
    }
    final ok = await confirmDelete(
      context,
      title: l10n.deleteTransactionTitle,
      message: l10n.deleteTransactionConfirm,
    );
    if (ok) await _deleteTransaction(doc.id);
  }

  Future<void> _restore(QueryDocumentSnapshot doc) async {
    await doc.reference.update({
      'archived': FieldValue.delete(),
      'archivedAt': FieldValue.delete(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.transactionRestored)));
  }

  Future<void> _deleteTransaction(String id) async {
    await transactionsRef.doc(id).delete();
  }

  static List<String> _exportHeader(AppLocalizations l10n) => <String>[
    l10n.exportNo,
    l10n.exportDate,
    l10n.exportStatus,
    l10n.exportClientId,
    l10n.exportOffice,
    l10n.exportFrom,
    l10n.exportTo,
    l10n.exportAmount,
    l10n.exportFee,
    l10n.exportPayout,
  ];

  /// Hämtar alla transaktioner (senaste först) som rader för CSV/PDF.
  /// Läser det nuvarande schemat (createAt, fromCurrency, amountFrom ...) och
  /// faller tillbaka på de äldre fälten (date, currency, amount, fee).
  /// Sorteringen sker här, inte i queryn, eftersom orderBy utelämnar
  /// dokument som saknar fältet.
  Future<List<List<String>>> _loadExportRows(AppLocalizations l10n) async {
    final query = await transactionsRef.get();

    DateTime? dateOf(Map<String, dynamic> data) {
      final ts =
          (data['createAt'] ?? data['completedAt'] ?? data['date'])
              as Timestamp?;
      return ts?.toDate();
    }

    final entries =
        query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList()
          ..sort((a, b) {
            final da = dateOf(a);
            final dbb = dateOf(b);
            if (da == null && dbb == null) return 0;
            if (da == null) return 1;
            if (dbb == null) return -1;
            return dbb.compareTo(da); // senaste först
          });

    return entries.map((data) {
      return <String>[
        formatTransactionNo(data['transactionNo']),
        dateOf(data)?.toIso8601String() ?? '',
        [
          statusText(l10n, (data['status'] ?? '').toString()),
          if (data['archived'] == true) l10n.archivedBadge,
        ].join(' · '),
        (data['clientId'] ?? '').toString(),
        (data['officeId'] ?? '').toString(),
        (data['fromCurrency'] ?? data['currency'] ?? '').toString(),
        (data['toCurrency'] ?? '').toString(),
        (data['amountFrom'] ?? data['amount'] ?? 0).toString(),
        (data['feeAmountFrom'] ?? data['fee'] ?? 0).toString(),
        (data['amountToNet'] ?? '').toString(),
      ];
    }).toList();
  }

  Future<void> _exportToCSV() async {
    final l10n = context.l10n;
    final rows = await _loadExportRows(l10n);

    if (rows.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noTransactionsToExport)));
      return;
    }

    // UTF-8 med BOM så att Excel visar å, ä, ö, kyrilliska och turkiska rätt.
    final csv = toCsv([_exportHeader(l10n), ...rows]);
    final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);
    final name =
        'orderrapport_${DateTime.now().toIso8601String().split('T').first}';
    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: name,
        bytes: bytes,
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
    } else {
      await FileSaver.instance.saveAs(
        name: name,
        bytes: bytes,
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
    }
  }

  Future<void> _exportToPDF() async {
    final l10n = context.l10n;
    final rows = await _loadExportRows(l10n);

    if (rows.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noTransactionsToExport)));
      return;
    }

    // Standardtypsnittet i pdf saknar kyrilliska och turkiska tecken.
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(
          await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
        ),
        bold: pw.Font.ttf(
          await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
        ),
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Text(l10n.orderReport, style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              children: [
                pw.TableRow(
                  children: _exportHeader(l10n)
                      .map(
                        (h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            h,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                ...rows.map((cells) {
                  return pw.TableRow(
                    children: cells
                        .map(
                          (c) => pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              c,
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    final Uint8List bytes = await pdf.save();

    // Webben laddar ner filen direkt, övriga plattformar visar en spara-dialog.
    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: 'orderrapport',
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
    } else {
      await FileSaver.instance.saveAs(
        name: 'orderrapport',
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
    }
  }

  static DateTime? _dateOf(Map<String, dynamic> data) =>
      (data['createAt'] as Timestamp? ??
              data['completedAt'] as Timestamp? ??
              data['date'] as Timestamp?)
          ?.toDate();

  static String _kindOf(Map<String, dynamic> data) => isBuyTransaction(data)
      ? 'buy'
      : isSellTransaction(data)
      ? 'sell'
      : 'transfer';

  static bool _isOpen(String status) =>
      status != 'completed' && status != 'customer_rejected';

  /// Bygger TransactionModel för rapporten. Läser det nuvarande schemat
  /// (kundens förfrågningar) och faller tillbaka på äldre fält.
  TransactionModel _toModel(AppLocalizations l10n, QueryDocumentSnapshot d) {
    final data = d.data() as Map<String, dynamic>;
    return TransactionModel(
      sender: '${data['customerName'] ?? data['sender'] ?? ''}',
      receiver: (data['receiver'] ?? '').toString(),
      currency: (data['fromCurrency'] ?? data['currency'] ?? '').toString(),
      amount: _toDouble(data['amountFrom'] ?? data['amount']),
      fee: _toDouble(data['feeAmountFrom'] ?? data['fee']),
      country: (data['country'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      date: _dateOf(data) ?? DateTime.now(),
      status: (data['status'] ?? '').toString(),
      label: formatTransactionNo(data['transactionNo']),
      toCurrency: (data['toCurrency'] ?? '').toString(),
      archived: _isArchived(d),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderHistory)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _officeStream,
        builder: (context, offSnap) => StreamBuilder<QuerySnapshot>(
          stream: _txStream,
          builder: (context, snapshot) {
            final error = offSnap.error ?? snapshot.error;
            if (error != null) {
              return Center(child: Text(l10n.errorWithDetails('$error')));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return _content(
              snapshot.data!.docs,
              offSnap.data?.docs ?? const [],
            );
          },
        ),
      ),
    );
  }

  Widget _content(
    List<QueryDocumentSnapshot> txDocs,
    List<QueryDocumentSnapshot> officeDocs,
  ) {
    final l10n = context.l10n;
    Map<String, dynamic> data(QueryDocumentSnapshot d) =>
        d.data() as Map<String, dynamic>;
    final officeLabels = {
      for (final o in officeDocs)
        o.id: '${data(o)['country'] ?? ''} – ${data(o)['city'] ?? ''}',
    };
    String status(QueryDocumentSnapshot d) => '${data(d)['status'] ?? ''}';

    final now = DateTime.now();
    final today = DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day),
    );
    final active = txDocs.where((d) => !_isArchived(d)).toList();
    final archived = txDocs.length - active.length;
    final filters = [
      AdminFilter<QueryDocumentSnapshot>(
        l10n.filterOngoing,
        (d) => _isOpen(status(d)),
      ),
      AdminFilter<QueryDocumentSnapshot>(
        l10n.filterCompleted,
        (d) => status(d) == 'completed',
      ),
      AdminFilter<QueryDocumentSnapshot>(
        l10n.filterRejected,
        (d) => status(d) == 'customer_rejected',
      ),
    ];
    final currencies = {
      for (final d in txDocs) ...[
        '${data(d)['fromCurrency'] ?? data(d)['currency'] ?? ''}',
        '${data(d)['toCurrency'] ?? ''}',
      ],
    }.where((c) => c.isNotEmpty).toList()..sort();

    final min = _num(_minCtrl);
    final max = _num(_maxCtrl);
    final items = txDocs.where((d) {
      final t = data(d);
      if (!_showArchived && _isArchived(d)) return false;
      if (_officeId != null && '${t['officeId'] ?? ''}' != _officeId) {
        return false;
      }
      if (_currency != null &&
          '${t['fromCurrency'] ?? t['currency'] ?? ''}' != _currency &&
          '${t['toCurrency'] ?? ''}' != _currency) {
        return false;
      }
      if (_kind != null && _kindOf(t) != _kind) return false;
      if (!inDateRange(_dateOf(t), _range)) return false;
      final amount = _toDouble(t['amountFrom'] ?? t['amount']);
      if (min != null && amount < min) return false;
      if (max != null && amount > max) return false;
      return true;
    }).toList();
    final epoch = DateTime(2000);
    switch (_sort) {
      case 'oldest':
        items.sort(
          (a, b) =>
              (_dateOf(data(a)) ?? epoch).compareTo(_dateOf(data(b)) ?? epoch),
        );
      case 'amount':
        items.sort(
          (a, b) => _toDouble(
            data(b)['amountFrom'] ?? data(b)['amount'],
          ).compareTo(_toDouble(data(a)['amountFrom'] ?? data(a)['amount'])),
        );
      default:
        items.sort(
          (a, b) =>
              (_dateOf(data(b)) ?? epoch).compareTo(_dateOf(data(a)) ?? epoch),
        );
    }

    Widget amountField(TextEditingController c, String hint) => Expanded(
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(hintText: hint, isDense: true),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                l10n.ordersSummary(active.length, archived),
                style: TextStyle(color: AppColors.textMuted),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _exportToCSV,
                    icon: const Icon(Icons.table_chart_outlined),
                    label: Text(l10n.exportCsv),
                  ),
                  OutlinedButton.icon(
                    onPressed: _exportToPDF,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(l10n.exportPdf),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          StatRow(
            stats: [
              StatData(
                l10n.filterToday,
                '${active.where((d) => inDateRange(_dateOf(data(d)), today)).length}',
                AppColors.textPrimary,
                onTap: () => setState(() {
                  _filter = null;
                  _range = today;
                }),
              ),
              StatData(
                filters[0].label,
                '${active.where(filters[0].test).length}',
                AppColors.warning,
                onTap: () => setState(() => _filter = 0),
              ),
              StatData(
                filters[1].label,
                '${active.where(filters[1].test).length}',
                AppColors.success,
                onTap: () => setState(() => _filter = 1),
              ),
              StatData(
                l10n.filterArchived,
                '$archived',
                AppColors.textMuted,
                onTap: () => setState(() => _showArchived = true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdminList<QueryDocumentSnapshot>(
            items: items,
            searchHint: l10n.searchTransactionsHint,
            filters: filters,
            filter: _filter,
            onFilter: (i) => setState(() => _filter = i),
            emptyText: l10n.noSearchMatches,
            advancedCount: _advancedCount,
            filterKey: (
              _officeId,
              _currency,
              _kind,
              _range,
              min,
              max,
              _showArchived,
              _sort,
            ),
            onClearAdvanced: _clearAdvanced,
            advanced: Wrap(
              spacing: 16,
              runSpacing: 14,
              children: [
                AdminSelect<String>(
                  label: l10n.office,
                  value: _officeId,
                  options: [
                    (null, l10n.allOffices),
                    for (final e in officeLabels.entries) (e.key, e.value),
                  ],
                  onChanged: (v) => setState(() => _officeId = v),
                ),
                AdminSelect<String>(
                  label: l10n.currency,
                  value: _currency,
                  options: [
                    (null, l10n.statAll),
                    for (final c in currencies) (c, c),
                  ],
                  onChanged: (v) => setState(() => _currency = v),
                ),
                AdminSelect<String>(
                  label: l10n.filterKind,
                  value: _kind,
                  options: [
                    (null, l10n.statAll),
                    ('buy', l10n.kindBuy),
                    ('sell', l10n.kindSell),
                    ('transfer', l10n.kindTransfer),
                  ],
                  onChanged: (v) => setState(() => _kind = v),
                ),
                AdminDateRange(
                  label: l10n.filterDate,
                  range: _range,
                  onChanged: (r) => setState(() => _range = r),
                ),
                AdminFilterField(
                  l10n.filterAmount,
                  Row(
                    children: [
                      amountField(_minCtrl, l10n.filterFrom),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('–'),
                      ),
                      amountField(_maxCtrl, l10n.filterTo),
                    ],
                  ),
                ),
                AdminSelect<String>(
                  label: l10n.sortBy,
                  value: _sort,
                  options: [
                    ('newest', l10n.sortNewest),
                    ('oldest', l10n.sortOldest),
                    ('amount', l10n.sortAmount),
                  ],
                  onChanged: (v) => setState(() => _sort = v ?? 'newest'),
                ),
                AdminFilterField(
                  l10n.filterArchived,
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(l10n.showArchivedShort),
                    value: _showArchived,
                    onChanged: (v) => setState(() => _showArchived = v),
                  ),
                ),
              ],
            ),
            matches: (d, q) {
              final t = data(d);
              final phone = '${t['customerPhone'] ?? ''}';
              return matchesSearch(
                q,
                ids: [
                  formatClientId(t['clientId']),
                  '${t['clientId'] ?? ''}',
                  '${t['transactionNo'] ?? ''}',
                  '${t['pickupCode'] ?? ''}'.replaceAll('-', ''),
                  formatTransactionNo(
                    t['transactionNo'],
                  ).replaceFirst('T-', ''),
                ],
                phones: [phone],
                texts: [
                  formatTransactionNo(t['transactionNo']),
                  '${t['pickupCode'] ?? ''}',
                  '${t['customerName'] ?? t['sender'] ?? ''}',
                  phone,
                  officeLabels['${t['officeId']}'] ?? '',
                  '${t['fromCurrency'] ?? t['currency'] ?? ''}',
                  '${t['toCurrency'] ?? ''}',
                  statusText(l10n, '${t['status'] ?? ''}'),
                ],
              );
            },
            rowBuilder: (d) => _row(d, officeLabels),
            footer: (results) => ExpansionTile(
              leading: const Icon(Icons.insights_outlined),
              title: Text(l10n.reportTitle),
              children: [
                OrderReport(
                  transactions: results.map((r) => _toModel(l10n, r)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// En transaktion i listan.
  Widget _row(QueryDocumentSnapshot d, Map<String, String> officeLabels) {
    final l10n = context.l10n;
    final t = d.data() as Map<String, dynamic>;
    final status = '${t['status'] ?? ''}';
    final no = formatTransactionNo(t['transactionNo']);
    final name = '${t['customerName'] ?? t['sender'] ?? ''}'.trim();
    final clientId = formatClientId(t['clientId']);
    final at = _dateOf(t);
    final from = '${t['fromCurrency'] ?? t['currency'] ?? ''}';
    final to = '${t['toCurrency'] ?? ''}';
    final amount = _toDouble(t['amountFrom'] ?? t['amount']);
    final kind = _kindOf(t);
    final archived = _isArchived(d);
    return AdminRow(
      avatar: AdminAvatar(
        icon: switch (kind) {
          'buy' => Icons.south_west,
          'sell' => Icons.north_east,
          _ => Icons.swap_horiz,
        },
      ),
      title: [
        if (no.isNotEmpty) no,
        if (name.isNotEmpty)
          name
        else if (clientId.isNotEmpty)
          l10n.clientShort(clientId),
      ].join(' · '),
      subtitle: [
        if (at != null) formatDateTime(context, at),
        if (officeLabels['${t['officeId']}'] != null)
          officeLabels['${t['officeId']}']!,
      ].join(' · '),
      columns: [
        '${formatMoney(amount)} $from${to.isEmpty ? '' : ' → $to'}',
        if (isBuyTransaction(t) || isSellTransaction(t))
          transactionSummary(l10n, t)
        else
          clientId.isEmpty ? '' : l10n.clientShort(clientId),
      ],
      pill: archived
          ? AdminPill(l10n.filterArchived, AppColors.textMuted)
          : AdminPill(statusText(l10n, status), statusColor(status)),
      onTap: () => _editTransaction(d),
      actions: [
        AdminAction(l10n.edit, Icons.edit_outlined, () => _editTransaction(d)),
        if (archived)
          AdminAction(
            l10n.restoreAction,
            Icons.unarchive_outlined,
            () => _restore(d),
          )
        else
          AdminAction(
            status == 'completed' ? l10n.archiveAction : l10n.deleteAction,
            status == 'completed'
                ? Icons.archive_outlined
                : Icons.delete_outline,
            () => _deleteOrArchive(d),
            danger: status != 'completed',
          ),
      ],
    );
  }
}

/// Läser ett tal ur Firestore-data. Tal används som de är, text som ser ut som
/// ett tal omvandlas och allt annat blir 0 (så att rapporten aldrig kraschar).
double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  return 0;
}
