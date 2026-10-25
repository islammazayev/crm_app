import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import 'manager_cashiers_page.dart';

/// Managerns saldon: kontorets saldo och varje kopplad kassörs saldo, var
/// för sig. De läggs inte ihop, eftersom pengarna finns på olika ställen.
class ManagerBalancesPage extends StatelessWidget {
  final String managerId;
  final String officeId;
  final String officeLabel;

  const ManagerBalancesPage({
    super.key,
    required this.managerId,
    required this.officeId,
    required this.officeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.balancesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionHeader(title: l10n.officeBalanceTitle),
          const SizedBox(height: 10),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: db.collection('offices').doc(officeId).snapshots(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Text(l10n.errorWithDetails('${snap.error}'));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return BalanceCard(
                icon: Icons.storefront_outlined,
                color: AppColors.info,
                title: officeLabel.isEmpty ? l10n.office : officeLabel,
                balances: parseBalances(
                  snap.data!.data()?['balances'],
                  officeId: officeId,
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          SectionHeader(title: l10n.cashierBalancesTitle),
          const SizedBox(height: 10),
          StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            stream: ManagerCashiersPage.cashiers(managerId, officeId),
            builder: (context, snap) {
              if (snap.hasError) {
                return Text(l10n.errorWithDetails('${snap.error}'));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              String nameOf(Map<String, dynamic> d) =>
                  '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
              final docs = snap.data!
                ..sort((a, b) => nameOf(a.data()).compareTo(nameOf(b.data())));
              if (docs.isEmpty) {
                return Text(
                  l10n.noCashiersLinked,
                  style: const TextStyle(color: AppColors.textMuted),
                );
              }
              return Column(
                children: [
                  for (final doc in docs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BalanceCard(
                        icon: Icons.point_of_sale,
                        color: AppColors.primary,
                        title: nameOf(doc.data()),
                        balances: parseBalances(
                          doc.data()['balances'],
                          officeId: doc.id,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Ett kort med namn och saldo per valuta.
class BalanceCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Map<String, double> balances;

  const BalanceCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.balances,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = balances.entries.where((e) => e.value != 0).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Text(
                l10n.noBalance,
                style: const TextStyle(color: AppColors.textMuted),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in entries)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${e.value.toStringAsFixed(2)} ${e.key}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: e.value < 0
                              ? Colors.red
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
