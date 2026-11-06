import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../l10n/status_text.dart';
import '../../screens/auth_gate.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import '../../utils/money_format.dart';
import '../../utils/transaction_kind.dart';
import '../../utils/transaction_no.dart';
import '../../widgets/language_button.dart';
import '../../widgets/role_switch.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.officeLabel),
        actions: [
          const RoleSwitchButton(toCashier: true),
          const LanguageButton(),
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => signOutToLogin(context),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.greeting(widget.managerName),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createNewTransaction),
                    onPressed: () => _open(
                      ManagerCreateTransactionScreen(officeId: widget.officeId),
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(l10n.scanPickup),
                    onPressed: _scanPickup,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _totalBalance(),
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
                  int count(bool Function(String) test) =>
                      docs.where((d) => test('${d.data()['status']}')).length;
                  final needs =
                      docs
                          .where(
                            (d) => _needsManager.contains(d.data()['status']),
                          )
                          .toList()
                        ..sort((a, b) {
                          DateTime at(Map<String, dynamic> d) =>
                              (d['createAt'] as Timestamp?)?.toDate() ??
                              DateTime.now();
                          return at(b.data()).compareTo(at(a.data()));
                        });
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Stat(
                            label: l10n.statNew,
                            value: count(
                              ManagerTransactionTabs.newStatuses.contains,
                            ),
                            color: AppColors.warning,
                            onTap: () => widget.onOpenTransactions(0),
                          ),
                          const SizedBox(width: 10),
                          _Stat(
                            label: l10n.statOngoing,
                            value: count(
                              ManagerTransactionTabs.ongoingStatuses.contains,
                            ),
                            color: AppColors.info,
                            onTap: () => widget.onOpenTransactions(1),
                          ),
                          const SizedBox(width: 10),
                          _Stat(
                            label: l10n.statDone,
                            value: count(
                              ManagerTransactionTabs.doneStatuses.contains,
                            ),
                            color: AppColors.success,
                            onTap: () => widget.onOpenTransactions(2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.needsYouNow,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (snap.hasData && needs.isEmpty)
                        Text(
                          l10n.nothingNeedsYou,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      for (final d in needs.take(8))
                        _NeedsYouRow(
                          data: d.data(),
                          onTap: () => _open(
                            ManagerTransactionDetailScreen(transactionId: d.id),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalBalance() {
    final l10n = context.l10n;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _office,
      builder: (context, officeSnap) =>
          StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            stream: _cashiers,
            builder: (context, cashSnap) {
              final total = sumBalances([
                parseBalances(
                  officeSnap.data?.data()?['balances'],
                  officeId: widget.officeId,
                ),
                for (final c in cashSnap.data ?? const [])
                  parseBalances(c.data()['balances'], officeId: c.id),
              ]);
              final entries = total.entries.where((e) => e.value != 0).toList()
                ..sort((a, b) => a.key.compareTo(b.key));
              return Material(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: widget.onOpenBalances,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.totalBalanceTitle,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (entries.isEmpty)
                          Text(l10n.noBalance)
                        else
                          Wrap(
                            spacing: 20,
                            runSpacing: 6,
                            children: [
                              for (final e in entries)
                                Text(
                                  '${formatMoney(e.value)} ${e.key}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final VoidCallback onTap;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value',
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NeedsYouRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _NeedsYouRow({required this.data, required this.onTap});

  Color get _color => switch (data['status']) {
    'customer_requested' => AppColors.warning,
    'customer_countered' => AppColors.warning,
    'payment_confirmed' => AppColors.success,
    _ => AppColors.info,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          [
            formatTransactionNo(data['transactionNo']),
            '${data['customerName'] ?? ''}'.trim(),
          ].where((t) => t.isNotEmpty).join(' · '),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          transactionSummary(l10n, data),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          constraints: const BoxConstraints(maxWidth: 130),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText(l10n, '${data['status']}'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _color, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
