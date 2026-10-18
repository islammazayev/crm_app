import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/client_id.dart';
import 'manager_transactions_detail_screen.dart';

class ManagerTransactionsPage extends StatelessWidget {
  final String officeId;

  /// Om satt visas bara transaktioner med någon av dessa statusar.
  final List<String>? statuses;
  final String title;

  const ManagerTransactionsPage({
    super.key,
    required this.officeId,
    this.statuses,
    this.title = 'Transaktioner',
  });

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('transactions')
        .where('officeId', isEqualTo: officeId)
        .orderBy('createAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Fel: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filtreras i appen så att inga fler index behövs.
          final docs = snapshot.data!.docs.where((d) {
            if (statuses == null) return true;
            final status = (d.data() as Map<String, dynamic>)['status'];
            return statuses!.contains(status);
          }).toList();
          if (docs.isEmpty) {
            return const Center(child: Text('Inga transaktioner ännu'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final amountFrom = ((data['amountFrom'] ?? 0) as num).toDouble();
              final fromCurrency = data['fromCurrency']?.toString() ?? '';
              final toCurrency = data['toCurrency']?.toString() ?? '';
              final createdAt = (data['createAt'] as Timestamp?)?.toDate();
              final status = data['status']?.toString() ?? '';

              // Kundens klient-ID och namn sparas i transaktionen när kunden
              // skickar förfrågan, så managern behöver inte läsa kundregistret.
              final clientId = formatClientId(data['clientId']);
              final name = (data['customerName'] ?? '').toString().trim();

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
                case 'completed':
                  statusText = 'Genomförd';
                  break;
                default:
                  statusText = status;
              }

              final titleLines = <String>[];
              if (clientId.isNotEmpty) {
                titleLines.add('Klient‑ID: $clientId');
              }
              if (name.isNotEmpty) {
                titleLines.add(name);
              }

              return ListTile(
                title: Text(
                  titleLines.isNotEmpty ? titleLines.join('\n') : 'Okänd klient',
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
      ),
    );
  }
}
