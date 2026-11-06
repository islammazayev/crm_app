import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../l10n/status_text.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import '../../utils/transaction_kind.dart';
import '../../utils/transaction_no.dart';
import '../../widgets/overview_widgets.dart';
import 'manager_cashiers_page.dart';
import 'manager_create_transaction_screen.dart';
import 'manager_transactions_detail_screen.dart';
import 'manager_transactions_page.dart';
import 'pickup_scanner_page.dart';

/// Managerns startsida: totalt saldo, läget just nu och det som väntar på
/// managern.
class ManagerOverviewPage extends StatefulWidget {
  final String managerId;
  final String managerName;
  final String officeId;
  final String officeLabel;

  /// Öppnar transaktionerna på en flik (se [ManagerTransactionTabs]).
  final ValueChanged<int> onOpenTransactions;
  final VoidCallback onOpenBalances;

  const ManagerOverviewPage({
    super.key,
    required this.managerId,
    required this.managerName,
    required this.officeId,
    required this.officeLabel,
    required this.onOpenTransactions,
    required this.onOpenBalances,
  });

  @override
  State<ManagerOverviewPage> createState() => _ManagerOverviewPageState();
}

class _ManagerOverviewPageState extends State<ManagerOverviewPage> {
  late final _db = FirebaseFirestore.instance;
  late final _office = _db
      .collection('offices')
      .doc(widget.officeId)
      .snapshots();
  late final _cashiers = ManagerCashiersPage.cashiers(
    widget.managerId,
    widget.officeId,
  );
  late final _transactions = _db
      .collection('transactions')
      .where('officeId', isEqualTo: widget.officeId)
      .snapshots();

  /// Statusar där nästa steg ligger hos kontoret.
  static const _needsManager = [
    'customer_requested',
    'customer_countered',
    'customer_accepted',
    'customer_paid',
    'payment_confirmed',
  ];

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Skannar kundens QR-kod och öppnar transaktionen för utbetalning.
  /// Transaktioner från andra kontor går inte att läsa (reglerna).
  Future<void> _scanPickup() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final result = await Navigator.push<({String transactionId, String token})>(
      context,
      MaterialPageRoute(builder: (_) => const PickupScannerPage()),
    );
    if (result == null || !mounted) return;
    try {
      final snap = await _db
          .collection('transactions')
          .doc(result.transactionId)
          .get();
      if (!mounted) return;
      if (!snap.exists || snap.data()?['status'] != 'payment_confirmed') {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.qrNotReadyForPayout)),
        );
        return;
      }
      _open(
        ManagerTransactionDetailScreen(
          transactionId: result.transactionId,
          scannedToken: result.token,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.qrOtherOffice)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OverviewPage(
      title: greetingFor(l10n, widget.managerName),
      subtitle: widget.officeLabel,
      action: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(l10n.scanPickup),
            onPressed: _scanPickup,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.newTransactionShort),
            onPressed: () => _open(
              ManagerCreateTransactionScreen(officeId: widget.officeId),
            ),
          ),
        ],
      ),
      children: [
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _office,
          builder: (context, officeSnap) =>
              StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                stream: _cashiers,
                builder: (context, cashSnap) => BalanceHero(
                  title: l10n.totalBalanceTitle,
                  onTap: widget.onOpenBalances,
                  balances: sumBalances([
                    parseBalances(
                      officeSnap.data?.data()?['balances'],
                      officeId: widget.officeId,
                    ),
                    for (final c in cashSnap.data ?? const [])
                      parseBalances(c.data()['balances'], officeId: c.id),
                  ]),
                ),
              ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _transactions,
          builder: (context, snap) {
            if (snap.hasError) {
              return Text(l10n.errorWithDetails('${snap.error}'));
            }
            final docs = (snap.data?.docs ?? const [])
                .where((d) => d.data()['archived'] != true)
                .toList();
            String count(List<String> statuses) =>
                '${docs.where((d) => statuses.contains(d.data()['status'])).length}';
            DateTime at(Map<String, dynamic> d) =>
                (d['createAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final needs =
                docs
                    .where((d) => _needsManager.contains(d.data()['status']))
                    .toList()
                  ..sort((a, b) => at(b.data()).compareTo(at(a.data())));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StatRow(
                  stats: [
                    StatData(
                      l10n.statNew,
                      count(ManagerTransactionTabs.newStatuses),
                      AppColors.warning,
                      onTap: () => widget.onOpenTransactions(0),
                    ),
                    StatData(
                      l10n.statOngoing,
                      count(ManagerTransactionTabs.ongoingStatuses),
                      AppColors.info,
                      onTap: () => widget.onOpenTransactions(1),
                    ),
                    StatData(
                      l10n.statDone,
                      count(ManagerTransactionTabs.doneStatuses),
                      AppColors.success,
                      onTap: () => widget.onOpenTransactions(2),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListPanel(
                  title: l10n.needsYouNow,
                  emptyText: snap.hasData ? l10n.nothingNeedsYou : '',
                  rows: [
                    for (final d in needs.take(8))
                      StatusRow(
                        title: [
                          formatTransactionNo(d.data()['transactionNo']),
                          '${d.data()['customerName'] ?? ''}'.trim(),
                        ].where((t) => t.isNotEmpty).join(' · '),
                        subtitle: transactionSummary(l10n, d.data()),
                        status: statusText(l10n, '${d.data()['status']}'),
                        color: statusColor('${d.data()['status']}'),
                        onTap: () => _open(
                          ManagerTransactionDetailScreen(transactionId: d.id),
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
