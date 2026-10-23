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
import '../../lists/order_history_list.dart';
import '../../models/transaction_model.dart';
import '../../utils/client_id.dart';
import '../../utils/csv.dart';
import '../../utils/search_match.dart';
import '../../utils/transaction_no.dart';
import '../../widgets/confirm_delete.dart';
import '../../widgets/order_report.dart';
import '../../widgets/search_summary.dart';

/// Admin: orderhistorik med filter på kontor och datum, rapport och export.
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  DateTimeRange? _selectedRange;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? _selectedOfficeId; // null = alla kontor

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
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.phone),
                ),
                const SizedBox(height: 8),
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
                  onChanged: (v) => setLocal(() => status = v ?? status),
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
        statusText(l10n, (data['status'] ?? '').toString()),
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
    final name = 'orderrapport_${DateTime.now().toIso8601String().split('T').first}';
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderHistory)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                labelText: l10n.searchTransactionsLabel,
                hintText: l10n.searchTransactionsHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),

            // Office-filter
            StreamBuilder<QuerySnapshot>(
              stream: officesRef.snapshots(),
              builder: (context, offSnap) {
                final officeDocs = offSnap.hasData
                    ? offSnap.data!.docs
                    : <QueryDocumentSnapshot>[];

                return DropdownButtonFormField<String?>(
                  key: ValueKey(_selectedOfficeId),
                  initialValue: _selectedOfficeId,
                  decoration: InputDecoration(
                    labelText: l10n.filterByOffice,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.allOffices),
                    ),
                    ...officeDocs.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final label =
                          '${data['country'] ?? ''} – ${data['city'] ?? ''}';
                      return DropdownMenuItem<String?>(
                        value: d.id,
                        child: Text(label),
                      );
                    }),
                  ],
                  onChanged: (v) => setState(() => _selectedOfficeId = v),
                );
              },
            ),

            const SizedBox(height: 12),

            // Datumintervall + export
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 3),
                      lastDate: DateTime(now.year + 1),
                      initialDateRange:
                          _selectedRange ??
                          DateTimeRange(
                            start: DateTime(now.year, now.month, now.day),
                            end: DateTime(now.year, now.month, now.day),
                          ),
                    );
                    if (picked != null) {
                      setState(() => _selectedRange = picked);
                    }
                  },
                  child: Text(
                    _selectedRange == null
                        ? l10n.chooseDateRange
                        : '${_selectedRange!.start.toLocal().toString().split(' ').first} – ${_selectedRange!.end.toLocal().toString().split(' ').first}',
                  ),
                ),
                if (_selectedRange != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: l10n.clearDates,
                    onPressed: () => setState(() => _selectedRange = null),
                  ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _exportToCSV,
                  icon: const Icon(Icons.table_chart),
                  label: Text(l10n.exportCsv),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _exportToPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(l10n.exportPdf),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Visa ingenting förrän admin har sökt eller valt datumintervall
            if (_selectedRange == null && isEmptySearch(_query))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    l10n.searchOrChooseDatesHint,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              // Transaktionslista: kontor, datum och sökning
              StreamBuilder<QuerySnapshot>(
                stream: officesRef.snapshots(),
                builder: (context, offSnap) => StreamBuilder<QuerySnapshot>(
                  stream: transactionsRef
                      .orderBy('createAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final docs = snapshot.data!.docs;

                    // Filtrera på officeId
                    var filtered = _selectedOfficeId == null
                        ? List.of(docs)
                        : docs
                              .where(
                                (d) =>
                                    (d.data()
                                        as Map<String, dynamic>)['officeId'] ==
                                    _selectedOfficeId,
                              )
                              .toList();

                    // Filtrera på datum
                    // Använder createAt (primärt), sedan completedAt, sedan date
                    if (_selectedRange != null) {
                      filtered = filtered.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final date =
                            (data['createAt'] as Timestamp? ??
                                    data['completedAt'] as Timestamp? ??
                                    data['date'] as Timestamp?)
                                ?.toDate();
                        if (date == null) return false;
                        final rangeStart = DateTime(
                          _selectedRange!.start.year,
                          _selectedRange!.start.month,
                          _selectedRange!.start.day,
                        );
                        final rangeEnd = DateTime(
                          _selectedRange!.end.year,
                          _selectedRange!.end.month,
                          _selectedRange!.end.day,
                          23,
                          59,
                          59,
                        );
                        return !date.isBefore(rangeStart) &&
                            !date.isAfter(rangeEnd);
                      }).toList();
                    }

                    // Filtrera på sökningen
                    final allMatches = filtered.length;
                    if (!isEmptySearch(_query)) {
                      final officeLabels = {
                        for (final o in offSnap.data?.docs ?? const [])
                          o.id: () {
                            final od = o.data() as Map<String, dynamic>;
                            return '${od['country'] ?? ''} ${od['city'] ?? ''}';
                          }(),
                      };
                      filtered = filtered.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final phone = '${data['customerPhone'] ?? ''}';
                        return matchesSearch(
                          _query,
                          ids: [
                            formatClientId(data['clientId']),
                            '${data['clientId'] ?? ''}',
                            '${data['transactionNo'] ?? ''}',
                            formatTransactionNo(
                              data['transactionNo'],
                            ).replaceFirst('T-', ''),
                          ],
                          phones: [phone],
                          texts: [
                            formatTransactionNo(data['transactionNo']),
                            '${data['customerName'] ?? data['sender'] ?? ''}',
                            phone,
                            officeLabels['${data['officeId']}'] ?? '',
                            '${data['fromCurrency'] ?? data['currency'] ?? ''}',
                            '${data['toCurrency'] ?? ''}',
                            statusText(l10n, '${data['status'] ?? ''}'),
                          ],
                        );
                      }).toList();
                    }
                    final shown = filtered.take(maxSearchResults).toList();

                    // Bygg filtrerade TransactionModel. Läser det nuvarande schemat
                    // (kundens förfrågningar) och faller tillbaka på äldre fält.
                    final filteredTransactions = filtered.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final clientId = formatClientId(data['clientId']);
                      final customerName = (data['customerName'] ?? '')
                          .toString()
                          .trim();
                      final no = formatTransactionNo(data['transactionNo']);
                      final label = [
                        if (no.isNotEmpty) no,
                        if (clientId.isNotEmpty) l10n.clientShort(clientId),
                        if (customerName.isNotEmpty) customerName,
                      ].join(' · ');

                      return TransactionModel(
                        sender: customerName.isNotEmpty
                            ? customerName
                            : (data['sender'] ?? '').toString(),
                        receiver: (data['receiver'] ?? '').toString(),
                        currency:
                            (data['fromCurrency'] ?? data['currency'] ?? '')
                                .toString(),
                        amount: _toDouble(data['amountFrom'] ?? data['amount']),
                        fee: _toDouble(data['feeAmountFrom'] ?? data['fee']),
                        country: (data['country'] ?? '').toString(),
                        city: (data['city'] ?? '').toString(),
                        date:
                            (data['createAt'] as Timestamp? ??
                                    data['completedAt'] as Timestamp? ??
                                    data['date'] as Timestamp?)
                                ?.toDate() ??
                            DateTime.now(),
                        status: (data['status'] ?? '').toString(),
                        label: label,
                        toCurrency: (data['toCurrency'] ?? '').toString(),
                      );
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rapporten räknar alla träffar, listan visar högst 50.
                        OrderReport(transactions: filteredTransactions),
                        SearchSummary(
                          empty: false,
                          total: allMatches,
                          matches: filtered.length,
                          shown: shown.length,
                        ),
                        SizedBox(
                          height: 300,
                          child: OrderHistoryList(
                            transactions: filteredTransactions
                                .take(shown.length)
                                .toList(),
                            onDelete: (index) async {
                              final ok = await confirmDelete(
                                context,
                                title: l10n.deleteTransactionTitle,
                                message: l10n.deleteTransactionConfirm,
                              );
                              if (ok) {
                                await _deleteTransaction(shown[index].id);
                              }
                            },
                            onEdit: (index) => _editTransaction(shown[index]),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
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
