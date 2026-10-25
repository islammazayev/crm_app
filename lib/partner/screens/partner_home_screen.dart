import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../cashier/widgets/transfer_list.dart' show BalancesCard;
import '../../l10n/locale_controller.dart';
import '../../screens/auth_gate.dart';
import '../../services/partner_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import '../../widgets/language_button.dart';
import '../../widgets/partner_exchanges.dart';

/// Kompanjonens startsida: saldo, nytt växlingsförslag till kontoret och
/// alla växlingar. Ingen avgift och ingen vinst, bara växling.
class PartnerHomeScreen extends StatelessWidget {
  const PartnerHomeScreen({super.key});

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
