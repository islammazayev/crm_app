import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/locale_controller.dart';
import '../../utils/transaction_kind.dart';
import '../../utils/transaction_no.dart';
import '../screens/customer_transaction_detail_screen.dart';

/// Kundvänlig text för transaktionens status.
String customerStatusText(AppLocalizations l10n, String status) {
  switch (status) {
    case 'customer_requested':
      return l10n.customerStatusRequested;
    case 'manager_proposed':
      return l10n.customerStatusProposed;
    case 'customer_accepted':
      return l10n.customerStatusAccepted;
    case 'customer_countered':
      return l10n.customerStatusCountered;
    case 'customer_rejected':
      return l10n.customerStatusRejected;
    case 'customer_paid':
      return l10n.customerStatusPaid;
    case 'payment_confirmed':
      return l10n.customerStatusPaymentConfirmed;
    case 'completed':
      return l10n.statusCompleted;
    default:
      return status;
  }
}

class CustomerTransactionsScreen extends StatelessWidget {
  const CustomerTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final query = FirebaseFirestore.instance
        .collection('transactions')
        .where('customerId', isEqualTo: currentUserId);

    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myTransactions)),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(l10n.errorWithDetails('${snapshot.error}')),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(l10n.noTransactionsYet));
          }

          // Sorteras här (senaste först) i stället för i frågan, så att
          // Firestore inte kräver ett extra index för customerId + createAt.
          // Arkiverade (av admin) visas inte.
          final docs =
              snapshot.data!.docs
                  .where(
                    (d) =>
                        (d.data() as Map<String, dynamic>)['archived'] != true,
                  )
                  .toList()
                ..sort((a, b) {
                  DateTime? at(QueryDocumentSnapshot d) =>
                      ((d.data() as Map<String, dynamic>)['createAt']
                              as Timestamp?)
                          ?.toDate();
                  final ta = at(a), tb = at(b);
                  if (ta == null && tb == null) return 0;
                  if (ta == null) return -1; // nyss skapad, tid ej satt än
                  if (tb == null) return 1;
                  return tb.compareTo(ta);
                });

          if (docs.isEmpty) {
            return Center(child: Text(l10n.noTransactionsYet));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final status = data['status']?.toString() ?? '';
              final createdAt = (data['createAt'] as Timestamp?)?.toDate();

              final statusText = customerStatusText(l10n, status);

              return ListTile(
                title: Text(
                  [
                    formatTransactionNo(data['transactionNo']),
                    transactionSummary(l10n, data),
                  ].where((t) => t.isNotEmpty).join('  ·  '),
                ),
                subtitle: Text(
                  '${createdAt != null ? createdAt.toLocal().toString() : ''}\n$statusText',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerTransactionDetailScreen(
                        transactionId: doc.id,
                      ),
                    ),
                  );
                },
                // Här kan vi senare öppna kundens detaljsida
                // där kunden kan acceptera/avböja.
              );
            },
          );
        },
      ),
    );
  }
}
