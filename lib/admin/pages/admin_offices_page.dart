import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../forms/office_form.dart';
import '../../l10n/locale_controller.dart';
import '../../lists/office_list.dart';
import '../../models/office.dart';
import '../../services/office_listing_service.dart';
import '../../utils/balances.dart';
import '../../utils/currencies.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageOffices)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.createOffice,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            OfficeForm(
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
                  },
            ),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: officesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs =
                    List<QueryDocumentSnapshot>.from(snapshot.data!.docs)
                      ..sort((a, b) {
                        final ta = _officeCreated(a);
                        final tb = _officeCreated(b);
                        if (ta == null && tb == null) return 0;
                        if (ta == null) return 1;
                        if (tb == null) return -1;
                        return ta.compareTo(tb);
                      });
                final offices = docs.map<Office>((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final currencies = List<String>.from(
                    data['currencies'] ?? [],
                  );
                  final balances = parseBalances(
                    data['balances'],
                    officeId: d.id,
                  );
                  final rawMethods = data['paymentMethods'] as List? ?? [];
                  final paymentMethods = rawMethods
                      .whereType<Map>()
                      .map(
                        (e) => OfficePaymentMethod.fromMap(
                          Map<String, dynamic>.from(e),
                        ),
                      )
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
                    OfficeList(
                      offices: offices,
                      officeDocs: docs, // viktigt för manager‑info
                      onEdit: (index) {
                        final officeDoc = docs[index];
                        final data = officeDoc.data() as Map<String, dynamic>;
                        final currencies = List<String>.from(
                          data['currencies'] ?? [],
                        );
                        showDialog(
                          context: context,
                          builder: (ctx) => EditOfficeDialog(
                            officeId: officeDoc.id,
                            data: data,
                            // Kontorets egna valutor + standardvalutor, så
                            // att admin kan lägga till nya valutor också.
                            availableCurrencies: <String>{
                              ...normalizeCurrencies(currencies),
                              ...kSupportedCurrencies,
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
                        final data = officeDoc.data() as Map<String, dynamic>;
                        final currencies = List<String>.from(
                          data['currencies'] ?? [],
                        );
                        if (currencies.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.officeHasNoCurrencies)),
                          );
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
                                    decoration: InputDecoration(
                                      labelText: l10n.currency,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: controller,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      labelText: l10n.amount,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                          final amount =
                              double.tryParse(
                                controller.text.replaceAll(',', '.'),
                              ) ??
                              0;
                          if (amount > 0) {
                            await _topUpOfficeCurrency(
                              officeDoc.id,
                              selectedCurrency,
                              amount,
                            );
                          }
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
