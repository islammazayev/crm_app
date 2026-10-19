import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/customer_transaction_detail_screen.dart';

/// Kundvänlig text för transaktionens status.
String customerStatusText(String status) {
  switch (status) {
    case 'customer_requested':
      return 'Skickad – väntar på manager';
    case 'manager_proposed':
      return 'Förslag från manager – klicka för detaljer';
    case 'customer_accepted':
      return 'Accepterad – betalningsuppgifter kommer';
    case 'customer_rejected':
      return 'Avböjd';
    case 'completed':
      return 'Genomförd';
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
        .where('customerId', isEqualTo: currentUserId)
        .orderBy('createAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Mina transaktioner')),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Fel: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Inga transaktioner ännu'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final amountFrom = data['amountFrom'] ?? 0;
              final fromCurrency = data['fromCurrency']?.toString() ?? '';
              final toCurrency = data['toCurrency']?.toString() ?? '';
              final status = data['status']?.toString() ?? '';
              final createdAt = (data['createAt'] as Timestamp?)?.toDate();

              final statusText = customerStatusText(status);

              return ListTile(
                title: Text('$amountFrom $fromCurrency → $toCurrency'),
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
