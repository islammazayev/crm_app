import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../screens/auth_gate.dart';
import '../../screens/settings_page.dart';
import '../../services/chat_service.dart';
import '../../services/partner_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import '../../utils/currencies.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/chat.dart';
import '../../widgets/overview_widgets.dart';
import '../../widgets/partner_exchanges.dart';

/// Partnerns app: meny med översikt, växlingar, meddelanden och
/// inställningar. Ingen avgift och ingen vinst, bara växling.
class PartnerHomeScreen extends StatefulWidget {
  const PartnerHomeScreen({super.key});

  @override
  State<PartnerHomeScreen> createState() => _PartnerHomeScreenState();
}

class _PartnerHomeScreenState extends State<PartnerHomeScreen> {
  final _shell = GlobalKey<AppShellState>();
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  late final _partner = PartnerService.partner(_uid).snapshots();
  late final _exchanges = PartnerService.exchangesForPartner(_uid);
  final _chats = ChatService.myChats();

  NewExchangePage _newExchange(String officeId, String label, String name) =>
      NewExchangePage(
        side: ExchangeSide.partner,
        onSubmit: (terms, _, note) => PartnerService.propose(
          by: ExchangeSide.partner,
          officeId: officeId,
          officeLabel: label,
          managerId: '',
          partnerId: _uid,
          partnerName: name,
          terms: terms,
          note: note,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _partner,
      builder: (context, snap) {
        final d = snap.data?.data();
        final officeId = '${d?['exchangeOfficeId'] ?? ''}';
        if (snap.hasError ||
            (snap.hasData && (d == null || officeId.isEmpty))) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.partnerAppBarTitle),
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
                  snap.hasError
                      ? l10n.errorWithDetails('${snap.error}')
                      : l10n.partnerNotSetUp,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final name = '${d!['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
        final officeLabel = '${d['exchangeOfficeLabel'] ?? ''}';
        return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          stream: _chats,
          builder: (context, chatSnap) {
            final unread = (chatSnap.data ?? const [])
                .where((c) => ChatService.isUnread(c.data()))
                .length;
            return StreamBuilder<
              List<QueryDocumentSnapshot<Map<String, dynamic>>>
            >(
              stream: _exchanges,
              builder: (context, exSnap) {
                final open = (exSnap.data ?? const [])
                    .where(
                      (e) => const [
                        'proposed',
                        'accepted',
                      ].contains(e.data()['status']),
                    )
                    .length;
                return AppShell(
                  key: _shell,
                  mobileCount: 3,
                  primaryAction: ShellAction(
                    icon: Icons.add,
                    label: l10n.newExchange,
                    onTap: () => _shell.currentState?.push(
                      _newExchange(officeId, officeLabel, name),
                    ),
                  ),
                  destinations: [
                    ShellDestination(
                      icon: Icons.home_outlined,
                      label: l10n.overview,
                      builder: (_) => _PartnerOverview(
                        uid: _uid,
                        name: name,
                        officeLabel: officeLabel,
                        newExchange: () =>
                            _newExchange(officeId, officeLabel, name),
                      ),
                    ),
                    ShellDestination(
                      icon: Icons.currency_exchange,
                      label: l10n.exchangesTitle,
                      badge: open,
                      builder: (_) => _PartnerExchangesPage(uid: _uid),
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
            );
          },
        );
      },
    );
  }
}

class _PartnerExchangesPage extends StatefulWidget {
  final String uid;

  const _PartnerExchangesPage({required this.uid});

  @override
  State<_PartnerExchangesPage> createState() => _PartnerExchangesPageState();
}

class _PartnerExchangesPageState extends State<_PartnerExchangesPage> {
  late final _exchanges = PartnerService.exchangesForPartner(widget.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.exchangesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PartnerExchangeList(stream: _exchanges, side: ExchangeSide.partner),
        ],
      ),
    );
  }
}

class _PartnerOverview extends StatefulWidget {
  final String uid;
  final String name;
  final String officeLabel;
  final NewExchangePage Function() newExchange;

  const _PartnerOverview({
    required this.uid,
    required this.name,
    required this.officeLabel,
    required this.newExchange,
  });

  @override
  State<_PartnerOverview> createState() => _PartnerOverviewState();
}

class _PartnerOverviewState extends State<_PartnerOverview> {
  late final _partner = PartnerService.partner(widget.uid).snapshots();
  late final _open = PartnerService.exchangesForPartner(widget.uid);

  /// Fyll på (eller dra av, med minus) eget saldo i en valuta.
  Future<void> _adjustBalance(
    BuildContext context,
    String uid,
    Map<String, double> balances,
  ) async {
    final l10n = context.l10n;
    String currency = kSupportedCurrencies.first;
    final amountCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l10n.adjustBalance),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: currency,
                decoration: InputDecoration(labelText: l10n.currency),
                items: [
                  for (final c in kSupportedCurrencies)
                    DropdownMenuItem(
                      value: c,
                      child: Text(
                        '$c  (${(balances[c] ?? 0).toStringAsFixed(2)})',
                      ),
                    ),
                ],
                onChanged: (v) => setLocal(() => currency = v ?? currency),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  helperText: l10n.adjustBalanceHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.ok),
            ),
          ],
        ),
      ),
    );
    final amount =
        double.tryParse(amountCtrl.text.trim().replaceAll(',', '.')) ?? 0;
    amountCtrl.dispose();
    if (ok != true || amount == 0 || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if ((balances[currency] ?? 0) + amount < 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.balanceWouldBeNegative)),
      );
      return;
    }
    try {
      await PartnerService.adjustOwnBalance(uid, currency, amount);
      messenger.showSnackBar(SnackBar(content: Text(l10n.balanceUpdated)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.errorWithDetails('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OverviewPage(
      title: greetingFor(l10n, widget.name),
      subtitle: widget.officeLabel.isEmpty
          ? ''
          : l10n.officeValue(widget.officeLabel),
      action: ElevatedButton.icon(
        icon: const Icon(Icons.currency_exchange),
        label: Text(l10n.newExchange),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => widget.newExchange()),
        ),
      ),
      children: [
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _partner,
          builder: (context, snap) {
            final balances = parseBalances(
              snap.data?.data()?['balances'],
              officeId: widget.uid,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BalanceHero(title: l10n.cashBalance, balances: balances),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add_card),
                    label: Text(l10n.adjustBalance),
                    onPressed: () =>
                        _adjustBalance(context, widget.uid, balances),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          l10n.needsYouNow,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        PartnerExchangeList(
          stream: _open,
          side: ExchangeSide.partner,
          onlyOpen: true,
        ),
      ],
    );
  }
}
