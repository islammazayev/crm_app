import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../cashier/widgets/transfer_list.dart' show BalancesCard;
import '../../l10n/locale_controller.dart';
import '../../screens/auth_gate.dart';
import '../../services/partner_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import '../../utils/currencies.dart';
import '../../widgets/chat.dart';
import '../../widgets/language_button.dart';
import '../../widgets/partner_exchanges.dart';

/// Partnerns startsida: saldo, nytt växlingsförslag till kontoret och
/// alla växlingar. Ingen avgift och ingen vinst, bara växling.
class PartnerHomeScreen extends StatelessWidget {
  const PartnerHomeScreen({super.key});

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
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.partnerAppBarTitle),
        actions: [
          const LanguageButton(),
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => signOutToLogin(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: PartnerService.partner(uid).snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text(l10n.errorWithDetails('${snap.error}')));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data!.data();
          final officeId = '${d?['exchangeOfficeId'] ?? ''}';
          if (d == null || officeId.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.partnerNotSetUp, textAlign: TextAlign.center),
              ),
            );
          }
          final name = '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
          final officeLabel = '${d['exchangeOfficeLabel'] ?? ''}';
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.welcomeName(name),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (officeLabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.officeValue(officeLabel),
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 16),
              BalancesCard(
                balances: parseBalances(d['balances'], officeId: uid),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.add_card),
                  label: Text(l10n.adjustBalance),
                  onPressed: () => _adjustBalance(
                    context,
                    uid,
                    parseBalances(d['balances'], officeId: uid),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.currency_exchange),
                  label: Text(l10n.newExchange),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewExchangePage(
                        side: ExchangeSide.partner,
                        onSubmit: (terms, _, note) => PartnerService.propose(
                          by: ExchangeSide.partner,
                          officeId: officeId,
                          officeLabel: officeLabel,
                          managerId: '',
                          partnerId: uid,
                          partnerName: name,
                          terms: terms,
                          note: note,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const MessagesCard(),
              const SizedBox(height: 24),
              SectionHeader(title: l10n.exchangesTitle),
              const SizedBox(height: 10),
              PartnerExchangeList(
                stream: PartnerService.exchangesForPartner(uid),
                side: ExchangeSide.partner,
              ),
            ],
          );
        },
      ),
    );
  }
}
