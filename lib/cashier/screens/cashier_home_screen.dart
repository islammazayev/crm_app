import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../screens/auth_gate.dart';
import '../../screens/settings_page.dart';
import '../../services/cashier_service.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import '../../utils/merged_query.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/chat.dart';
import '../../widgets/overview_widgets.dart';
import '../../widgets/role_switch.dart';
import '../pages/cashier_cash_payments_page.dart';
import '../pages/cashier_send_page.dart';
import '../pages/cashier_transfers_page.dart';

/// Kassörens app: meny med översikt, överföringar, kontanta inbetalningar,
/// meddelanden och inställningar.
class CashierHomeScreen extends StatefulWidget {
  const CashierHomeScreen({super.key});

  /// Skickade av mig och skickade till mig (en fråga per villkor, så att
  /// reglerna kan godkänna dem).
  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> myTransfers(
    String uid,
  ) => mergedQuery([
    CashierService.transfers.where('fromId', isEqualTo: uid),
    CashierService.transfers.where('toId', isEqualTo: uid),
  ]);

  @override
  State<CashierHomeScreen> createState() => _CashierHomeScreenState();
}

class _CashierHomeScreenState extends State<CashierHomeScreen> {
  final _shell = GlobalKey<AppShellState>();
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  late final _directory = CashierService.directory(_uid).snapshots();
  late final _cashier = CashierService.cashier(_uid).snapshots();
  late final _user = FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .snapshots();
  final _chats = ChatService.myChats();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<DocumentSnapshot>(
      stream: _directory,
      builder: (context, dirSnap) {
        if (dirSnap.hasError || (dirSnap.hasData && !dirSnap.data!.exists)) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.cashierAppBarTitle),
              actions: [
                IconButton(
                  tooltip: l10n.logout,
                  icon: const Icon(Icons.logout),
                  onPressed: () => signOutToLogin(context),
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  dirSnap.hasError
                      ? l10n.errorWithDetails('${dirSnap.error}')
                      : l10n.cashierNotSetUp,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (!dirSnap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final me = CashierEntry.fromDoc(dirSnap.data!);
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _cashier,
          builder: (context, cashSnap) {
            if (!cashSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final data = cashSnap.data!.data();
            final balances = parseBalances(data?['balances'], officeId: _uid);
            // Kontoret där kassören tar emot kontanta inbetalningar.
            final String? cashOfficeId =
                me.officeId ?? data?['cashOfficeId'] as String?;
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _user,
              builder: (context, userSnap) =>
                  StreamBuilder<
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>
                  >(
                    stream: _chats,
                    builder: (context, chatSnap) {
                      final unread = (chatSnap.data ?? const [])
                          .where((d) => ChatService.isUnread(d.data()))
                          .length;
                      return AppShell(
                        key: _shell,
                        primaryAction: ShellAction(
                          icon: Icons.add,
                          label: l10n.sendMoney,
                          onTap: () => _shell.currentState?.push(
                            CashierSendPage(me: me, balances: balances),
                          ),
                        ),
                        extraActions: [
                          if (userSnap.data?.data()?['role'] == 'manager' &&
                              userSnap.data?.data()?['alsoCashier'] == true)
                            ShellAction(
                              icon: Icons.swap_horiz,
                              label: l10n.switchToManager,
                              onTap: () =>
                                  switchRole(context, toCashier: false),
                            ),
                        ],
                        destinations: [
                          ShellDestination(
                            icon: Icons.home_outlined,
                            label: l10n.overview,
                            builder: (_) => _CashierOverview(
                              uid: _uid,
                              me: me,
                              cashOfficeId: cashOfficeId,
                            ),
                          ),
                          ShellDestination(
                            icon: Icons.sync_alt,
                            label: l10n.myTransfers,
                            builder: (_) =>
                                CashierTransfersPage(cashierId: _uid),
                          ),
                          if (cashOfficeId != null)
                            ShellDestination(
                              icon: Icons.payments_outlined,
                              label: l10n.cashPaymentsTitle,
                              builder: (_) => CashierCashPaymentsPage(
                                officeId: cashOfficeId,
                              ),
                            ),
                          ShellDestination(
                            icon: Icons.forum_outlined,
                            label: l10n.messagesTitle,
                            badge: unread,
                            builder: (_) => const MessagesPage(),
                          ),
                          ShellDestination(
                            icon: Icons.settings_outlined,
                            label: l10n.settingsTitle,
                            builder: (_) => const SettingsPage(),
                          ),
                        ],
                      );
                    },
                  ),
            );
          },
        );
      },
    );
  }
}

