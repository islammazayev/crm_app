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
import '../../services/customer_counter_service.dart';
import '../../services/office_listing_service.dart';
import '../../utils/balances.dart';
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

  @override
  void initState() {
    super.initState();
    _selfHeal();
  }

  /// Rättar data som kan ha hamnat fel: publika kontorsposter som saknas
  /// och en kundräknare som ligger efter redan utdelade klient-ID:n.
  Future<void> _selfHeal() async {
    // Varje steg körs för sig, så att ett fel i det ena inte stoppar det andra,
    // och så att loggen visar vilket steg som misslyckades.
    try {
      await OfficeListingService.syncAll();
    } catch (e) {
      debugPrint('Självläkning (officeListings) misslyckades: $e');
    }
    try {
      await CustomerCounterService.ensureAtLeastMax();
    } catch (e) {
      debugPrint('Självläkning (kundräknare) misslyckades: $e');
    }
  }

  Future<void> _addOffice({
    required String country,
    required String city,
    required List<String> currencies,
    required List<OfficePaymentMethod> paymentMethods,
  }) async {
    final Map<String, double> balances = {
      for (final c in currencies) c: 0.0,
    };

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
      String officeId, String currency, double amount) async {
    await officesRef.doc(officeId).update({
      'balances.$currency': FieldValue.increment(amount),
    });
  }

  Future<void> _deleteTransaction(String id) async {
    await transactionsRef.doc(id).delete();
  }

  static const List<String> _exportHeader = <String>[
    'Datum',
    'Status',
    'Klient-ID',
    'Kontor',
    'Från',
    'Till',
    'Belopp',
    'Avgift',
    'Utbetalas',
  ];

  /// Hämtar alla transaktioner (senaste först) som rader för CSV/PDF.
  /// Läser det nuvarande schemat (createAt, fromCurrency, amountFrom ...) och
  /// faller tillbaka på de äldre fälten (date, currency, amount, fee).
  /// Sorteringen sker här, inte i queryn, eftersom orderBy utelämnar
  /// dokument som saknar fältet.
  Future<List<List<String>>> _loadExportRows() async {
    final query = await transactionsRef.get();

    DateTime? dateOf(Map<String, dynamic> data) {
      final ts = (data['createAt'] ?? data['completedAt'] ?? data['date'])
          as Timestamp?;
      return ts?.toDate();
    }

    final entries = query.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList()
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
        dateOf(data)?.toIso8601String() ?? '',
        (data['status'] ?? '').toString(),
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
    final rows = await _loadExportRows();

    if (rows.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inga transaktioner att exportera')),
      );
      return;
    }

    exportCSV.myCSV(_exportHeader, rows);
  }

  Future<void> _exportToPDF() async {
    final rows = await _loadExportRows();

    if (rows.isEmpty) {
      if (!mounted) return;
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
                  children: _exportHeader
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
                stream: officesRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = List<QueryDocumentSnapshot>.from(
                    snapshot.data!.docs,
                  )..sort((a, b) {
                      final ta = _officeCreated(a);
                      final tb = _officeCreated(b);
                      if (ta == null && tb == null) return 0;
                      if (ta == null) return 1;
                      if (tb == null) return -1;
                      return ta.compareTo(tb);
                    });
                  final offices = docs.map<Office>((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final currencies =
                        List<String>.from(data['currencies'] ?? []);
                    final balances =
                        parseBalances(data['balances'], officeId: d.id);
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
                                // Kontorets egna valutor + standardvalutor, så
                                // att admin kan lägga till nya valutor också.
                                availableCurrencies: <String>{
                                  ...currencies,
                                  'EUR', 'USD', 'SEK', 'RUB',
                                  'USDT', 'GBP', 'AED', 'TRY',
                                }.toList(),
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
