import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../customer/pages/customer_buy_page.dart';
import '../customer/pages/customer_send_page.dart';
import '../customer/screens/customer_transactions_screen.dart';
import '../l10n/locale_controller.dart';
import '../screens/auth_gate.dart';
import '../theme/app_theme.dart';
import '../utils/client_id.dart';
import '../utils/customer_tiers.dart';
import 'action_card.dart';
import 'language_button.dart';

/// Kundens startsida: kunduppgifter överst och ett kort per funktion,
/// som på managerns och adminens startsidor.
class CustomerWelcomeScreen extends StatelessWidget {
  final String clientId;
  final String fullName;
  final String phone;

  const CustomerWelcomeScreen({
    super.key,
    required this.clientId,
    required this.fullName,
    required this.phone,
  });

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _comingSoon(BuildContext context, String section) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.comingSoon(section))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerAppBarTitle),
        actions: [
          const LanguageButton(),
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => signOutToLogin(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.welcomeName(fullName),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${l10n.clientIdValue(formatClientId(clientId))}  ·  '
              '${l10n.phoneValue(phone)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            _TierBadge(uid: uid),
            const SizedBox(height: 24),
            SectionHeader(title: l10n.customerPanel),
            const SizedBox(height: 8),
            ActionCardGrid(
              children: [
                ActionCard(
                  icon: Icons.send_outlined,
                  iconColor: AppColors.primary,
                  title: l10n.sendMoney,
                  subtitle: l10n.sendMoneySubtitle,
                  badge: '+',
                  onTap: () => _open(context, const CustomerSendPage()),
                ),
                // Siffran visar förslag från managern som väntar på svar.
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('transactions')
                      .where('customerId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final docs = (snapshot.data?.docs ?? const [])
                        .where(
                          (d) =>
                              (d.data() as Map<String, dynamic>)['archived'] !=
                              true,
                        )
                        .toList();
                    int countStatus(String status) => docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return data['status'] == status;
                    }).length;
                    final waiting = countStatus('manager_proposed');
                    final ready = countStatus('payment_confirmed');
                    return ActionCard(
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppColors.info,
                      title: l10n.myTransactions,
                      subtitle: waiting > 0
                          ? l10n.offersWaiting(waiting)
                          : ready > 0
                          ? l10n.readyForPickup(ready)
                          : l10n.myTransactionsSubtitle,
                      badge: snapshot.hasData ? '${docs.length}' : '…',
                      onTap: () =>
                          _open(context, const CustomerTransactionsScreen()),
                    );
                  },
                ),
                ActionCard(
                  icon: Icons.shopping_cart_outlined,
                  iconColor: AppColors.warning,
                  title: l10n.tabBuy,
                  subtitle: l10n.buyCardSubtitle,
                  badge: '+',
                  onTap: () => _open(context, const CustomerBuyPage()),
                ),
                for (final (icon, title) in [
                  (Icons.sell_outlined, l10n.tabSell),
                  (Icons.currency_exchange, l10n.tabExchange),
                ])
                  ActionCard(
                    icon: icon,
                    iconColor: AppColors.textMuted,
                    title: title,
                    subtitle: l10n.comingSoon(title),
                    badge: l10n.soonBadge,
                    onTap: () => _comingSoon(context, title),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Kundens nivå och rabatt, t.ex. "🥇 Guld – 1 % rabatt på avgiften".
/// Visas inte alls för kunder utan nivå.
class _TierBadge extends StatelessWidget {
  final String uid;

  const _TierBadge({required this.uid});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .snapshots(),
      builder: (context, customerSnap) {
        return StreamBuilder<TierSettings>(
          stream: TierSettings.watch(),
          builder: (context, tierSnap) {
            final info = (tierSnap.data ?? const TierSettings()).forCustomer(
              customerSnap.data?.data(),
            );
            if (info == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  l10n.customerTierBadge(
                    '${info.tier.emoji} ${info.tier.label(l10n)}',
                    formatPercent(info.discount),
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
