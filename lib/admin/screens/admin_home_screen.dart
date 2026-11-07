import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../l10n/status_text.dart';
import '../../screens/settings_page.dart';
import '../../services/cashier_service.dart';
import '../../services/currency_migration_service.dart';
import '../../services/customer_counter_service.dart';
import '../../services/office_listing_service.dart';
import '../../services/transaction_number_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import '../../utils/client_id.dart';
import '../../utils/transaction_kind.dart';
import '../../utils/transaction_no.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/overview_widgets.dart';
import '../pages/admin_cashiers_page.dart';
import '../pages/admin_customers_page.dart';
import '../pages/admin_managers_page.dart';
import '../pages/admin_offices_page.dart';
import '../pages/admin_orders_page.dart';
import '../pages/admin_tiers_page.dart';

/// Adminens app: meny med översikt och alla områden.
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _shell = GlobalKey<AppShellState>();

  @override
  void initState() {
    super.initState();
    _selfHeal();
  }

  /// Rättar data som kan ha hamnat fel: publika kontorsposter som saknas
  /// och en kundräknare som ligger efter redan utdelade klient-ID:n.
  Future<void> _selfHeal() async {
    // Varje steg körs för sig, så att ett fel i det ena inte stoppar det andra,
    // och så att loggen visar vilket steg som misslyckades.
    try {
      await OfficeListingService.syncAll();
    } catch (e) {
      debugPrint('Självläkning (officeListings) misslyckades: $e');
    }
    try {
      await CurrencyMigrationService.run();
    } catch (e) {
      debugPrint('Självläkning (valutakoder) misslyckades: $e');
    }
    try {
      await CustomerCounterService.ensureAtLeastMax();
    } catch (e) {
      debugPrint('Självläkning (kundräknare) misslyckades: $e');
    }
    try {
      await CashierService.backfillCashOffice();
    } catch (e) {
      debugPrint('Självläkning (kassörernas kontor) misslyckades: $e');
    }
    try {
      await TransactionNumberService.backfill();
    } catch (e) {
      debugPrint('Självläkning (transaktionsnummer) misslyckades: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppShell(
      key: _shell,
      destinations: [
        ShellDestination(
          icon: Icons.home_outlined,
          label: l10n.overview,
          builder: (_) => _AdminOverview(onSelect: _select),
        ),
        ShellDestination(
          icon: Icons.receipt_long_outlined,
          label: l10n.orderHistory,
          builder: (_) => const AdminOrdersPage(),
        ),
        ShellDestination(
          icon: Icons.people_outline,
          label: l10n.customers,
          builder: (_) => const AdminCustomersPage(),
        ),
        ShellDestination(
          icon: Icons.storefront_outlined,
          label: l10n.offices,
          builder: (_) => const AdminOfficesPage(),
        ),
        ShellDestination(
          icon: Icons.badge_outlined,
          label: l10n.managers,
          builder: (_) => const AdminManagersPage(),
        ),
        ShellDestination(
          icon: Icons.point_of_sale,
          label: l10n.cashiers,
          builder: (_) => const AdminCashiersPage(),
        ),
        ShellDestination(
          icon: Icons.handshake_outlined,
          label: l10n.partners,
          builder: (_) => const AdminCashiersPage(type: StaffType.partner),
        ),
        ShellDestination(
          icon: Icons.workspace_premium_outlined,
          label: l10n.customerTiers,
          builder: (_) => const AdminTiersPage(),
        ),
        ShellDestination(
          icon: Icons.settings_outlined,
          label: l10n.settingsTitle,
          builder: (_) => const SettingsPage(),
        ),
      ],
    );
  }

  void _select(int index) => _shell.currentState?.select(index);
}

/// Adminens översikt: allt saldo, antal och de senaste transaktionerna.
class _AdminOverview extends StatefulWidget {
  final ValueChanged<int> onSelect;

  const _AdminOverview({required this.onSelect});

  @override
  State<_AdminOverview> createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<_AdminOverview> {
  final _db = FirebaseFirestore.instance;
  late final _offices = _db.collection('offices').snapshots();
  late final _officeCount = _db.collection('offices').snapshots();
  late final _cashiers = _db.collection('cashiers').snapshots();
  late final _customers = _db.collection('customers').snapshots();
  late final _transactions = _db.collection('transactions').snapshots();

  // Platser i menyn (se AdminHomeScreen).
  static const _ordersIndex = 1;
  static const _customersIndex = 2;
  static const _officesIndex = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OverviewPage(
      title: l10n.adminPanel,
      subtitle: l10n.adminOverviewSubtitle,
      children: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _offices,
          builder: (context, officeSnap) =>
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _cashiers,
                builder: (context, cashSnap) => BalanceHero(
                  title: l10n.adminTotalBalance,
                  onTap: () => widget.onSelect(_officesIndex),
                  balances: sumBalances([
                    for (final d in [
                      ...?officeSnap.data?.docs,
                      ...?cashSnap.data?.docs,
                    ])
                      parseBalances(d.data()['balances'], officeId: d.id),
                  ]),
                ),
              ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _transactions,
          builder: (context, txSnap) {
            if (txSnap.hasError) {
              return Text(l10n.errorWithDetails('${txSnap.error}'));
            }
            final docs = (txSnap.data?.docs ?? const [])
                .where((d) => d.data()['archived'] != true)
                .toList();
            DateTime at(Map<String, dynamic> d) =>
                (d['createAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            docs.sort((a, b) => at(b.data()).compareTo(at(a.data())));
            final open = docs
                .where(
                  (d) => !const [
                    'completed',
                    'customer_rejected',
                  ].contains(d.data()['status']),
                )
                .length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _customers,
                  builder: (context, custSnap) =>
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _officeCount,
                        builder: (context, officeSnap) => StatRow(
                          stats: [
                            StatData(
                              l10n.customers,
                              '${custSnap.data?.docs.length ?? '…'}',
                              AppColors.primary,
                              onTap: () => widget.onSelect(_customersIndex),
                            ),
                            StatData(
                              l10n.offices,
                              '${officeSnap.data?.docs.length ?? '…'}',
                              AppColors.info,
                              onTap: () => widget.onSelect(_officesIndex),
                            ),
                            StatData(
                              l10n.statOngoing,
                              '$open',
                              AppColors.warning,
                              onTap: () => widget.onSelect(_ordersIndex),
                            ),
                          ],
                        ),
                      ),
                ),
                const SizedBox(height: 12),
                ListPanel(
                  title: l10n.recentTransactions,
                  emptyText: txSnap.hasData ? l10n.noTransactionsYet : '',
                  rows: [
                    for (final d in docs.take(8))
                      StatusRow(
                        date: (d.data()['createAt'] as Timestamp?)?.toDate(),
                        title: [
                          formatTransactionNo(d.data()['transactionNo']),
                          if ('${d.data()['clientId'] ?? ''}'.isNotEmpty)
                            formatClientId(d.data()['clientId']),
                          '${d.data()['customerName'] ?? ''}'.trim(),
                        ].where((t) => t.isNotEmpty).join(' · '),
                        subtitle: transactionSummary(l10n, d.data()),
                        status: statusText(l10n, '${d.data()['status']}'),
                        color: statusColor('${d.data()['status']}'),
                        onTap: () => widget.onSelect(_ordersIndex),
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
