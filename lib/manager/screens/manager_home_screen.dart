import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../screens/auth_gate.dart';
import '../../screens/settings_page.dart';
import '../../services/chat_service.dart';
import '../../services/partner_service.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/chat.dart';
import '../pages/manager_balances_page.dart';
import '../pages/manager_cashiers_page.dart';
import '../pages/manager_overview_page.dart';
import '../pages/manager_partners_page.dart';
import '../pages/manager_transactions_page.dart';

/// Managerns app: meny (sidomeny eller bottenmeny) med översikt,
/// transaktioner, saldo, meddelanden, kassörer, partner och inställningar.
class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  final _shell = GlobalKey<AppShellState>();
  final _transactionTab = ValueNotifier<int>(0);
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _loading = true;
  String _name = '';
  String _officeLabel = '';
  String? _officeId;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _transactions;
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>? _exchanges;
  final _chats = ChatService.myChats();

  // Menyns ordning; de fyra första syns i bottenmenyn på mobil.
  static const _transactionsIndex = 1;
  static const _balancesIndex = 2;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _transactionTab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final db = FirebaseFirestore.instance;
    try {
      final user = (await db.collection('users').doc(_uid).get()).data();
      _name = '${user?['firstName'] ?? ''}'.trim();
      _officeId = user?['officeId']?.toString();
      final officeId = _officeId;
      if (officeId != null && officeId.isNotEmpty) {
        final listing =
            (await db.collection('officeListings').doc(officeId).get()).data();
        _officeLabel = [
          listing?['country'],
          listing?['city'],
        ].map((e) => '${e ?? ''}').where((e) => e.isNotEmpty).join(' – ');
        _transactions = db
            .collection('transactions')
            .where('officeId', isEqualTo: officeId)
            .snapshots();
        _exchanges = PartnerService.exchangesForOffice(officeId);
      }
    } catch (e) {
      debugPrint('Kunde inte läsa managerns kontor: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final officeId = _officeId;
    if (_loading || officeId == null || officeId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.managerAppBarTitle),
          actions: [
            IconButton(
              tooltip: l10n.logout,
              icon: const Icon(Icons.logout),
              onPressed: () => signOutToLogin(context),
            ),
          ],
        ),
        body: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : Text(l10n.noOfficeAssigned),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _transactions,
      builder: (context, txSnap) {
        final newCount = (txSnap.data?.docs ?? const [])
            .where(
              (d) =>
                  d.data()['archived'] != true &&
                  ManagerTransactionTabs.newStatuses.contains(
                    d.data()['status'],
                  ),
            )
            .length;
        return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          stream: _chats,
          builder: (context, chatSnap) {
            final unread = (chatSnap.data ?? const [])
                .where((d) => ChatService.isUnread(d.data()))
                .length;
            return StreamBuilder<
              List<QueryDocumentSnapshot<Map<String, dynamic>>>
            >(
              stream: _exchanges,
              builder: (context, exSnap) {
                final openExchanges = (exSnap.data ?? const [])
                    .where(
                      (d) => const [
                        'proposed',
                        'accepted',
                      ].contains(d.data()['status']),
                    )
                    .length;
                return AppShell(
                  key: _shell,
                  destinations: [
                    ShellDestination(
                      icon: Icons.home_outlined,
                      label: l10n.overview,
                      builder: (_) => ManagerOverviewPage(
                        managerId: _uid,
                        managerName: _name,
                        officeId: officeId,
                        officeLabel: _officeLabel,
                        onOpenTransactions: (tab) {
                          _transactionTab.value = tab;
                          _shell.currentState?.select(_transactionsIndex);
                        },
                        onOpenBalances: () =>
                            _shell.currentState?.select(_balancesIndex),
                      ),
                    ),
                    ShellDestination(
                      icon: Icons.sync_alt,
                      label: l10n.transactions,
                      badge: newCount,
                      builder: (_) => ManagerTransactionTabs(
                        officeId: officeId,
                        tab: _transactionTab,
                      ),
                    ),
                    ShellDestination(
                      icon: Icons.account_balance_wallet_outlined,
                      label: l10n.balancesTitle,
                      builder: (_) => ManagerBalancesPage(
                        managerId: _uid,
                        officeId: officeId,
                        officeLabel: _officeLabel,
                      ),
                    ),
                    ShellDestination(
                      icon: Icons.forum_outlined,
                      label: l10n.messagesTitle,
                      badge: unread,
                      builder: (_) => const MessagesPage(),
                    ),
                    ShellDestination(
                      icon: Icons.point_of_sale,
                      label: l10n.myCashiers,
                      builder: (_) => ManagerCashiersPage(
                        managerId: _uid,
                        officeId: officeId,
                      ),
                    ),
                    ShellDestination(
                      icon: Icons.handshake_outlined,
                      label: l10n.partners,
                      badge: openExchanges,
                      builder: (_) => ManagerPartnersPage(
                        managerId: _uid,
                        officeId: officeId,
                        officeLabel: _officeLabel,
                      ),
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
          },
        );
      },
    );
  }
}
