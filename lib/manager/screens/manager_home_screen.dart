import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../screens/auth_gate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/action_card.dart';
import '../../widgets/language_button.dart';
import '../pages/manager_cashiers_page.dart';
import '../pages/manager_create_transaction_screen.dart';
import '../pages/manager_transactions_detail_screen.dart';
import '../pages/manager_transactions_page.dart';
import '../pages/pickup_scanner_page.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  String _officeLabel = '';
  String? _officeId;

  @override
  void initState() {
    super.initState();
    _loadOfficeLabel();
  }

  /// Hämtar land och stad för managerns kontor till rubriken.
  Future<void> _loadOfficeLabel() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final db = FirebaseFirestore.instance;

      final userSnap = await db.collection('users').doc(user.uid).get();
      final officeId = userSnap.data()?['officeId']?.toString();
      if (officeId == null || officeId.isEmpty) return;
      if (mounted) setState(() => _officeId = officeId);

      final listing = await db.collection('officeListings').doc(officeId).get();
      final data = listing.data();
      if (data == null) return;

      final label = [
        data['country'],
        data['city'],
      ].map((e) => (e ?? '').toString()).where((e) => e.isNotEmpty).join(' – ');
      if (mounted) setState(() => _officeLabel = label);
    } catch (_) {
      // Rubriken är bara en bekvämlighet, fel här ska inte störa något.
    }
  }

  /// Skannar kundens QR-kod och öppnar transaktionen, som själv kontrollerar
  /// nyckeln och frågar om utbetalning. Transaktioner från andra kontor går
  /// inte att läsa (reglerna) och stoppas här.
  Future<void> _scanPickup(BuildContext context) async {
    final l10n = context.l10n;
    final result = await Navigator.push<({String transactionId, String token})>(
      context,
      MaterialPageRoute(builder: (_) => const PickupScannerPage()),
    );
    if (result == null || !context.mounted) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(result.transactionId)
          .get();
      final status = snap.data()?['status'];
      if (!context.mounted) return;
      if (!snap.exists || status != 'payment_confirmed') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.qrNotReadyForPayout)));
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManagerTransactionDetailScreen(
            transactionId: result.transactionId,
            scannedToken: result.token,
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.qrOtherOffice)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _officeLabel.isEmpty
              ? l10n.managerAppBarTitle
              : l10n.managerAppBarTitleWithOffice(_officeLabel),
        ),
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
            SectionHeader(title: l10n.managerPanel),
            const SizedBox(height: 8),
            Text(
              l10n.managerPanelIntro,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            if (_officeId == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .where('officeId', isEqualTo: _officeId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final counts = <String, int>{};
                  for (final d in snapshot.data?.docs ?? const []) {
                    if ((d.data() as Map<String, dynamic>)['archived'] ==
                        true) {
                      continue;
                    }
                    final status =
                        (d.data() as Map<String, dynamic>)['status']
                            ?.toString() ??
                        '';
                    counts[status] = (counts[status] ?? 0) + 1;
                  }
                  int count(List<String> statuses) => statuses.fold(
                    0,
                    (total, st) => total + (counts[st] ?? 0),
                  );

                  const newStatuses = ['customer_requested'];
                  const ongoingStatuses = [
                    'manager_proposed',
                    'customer_countered',
                    'customer_accepted',
                    'customer_paid',
                    'payment_confirmed',
                  ];
                  const doneStatuses = ['completed', 'customer_rejected'];
                  final officeId = _officeId!;

                  void open(String title, List<String> statuses) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManagerTransactionsPage(
                          officeId: officeId,
                          statuses: statuses,
                          title: title,
                        ),
                      ),
                    );
                  }

                  return ActionCardGrid(
                    children: [
                      StreamBuilder<
                        List<QueryDocumentSnapshot<Map<String, dynamic>>>
                      >(
                        stream: ManagerCashiersPage.cashiers(
                          FirebaseAuth.instance.currentUser?.uid ?? '',
                          officeId,
                        ),
                        builder: (context, cashSnap) => ActionCard(
                          icon: Icons.point_of_sale,
                          iconColor: AppColors.primary,
                          title: l10n.myCashiers,
                          subtitle: l10n.myCashiersSubtitle,
                          badge: cashSnap.hasData
                              ? '${cashSnap.data!.length}'
                              : '…',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ManagerCashiersPage(
                                managerId:
                                    FirebaseAuth.instance.currentUser?.uid ??
                                    '',
                                officeId: officeId,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ActionCard(
                        icon: Icons.qr_code_scanner,
                        iconColor: AppColors.success,
                        title: l10n.scanPickup,
                        subtitle: l10n.scanPickupSubtitle,
                        badge: 'QR',
                        onTap: () => _scanPickup(context),
                      ),
                      ActionCard(
                        icon: Icons.add_circle_outline,
                        iconColor: AppColors.primary,
                        title: l10n.createNewTransaction,
                        subtitle: l10n.createTransactionCardSubtitle,
                        badge: '+',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ManagerCreateTransactionScreen(
                                officeId: officeId,
                              ),
                            ),
                          );
                        },
                      ),
                      ActionCard(
                        icon: Icons.mark_email_unread_outlined,
                        iconColor: AppColors.warning,
                        title: l10n.newCustomerTransactions,
                        subtitle: l10n.newCustomerTransactionsSubtitle,
                        badge: '${count(newStatuses)}',
                        onTap: () =>
                            open(l10n.newCustomerTransactions, newStatuses),
                      ),
                      ActionCard(
                        icon: Icons.sync_alt,
                        iconColor: AppColors.info,
                        title: l10n.ongoingTransactions,
                        subtitle: l10n.ongoingTransactionsSubtitle,
                        badge: '${count(ongoingStatuses)}',
                        onTap: () =>
                            open(l10n.ongoingTransactions, ongoingStatuses),
                      ),
                      ActionCard(
                        icon: Icons.task_alt,
                        iconColor: AppColors.success,
                        title: l10n.finishedTransactions,
                        subtitle: l10n.finishedTransactionsSubtitle,
                        badge: '${count(doneStatuses)}',
                        onTap: () =>
                            open(l10n.finishedTransactions, doneStatuses),
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
