import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'manager_transactions_detail_screen.dart';

class ManagerTransactionsPage extends StatelessWidget {
  final String officeId;
  const ManagerTransactionsPage({super.key, required this.officeId});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('transactions')
        .where('officeId', isEqualTo: officeId)
        .orderBy('createAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaktioner')),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Fel: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Inga transaktioner ännu'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final customerId = data['customerId']?.toString() ?? '';
              final amountFrom = (data['amountFrom'] ?? 0 as num).toDouble();
              final fromCurrency = data['fromCurrency']?.toString() ?? '';
              final toCurrency = data['toCurrency']?.toString() ?? '';
              final createdAt = (data['createAt'] as Timestamp?)?.toDate();
              final status = data['status']?.toString() ?? '';

              String statusText;
              switch (status) {
                case 'customer_requested':
                  statusText = 'Ny förfrågan från kund';
                  break;
                case 'manager_proposed':
                  statusText = 'Förslag skickat – väntar på kund';
                  break;
                case 'customer_accepted':
                  statusText = 'Kund har accepterat förslaget';
                  break;
                case 'customer_rejected':
                  statusText = 'Kund avbröt transaktionen';
                  break;
                default:
                  statusText = status;
              }

              // Hämta kundens namn från customers/{customerId}
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('customers')
                    .doc(customerId)
                    .get(),
                builder: (context, customerSnap) {
                  String name = '';
                  if (customerSnap.hasData &&
                      customerSnap.data!.data() != null) {
                    final cData =
                        customerSnap.data!.data() as Map<String, dynamic>;
                    final firstName = cData['firstName']?.toString() ?? '';
                    final lastName = cData['lastName']?.toString() ?? '';
                    name = '$firstName $lastName'.trim();
                  }

                  final titleLines = <String>[];
                  if (customerId.isNotEmpty) {
                    titleLines.add('Klient‑ID: $customerId');
                  }
                  if (name.isNotEmpty) {
                    titleLines.add(name);
                  }

                  return ListTile(
                    title: Text(
                      titleLines.isNotEmpty
                          ? titleLines.join('\n')
                          : 'Okänd klient',
                    ),
                    subtitle: Text(
                      '$amountFrom $fromCurrency → $toCurrency'
                      '${createdAt != null ? '\n${createdAt.toLocal()}' : ''}'
                      '\n$statusText',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManagerTransactionDetailScreen(
                            transactionId: doc.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
