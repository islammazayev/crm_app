import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../cashier/pages/cashier_overview_page.dart';
import '../../l10n/locale_controller.dart';
import '../../services/cashier_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import '../../utils/merged_query.dart';

/// Kassörer kopplade till managern eller till managerns kontor.
class ManagerCashiersPage extends StatelessWidget {
  final String managerId;
  final String? officeId;

  const ManagerCashiersPage({
    super.key,
    required this.managerId,
    required this.officeId,
  });

  /// En fråga per villkor, så att reglerna kan godkänna dem.
  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> cashiers(
    String managerId,
    String? officeId,
  ) {
    final col = FirebaseFirestore.instance.collection('cashiers');
    return mergedQuery([
      col.where('managerId', isEqualTo: managerId),
      if (officeId != null) col.where('officeId', isEqualTo: officeId),
    ]);
  }

  /// Överföringar som rör managerns kassörer. Kopplingen sparas i
  /// överföringen när den skickas.
  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> transfers(
    String managerId,
    String? officeId,
  ) {
    final t = CashierService.transfers;
    return mergedQuery([
      t.where('fromManagerId', isEqualTo: managerId),
      t.where('toManagerId', isEqualTo: managerId),
      if (officeId != null) t.where('fromOfficeId', isEqualTo: officeId),
      if (officeId != null) t.where('toOfficeId', isEqualTo: officeId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myCashiers)),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: cashiers(managerId, officeId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text(l10n.errorWithDetails('${snap.error}')));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          String nameOf(Map<String, dynamic> d) =>
              '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
          final docs = snap.data!
            ..sort((a, b) => nameOf(a.data()).compareTo(nameOf(b.data())));
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.noCashiersLinked, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final doc in docs)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.point_of_sale,
                      color: AppColors.primary,
                    ),
                    title: Text(nameOf(doc.data())),
                    subtitle: Text(() {
                      final b = parseBalances(
                        doc.data()['balances'],
                        officeId: doc.id,
                      ).entries.where((e) => e.value != 0);
                      return l10n.balanceValue(
                        b.isEmpty
                            ? '0'
                            : b
                                  .map(
                                    (e) =>
                                        '${e.value.toStringAsFixed(2)} ${e.key}',
                                  )
                                  .join(', '),
                      );
                    }()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CashierOverviewPage(
                          cashierId: doc.id,
                          name: nameOf(doc.data()),
                          transfers: transfers(managerId, officeId),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
