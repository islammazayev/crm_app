import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../services/cashier_service.dart';
import '../../utils/balances.dart';
import '../widgets/transfer_list.dart';

/// En kassörs saldo och överföringar, för admin och manager (bara läsning).
///
/// [transfers] skickas in eftersom admin får läsa allt, medan managern bara
/// får fråga efter överföringar som rör hens kassörer (se reglerna).
class CashierOverviewPage extends StatelessWidget {
  final String cashierId;
  final String name;
  final Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> transfers;

  const CashierOverviewPage({
    super.key,
    required this.cashierId,
    required this.name,
    required this.transfers,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: CashierService.cashier(cashierId).snapshots(),
              builder: (context, snap) => BalancesCard(
                balances: parseBalances(
                  snap.data?.data()?['balances'],
                  officeId: cashierId,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.transfersTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TransferList(cashierId: cashierId, stream: transfers),
          ],
        ),
      ),
    );
  }
}
