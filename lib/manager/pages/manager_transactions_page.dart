import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../utils/client_id.dart';
import '../../utils/transaction_no.dart';
import 'manager_transactions_detail_screen.dart';

class ManagerTransactionsPage extends StatelessWidget {
  final String officeId;

  /// Om satt visas bara transaktioner med någon av dessa statusar.
  final List<String>? statuses;

  /// Rubrik i appbaren. Utan rubrik visas "Transaktioner".
  final String? title;

  const ManagerTransactionsPage({
    super.key,
    required this.officeId,
    this.statuses,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('transactions')
        .where('officeId', isEqualTo: officeId)
        .orderBy('createAt', descending: true);

    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(title ?? l10n.transactions)),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(l10n.errorWithDetails('${snapshot.error}')),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filtreras i appen så att inga fler index behövs.
          // Arkiverade (av admin) visas inte.
          final docs = snapshot.data!.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            if (data['archived'] == true) return false;
            if (statuses == null) return true;
            final status = data['status'];
            return statuses!.contains(status);
          }).toList();
          if (docs.isEmpty) {
            return Center(child: Text(l10n.noTransactionsYet));
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
                  statusText = l10n.managerStatusRequested;
                  break;
                case 'manager_proposed':
                  statusText = l10n.managerStatusProposed;
                  break;
                case 'customer_accepted':
                  statusText = l10n.managerStatusAccepted;
                  break;
                case 'customer_countered':
                  statusText = l10n.managerStatusCountered;
                  break;
                case 'customer_rejected':
                  statusText = l10n.managerStatusRejected;
                  break;
                case 'customer_paid':
                  statusText = l10n.managerStatusPaid;
                  break;
                case 'payment_confirmed':
                  statusText = l10n.managerStatusPaymentConfirmed;
                  break;
                case 'completed':
                  statusText = l10n.statusCompleted;
                  break;
                default:
                  statusText = status;
              }

              final titleLines = <String>[];
              final no = formatTransactionNo(data['transactionNo']);
              if (no.isNotEmpty) titleLines.add(no);
              if (clientId.isNotEmpty) {
                titleLines.add(l10n.clientIdValue(clientId));
              }
              if (name.isNotEmpty) {
                titleLines.add(name);
              }

              return ListTile(
                title: Text(
                  titleLines.isNotEmpty
                      ? titleLines.join('\n')
                      : l10n.unknownClient,
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
                      builder: (_) =>
                          ManagerTransactionDetailScreen(transactionId: doc.id),
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