class _CashierOverview extends StatefulWidget {
  final String uid;
  final CashierEntry me;
  final String? cashOfficeId;

  const _CashierOverview({
    required this.uid,
    required this.me,
    required this.cashOfficeId,
  });

  @override
  State<_CashierOverview> createState() => _CashierOverviewState();
}

class _CashierOverviewState extends State<_CashierOverview> {
  late final _cashier = CashierService.cashier(widget.uid).snapshots();
  late final _transfers = CashierHomeScreen.myTransfers(widget.uid);
  late final _cash = widget.cashOfficeId == null
      ? Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>.value(
          const [],
        )
      : CashierCashPaymentsPage.waiting(widget.cashOfficeId!);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final me = widget.me;
    final where = [
      if (me.officeLabel.isNotEmpty) me.officeLabel,
      if (me.managerName.isNotEmpty) l10n.managerValue(me.managerName),
    ].join('  ·  ');
    return OverviewPage(
      title: greetingFor(l10n, me.name),
      subtitle: where,
      children: [
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _cashier,
          builder: (context, snap) {
            final balances = parseBalances(
              snap.data?.data()?['balances'],
              officeId: widget.uid,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BalanceHero(title: l10n.cashBalance, balances: balances),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send_outlined),
                    label: Text(l10n.sendMoney),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CashierSendPage(me: me, balances: balances),
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
          stream: _transfers,
          builder: (context, transferSnap) {
            final incoming = (transferSnap.data ?? const [])
                .where(
                  (d) =>
                      d.data()['toId'] == widget.uid &&
                      d.data()['status'] == 'pending',
                )
                .toList();
            return StreamBuilder<
              List<QueryDocumentSnapshot<Map<String, dynamic>>>
            >(
              stream: _cash,
              builder: (context, cashSnap) {
                final cash = cashSnap.data ?? const [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StatRow(
                      stats: [
                        StatData(
                          l10n.incomingTransfers,
                          '${incoming.length}',
                          AppColors.warning,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CashierTransfersPage(
                                cashierId: widget.uid,
                                onlyIncomingPending: true,
                              ),
                            ),
                          ),
                        ),
                        StatData(
                          l10n.cashPaymentsTitle,
                          '${cash.length}',
                          AppColors.success,
                          onTap: widget.cashOfficeId == null
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CashierCashPaymentsPage(
                                      officeId: widget.cashOfficeId!,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListPanel(
                      title: l10n.needsYouNow,
                      emptyText: l10n.nothingNeedsYou,
                      rows: [
                        for (final d in incoming)
                          StatusRow(
                            title: l10n.transferFrom(
                              '${d.data()['fromName'] ?? ''}',
                            ),
                            subtitle:
                                '${((d.data()['amount'] ?? 0) as num).toStringAsFixed(2)} ${d.data()['currency'] ?? ''}',
                            status: l10n.incomingTransfers,
                            color: AppColors.warning,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CashierTransfersPage(
                                  cashierId: widget.uid,
                                  onlyIncomingPending: true,
                                ),
                              ),
                            ),
                          ),
                        for (final d in cash)
                          StatusRow(
                            title: '${d.data()['customerName'] ?? ''}',
                            subtitle: l10n.customerPaysCashAmount(
                              ((d.data()['amountFrom'] ?? 0) as num)
                                  .toStringAsFixed(2),
                              '${d.data()['fromCurrency'] ?? ''}',
                            ),
                            status: l10n.cashPaymentsTitle,
                            color: AppColors.success,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CashierCashPaymentsPage(
                                  officeId: widget.cashOfficeId!,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
