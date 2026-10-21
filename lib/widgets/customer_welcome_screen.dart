import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../customer/pages/customer_send_page.dart';
import '../customer/screens/customer_transactions_screen.dart';
import '../l10n/locale_controller.dart';
import '../screens/auth_gate.dart';
import '../theme/app_theme.dart';
import '../utils/client_id.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.comingSoon(section))),
    );
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
            const SizedBox(height: 24),
            SectionHeader(title: l10n.customerPanel),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 760;
                return GridView.count(
                  crossAxisCount: isWide ? 2 : 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 2.5 : 2.1,
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
                        final docs = snapshot.data?.docs ?? const [];
                        final waiting = docs.where((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return data['status'] == 'manager_proposed';
                        }).length;
                        return ActionCard(
                          icon: Icons.receipt_long_outlined,
                          iconColor: AppColors.info,
                          title: l10n.myTransactions,
                          subtitle: waiting > 0
                              ? l10n.offersWaiting(waiting)
                              : l10n.myTransactionsSubtitle,
                          badge: snapshot.hasData ? '${docs.length}' : '…',
                          onTap: () => _open(
                            context,
                            const CustomerTransactionsScreen(),
                          ),
                        );
                      },
                    ),
                    for (final (icon, title) in [
                      (Icons.shopping_cart_outlined, l10n.tabBuy),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
