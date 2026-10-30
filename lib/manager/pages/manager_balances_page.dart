import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import 'manager_cashiers_page.dart';

/// Managerns saldon: totalen för kontoret och de kopplade kassörerna, och
/// därunder kontorets och varje kassörs saldo var för sig. Partnernas saldo
/// räknas inte med; det är inte kontorets pengar.
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: db.collection('offices').doc(officeId).snapshots(),
        builder: (context, officeSnap) {
          return StreamBuilder<
            List<QueryDocumentSnapshot<Map<String, dynamic>>>
          >(
            stream: ManagerCashiersPage.cashiers(managerId, officeId),
            builder: (context, cashSnap) {
              final error = officeSnap.error ?? cashSnap.error;
              if (error != null) {
                return Center(child: Text(l10n.errorWithDetails('$error')));
              }
              if (!officeSnap.hasData || !cashSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              String nameOf(Map<String, dynamic> d) =>
                  '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
              final office = parseBalances(
                officeSnap.data!.data()?['balances'],
                officeId: officeId,
              );
              final cashiers = cashSnap.data!
                ..sort((a, b) => nameOf(a.data()).compareTo(nameOf(b.data())));
              final cashierBalances = [
                for (final c in cashiers)
                  parseBalances(c.data()['balances'], officeId: c.id),
              ];

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Totalen visas bara när det finns kassörer att lägga ihop.
                  if (cashiers.isNotEmpty) ...[
                    SectionHeader(title: l10n.totalBalanceTitle),
                    const SizedBox(height: 10),
                    BalanceCard(
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.success,
                      title: l10n.totalBalanceSubtitle,
                      balances: sumBalances([office, ...cashierBalances]),
                    ),
                    const SizedBox(height: 28),
                  ],
                  SectionHeader(title: l10n.officeBalanceTitle),
                  const SizedBox(height: 10),
                  BalanceCard(
                    icon: Icons.storefront_outlined,
                    color: AppColors.info,
                    title: officeLabel.isEmpty ? l10n.office : officeLabel,
                    balances: office,
                  ),
                  const SizedBox(height: 28),
                  SectionHeader(title: l10n.cashierBalancesTitle),
                  const SizedBox(height: 10),
                  if (cashiers.isEmpty)
                    Text(
                      l10n.noCashiersLinked,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  for (var i = 0; i < cashiers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BalanceCard(
                        icon: Icons.point_of_sale,
                        color: AppColors.primary,
                        title: nameOf(cashiers[i].data()),
                        balances: cashierBalances[i],
                      ),
                    ),
                ],
              );
            },
          );
        },
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
