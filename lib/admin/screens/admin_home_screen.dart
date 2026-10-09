import 'dart:html' as html;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:to_csv/to_csv.dart' as exportCSV;

import '../../forms/office_form.dart';
import '../../forms/create_manager_form.dart';
import '../../lists/office_list.dart';
import '../../lists/order_history_list.dart';
import '../../widgets/order_report.dart';
import '../../models/office.dart';
import '../../models/transaction_model.dart';
import '../sections/admin_customers_section.dart';
import '../sections/admin_offices_section.dart';
import '../sections/admin_transactions_section.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  DateTimeRange? _selectedRange;
  String? _selectedOfficeId; // null = alla kontor

  CollectionReference get officesRef =>
      FirebaseFirestore.instance.collection('offices');
  CollectionReference get transactionsRef =>
      FirebaseFirestore.instance.collection('transactions');

  Future<void> _addOffice({
    required String country,
    required String city,
    required List<String> currencies,
    required List<OfficePaymentMethod> paymentMethods,
  }) async {
    final Map<String, double> balances = {
      for (final c in currencies) c: 0.0,
    };

    await officesRef.add({
      'country': country,
      'city': city,
      'currencies': currencies,
      'balances': balances,
      'paymentMethods': paymentMethods.map((m) => m.toMap()).toList(),
      'createAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteOffice(String id) async {
    await officesRef.doc(id).delete();
  }

  Future<void> _topUpOfficeCurrency(
      String officeId, String currency, double amount) async {
    await officesRef.doc(officeId).update({
      'balances.$currency': FieldValue.increment(amount),
    });
  }

  Future<void> _deleteTransaction(String id) async {
    await transactionsRef.doc(id).delete();
  }

  Future<void> _exportToCSV() async {
    final query = await transactionsRef.orderBy('date', descending: true).get();

    final header = <String>[
      'Datum',
      'Sender',
      'Receiver',
      'Country',
      'City',
      'Currency',
      'Amount',
      'Fee',
    ];

    final List<List<String>> rows = [];

    for (final doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp?)?.toDate();

      rows.add([
        date?.toIso8601String() ?? '',
        data['sender']?.toString() ?? '',
        data['receiver']?.toString() ?? '',
        data['country']?.toString() ?? '',
        data['city']?.toString() ?? '',
        data['currency']?.toString() ?? '',
        (data['amount'] ?? 0).toString(),
        (data['fee'] ?? 0).toString(),
      ]);
    }

    if (rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inga transaktioner att exportera')),
      );
      return;
    }

    exportCSV.myCSV(header, rows);
  }

  Future<void> _exportToPDF() async {
    final query = await transactionsRef.orderBy('date', descending: true).get();

    if (query.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inga transaktioner att exportera')),
      );
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Text('Orderrapport', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              children: [
                pw.TableRow(
                  children: [
                    'Datum',
                    'Sender',
                    'Receiver',
                    'Country',
                    'City',
                    'Currency',
                    'Amount',
                    'Fee',
                  ]
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
                ...query.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final date = (data['date'] as Timestamp?)?.toDate();
                  final cells = <String>[
                    date?.toIso8601String() ?? '',
                    data['sender']?.toString() ?? '',
                    data['receiver']?.toString() ?? '',
                    data['country']?.toString() ?? '',
                    data['city']?.toString() ?? '',
                    data['currency']?.toString() ?? '',
                    (data['amount'] ?? 0).toString(),
                    (data['fee'] ?? 0).toString(),
                  ];
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

    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'orderrapport.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM – Admin'),
        actions: [
          IconButton(
            tooltip: 'Logga ut',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adminvy: Full kontroll',
                style: TextStyle(fontSize: 24),
              ),

              const SizedBox(height: 16),

              // Kunddel i egen widget
              const AdminCustomersSection(),

              const SizedBox(height: 32),

              const Text(
                "Hantera kontor",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              OfficeForm(
                onSubmit: ({
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
                },
              ),
              const SizedBox(height: 8),

              StreamBuilder<QuerySnapshot>(
                stream: officesRef.orderBy('createdAt').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  final offices = docs.map<Office>((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final currencies =
                        List<String>.from(data['currencies'] ?? []);
                    final rawBalances =
                        Map<String, dynamic>.from(data['balances'] ?? {});
                    final balances = <String, double>{
                      for (final e in rawBalances.entries)
                        e.key: (e.value ?? 0).toDouble(),
                    };
                    final rawMethods =
                        data['paymentMethods'] as List? ?? [];
                    final paymentMethods = rawMethods
                        .whereType<Map>()
                        .map((e) => OfficePaymentMethod.fromMap(
                            Map<String, dynamic>.from(e)))
                        .toList();

                    return Office(
                      id: d.id,
                      country: data['country'] ?? '',
                      city: data['city'] ?? '',
                      currencies: currencies,
                      balances: balances,
                      paymentMethods: paymentMethods,
                    );
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CreateManagerForm(officeDocs: docs),
                      const SizedBox(height: 16),
                      OfficeList(
                          offices: offices,
                          officeDocs: docs, // viktigt för manager‑info
                          onEdit: (index) {
                            final officeDoc = docs[index];
                            final data =
                                officeDoc.data() as Map<String, dynamic>;
                            final currencies =
                                List<String>.from(data['currencies'] ?? []);
                            showDialog(
                              context: context,
                              builder: (ctx) => EditOfficeDialog(
                                officeId: officeDoc.id,
                                 data: data,
                                availableCurrencies: currencies,
                              ),
                            );
                          },
                          onDelete: (index) {
                            final id = docs[index].id;
                            _deleteOffice(id);
                          },
                          onTopUp: (index) async {
                            final officeDoc = docs[index];
                            final data =
                                officeDoc.data() as Map<String, dynamic>;
                            final currencies =
                                List<String>.from(data['currencies'] ?? []);
                            String selectedCurrency = currencies.first;

                            final controller = TextEditingController();
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Fyll på saldo'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DropdownButtonFormField<String>(
                                        value: selectedCurrency,
                                        items: currencies
                                            .map(
                                              (c) => DropdownMenuItem(
                                                value: c,
                                                child: Text(c),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null) {
                                            selectedCurrency = v;
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Valuta',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: controller,
                                        keyboardType:
                                            const TextInputType
                                                .numberWithOptions(
                                                    decimal: true),
                                        decoration: const InputDecoration(
                                          labelText: 'Belopp',
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Avbryt'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (ok == true) {
                              final amount = double.tryParse(
                                      controller.text.replaceAll(',', '.')) ??
                                  0;
                              if (amount > 0) {
                                await _topUpOfficeCurrency(
                                    officeDoc.id, selectedCurrency, amount);
                              }
                            }
                          },
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              const Text(
                'Orderhistorik',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Office-filter
              StreamBuilder<QuerySnapshot>(
                stream: officesRef.snapshots(),
                builder: (context, offSnap) {
                  final officeDocs =
                      offSnap.hasData ? offSnap.data!.docs : <QueryDocumentSnapshot>[];

                  return DropdownButtonFormField<String?>(
                    value: _selectedOfficeId,
                    decoration: const InputDecoration(
                      labelText: 'Filtrera på kontor (valfritt)',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Alla kontor'),
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
                        initialDateRange: _selectedRange ??
                            DateTimeRange(
                              start: DateTime(now.year, now.month, now.day),
                              end: DateTime(now.year, now.month, now.day),
                            ),
                      );
                      if (picked != null) {
                        setState(() => _selectedRange = picked);
                      }
                    },
                    child: Text(_selectedRange == null
                        ? 'Välj datumintervall'
                        : '${_selectedRange!.start.toLocal().toString().split(' ').first} – ${_selectedRange!.end.toLocal().toString().split(' ').first}'),
                  ),
                  if (_selectedRange != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Rensa datum',
                      onPressed: () => setState(() => _selectedRange = null),
                    ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _exportToCSV,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Exportera CSV'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _exportToPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Exportera PDF'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Visa ingenting förrän datumintervall valts
              if (_selectedRange == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Välj ett datumintervall för att visa transaktioner.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
              // Transaktionslista med dubbelt filter
              StreamBuilder<QuerySnapshot>(
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

                  // Bygg TransactionModel-lista
                  final allTransactions = docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return TransactionModel(
                      sender: data['sender'] ?? '',
                      receiver: data['receiver'] ?? '',
                      currency: data['currency'] ?? '',
                      amount: (data['amount'] ?? 0).toDouble(),
                      fee: (data['feeAmountFrom'] ?? data['fee'] ?? 0)
                          .toDouble(),
                      country: data['country'] ?? '',
                      city: data['city'] ?? '',
                      date: (data['completedAt'] as Timestamp? ??
                              data['date'] as Timestamp?)
                              ?.toDate() ??
                          DateTime.now(),
                    );
                  }).toList();

                  // Filtrera på officeId
                  var filtered = _selectedOfficeId == null
                      ? List.of(docs)
                      : docs
                          .where((d) =>
                              (d.data()
                                  as Map<String,
                                      dynamic>)['officeId'] ==
                              _selectedOfficeId)
                          .toList();

                  // Filtrera på datum
                  // Använder createAt (primärt), sedan completedAt, sedan date
                  if (_selectedRange != null) {
                    filtered = filtered.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final date = (data['createAt'] as Timestamp? ??
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
                        23, 59, 59,
                      );
                      return !date.isBefore(rangeStart) &&
                          !date.isAfter(rangeEnd);
                    }).toList();
                  }

                  // Bygg filtrerade TransactionModel
                  final filteredTransactions = filtered.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return TransactionModel(
                      sender: data['sender'] ?? '',
                      receiver: data['receiver'] ?? '',
                      currency: data['currency'] ?? '',
                      amount: (data['amountFrom'] ?? data['amount'] ?? 0)
                          .toDouble(),
                      fee: (data['feeAmountFrom'] ?? data['fee'] ?? 0)
                          .toDouble(),
                      country: data['country'] ?? '',
                      city: data['city'] ?? '',
                      date: (data['createAt'] as Timestamp? ??
                              data['completedAt'] as Timestamp? ??
                              data['date'] as Timestamp?)
                              ?.toDate() ??
                          DateTime.now(),
                    );
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OrderReport(transactions: filteredTransactions),
                      SizedBox(
                        height: 300,
                        child: OrderHistoryList(
                          transactions: filteredTransactions,
                          onDelete: (index) {
                            final id = filtered[index].id;
                            _deleteTransaction(id);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
