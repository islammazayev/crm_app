import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../services/partner_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import '../../widgets/partner_exchanges.dart';
import 'manager_balances_page.dart' show BalanceCard;

/// Managerns kompanjoner: deras saldon, nytt växlingsförslag och alla
/// växlingar för kontoret.
class ManagerPartnersPage extends StatelessWidget {
  final String managerId;
  final String officeId;
  final String officeLabel;

  const ManagerPartnersPage({
    super.key,
    required this.managerId,
    required this.officeId,
    required this.officeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.partners)),
      body: StreamBuilder(
        stream: PartnerService.partnersFor(managerId, officeId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text(l10n.errorWithDetails('${snap.error}')));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          String nameOf(Map<String, dynamic> d) =>
              '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
          final partners = snap.data!
            ..sort((a, b) => nameOf(a.data()).compareTo(nameOf(b.data())));
          final choices = {for (final p in partners) p.id: nameOf(p.data())};

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.currency_exchange),
                  label: Text(l10n.newExchange),
                  onPressed: partners.isEmpty
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewExchangePage(
                              side: ExchangeSide.office,
                              partnerChoices: choices,
                              onSubmit: (terms, partnerId, note) =>
                                  PartnerService.propose(
                                    by: ExchangeSide.office,
                                    officeId: officeId,
                                    officeLabel: officeLabel,
                                    managerId: managerId,
                                    partnerId: partnerId!,
                                    partnerName: choices[partnerId] ?? '',
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
                stream: PartnerService.exchangesForOffice(officeId),
                side: ExchangeSide.office,
              ),
              const SizedBox(height: 24),
              SectionHeader(title: l10n.partnerBalancesTitle),
              const SizedBox(height: 10),
              if (partners.isEmpty)
                Text(
                  l10n.noPartnersLinked,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              for (final p in partners)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BalanceCard(
                    icon: Icons.handshake_outlined,
                    color: AppColors.warning,
                    title: nameOf(p.data()),
                    balances: parseBalances(
                      p.data()['balances'],
                      officeId: p.id,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
