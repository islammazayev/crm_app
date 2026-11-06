import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../customer/pages/customer_send_page.dart';
import '../customer/pages/customer_trade_page.dart';
import '../customer/screens/customer_transaction_detail_screen.dart';
import '../customer/screens/customer_transactions_screen.dart';
import '../customer/widgets/trade_section.dart';
import '../l10n/locale_controller.dart';
import '../screens/settings_page.dart';
import '../theme/app_theme.dart';
import '../utils/client_id.dart';
import '../utils/customer_tiers.dart';
import '../utils/customer_transactions.dart';
import '../utils/transaction_kind.dart';
import '../utils/transaction_no.dart';
import 'app_shell.dart';
import 'overview_widgets.dart';

/// Kundens app: meny med översikt, transaktioner, skicka, köpa, sälja och
/// inställningar.
class CustomerWelcomeScreen extends StatefulWidget {
  final String clientId;
  final String fullName;
  final String phone;

  const CustomerWelcomeScreen({
    super.key,
    required this.clientId,
    required this.fullName,
    required this.phone,
  });

  @override
  State<CustomerWelcomeScreen> createState() => _CustomerWelcomeScreenState();
}

class _CustomerWelcomeScreenState extends State<CustomerWelcomeScreen> {
  final _shell = GlobalKey<AppShellState>();
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  late final _transactions = customerTransactions(_uid);

  // Platser i menyn.
  static const _transactionsIndex = 1;
  static const _sendIndex = 2;
  static const _buyIndex = 3;
  static const _sellIndex = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: _transactions,
      builder: (context, snap) {
        final waiting = (snap.data ?? const [])
            .where(
              (d) =>
                  d.data()['archived'] != true &&
                  d.data()['status'] == 'manager_proposed',
            )
            .length;
        return AppShell(
          key: _shell,
          primaryAction: ShellAction(
            icon: Icons.add,
            label: l10n.sendMoney,
            onTap: () => _shell.currentState?.select(_sendIndex),
          ),
          destinations: [
            ShellDestination(
              icon: Icons.home_outlined,
              label: l10n.overview,
              builder: (_) => _CustomerOverview(
                uid: _uid,
                clientId: widget.clientId,
                fullName: widget.fullName,
                onSelect: (i) => _shell.currentState?.select(i),
                transactionsIndex: _transactionsIndex,
                sendIndex: _sendIndex,
                buyIndex: _buyIndex,
                sellIndex: _sellIndex,
              ),
            ),
            ShellDestination(
              icon: Icons.receipt_long_outlined,
              label: l10n.myTransactions,
              badge: waiting,
              builder: (_) => const CustomerTransactionsScreen(),
            ),
            ShellDestination(
              icon: Icons.send_outlined,
              label: l10n.sendMoney,
              builder: (_) => const CustomerSendPage(),
            ),
            ShellDestination(
              icon: Icons.shopping_cart_outlined,
              label: l10n.tabBuy,
              builder: (_) => const CustomerTradePage(kind: TradeKind.buy),
            ),
            ShellDestination(
              icon: Icons.sell_outlined,
              label: l10n.tabSell,
              builder: (_) => const CustomerTradePage(kind: TradeKind.sell),
            ),
            ShellDestination(
              icon: Icons.settings_outlined,
              label: l10n.settingsTitle,
              builder: (_) => const SettingsPage(),
            ),
          ],
        );
      },
    );
  }
}

class _CustomerOverview extends StatefulWidget {
  final String uid;
  final String clientId;
  final String fullName;
  final ValueChanged<int> onSelect;
  final int transactionsIndex;
  final int sendIndex;
  final int buyIndex;
  final int sellIndex;

  const _CustomerOverview({
    required this.uid,
    required this.clientId,
    required this.fullName,
    required this.onSelect,
    required this.transactionsIndex,
    required this.sendIndex,
    required this.buyIndex,
    required this.sellIndex,
  });

  @override
  State<_CustomerOverview> createState() => _CustomerOverviewState();
}

class _CustomerOverviewState extends State<_CustomerOverview> {
  late final _transactions = customerTransactions(widget.uid);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OverviewPage(
      title: greetingFor(l10n, widget.fullName),
      subtitle: l10n.clientIdValue(formatClientId(widget.clientId)),
      children: [
        _TierBadge(uid: widget.uid),
        const SizedBox(height: 12),
        // Snabbval: två i bredd på mobil, fyra på bred skärm.
        LayoutBuilder(
          builder: (context, box) {
            final columns = box.maxWidth < 560 ? 2 : 4;
            final width = (box.maxWidth - 10 * (columns - 1)) / columns;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final (icon, color, label, onTap) in [
                  (
                    Icons.send_outlined,
                    AppColors.primary,
                    l10n.sendMoney,
                    () => widget.onSelect(widget.sendIndex),
                  ),
                  (
                    Icons.shopping_cart_outlined,
                    AppColors.warning,
                    l10n.tabBuy,
                    () => widget.onSelect(widget.buyIndex),
                  ),
                  (
                    Icons.sell_outlined,
                    AppColors.info,
                    l10n.tabSell,
                    () => widget.onSelect(widget.sellIndex),
                  ),
                  (
                    Icons.currency_exchange,
                    AppColors.textMuted,
                    '${l10n.tabExchange} · ${l10n.soonBadge}',
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.comingSoon(l10n.tabExchange)),
                      ),
                    ),
                  ),
                ])
                  SizedBox(
                    width: width,
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onTap,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(icon, color: color),
                              const SizedBox(height: 8),
                              Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          stream: _transactions,
          builder: (context, snap) {
            if (snap.hasError) {
              return Text(l10n.errorWithDetails('${snap.error}'));
            }
            final docs = (snap.data ?? const [])
                .where((d) => d.data()['archived'] != true)
                .toList();
            DateTime at(Map<String, dynamic> d) =>
                (d['createAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            docs.sort((a, b) => at(b.data()).compareTo(at(a.data())));
            int count(String status) =>
                docs.where((d) => d.data()['status'] == status).length;
            void openList() => widget.onSelect(widget.transactionsIndex);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StatRow(
                  stats: [
                    StatData(
                      l10n.statWaitingForYou,
                      '${count('manager_proposed')}',
                      AppColors.warning,
                      onTap: openList,
                    ),
                    StatData(
                      l10n.statReadyForPickup,
                      '${count('payment_confirmed')}',
                      AppColors.success,
                      onTap: openList,
                    ),
                    StatData(
                      l10n.statAll,
                      '${docs.length}',
                      AppColors.info,
                      onTap: openList,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListPanel(
                  title: l10n.recentTransactions,
                  emptyText: snap.hasData ? l10n.noTransactionsYet : '',
                  rows: [
                    for (final d in docs.take(5))
                      StatusRow(
                        title: [
                          formatTransactionNo(d.data()['transactionNo']),
                          transactionSummary(l10n, d.data()),
                        ].where((t) => t.isNotEmpty).join(' · '),
                        status: customerStatusText(
                          l10n,
                          '${d.data()['status']}',
                        ),
                        color: statusColor('${d.data()['status']}'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerTransactionDetailScreen(
                              transactionId: d.id,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
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
              padding: EdgeInsets.zero,
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
