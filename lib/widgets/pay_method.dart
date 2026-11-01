import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/locale_controller.dart';
import '../theme/app_theme.dart';

/// Hur kunden betalar: kontant på kontoret eller via bank. Sparas som
/// `payMethod` i transaktionen; saknas det gäller bank (som förut).
enum PayMethod { cash, bank }

PayMethod payMethodOf(Map<String, dynamic> data) =>
    data['payMethod'] == 'cash' ? PayMethod.cash : PayMethod.bank;

/// Val av betalsätt med en förklaring under.
class PayMethodPicker extends StatelessWidget {
  final PayMethod value;
  final ValueChanged<PayMethod> onChanged;

  /// Managern registrerar en kund på kontoret (texterna talar om kunden).
  final bool forManager;

  const PayMethodPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.forManager = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          forManager ? l10n.howDoesCustomerPay : l10n.howDoYouPay,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SegmentedButton<PayMethod>(
          segments: [
            ButtonSegment(
              value: PayMethod.cash,
              icon: const Icon(Icons.storefront_outlined),
              label: Text(l10n.payCashAtOffice),
            ),
            ButtonSegment(
              value: PayMethod.bank,
              icon: const Icon(Icons.account_balance_outlined),
              label: Text(l10n.payViaBank),
            ),
          ],
          selected: {value},
          onSelectionChanged: (v) => onChanged(v.first),
        ),
        const SizedBox(height: 8),
        Text(
          forManager
              ? (value == PayMethod.cash
                    ? l10n.walkInCashHint
                    : l10n.walkInBankHint)
              : (value == PayMethod.cash ? l10n.payCashHint : l10n.payBankHint),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

/// Kontorets adress och kartlänk för en kund som betalar kontant
/// (från officeListings, som admin fyller i).
class OfficeAddressCard extends StatelessWidget {
  final String officeId;
  final String title;

  const OfficeAddressCard({
    super.key,
    required this.officeId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('officeListings')
          .doc(officeId)
          .snapshots(),
      builder: (context, snap) {
        final d = snap.data?.data() ?? const {};
        final place = [
          '${d['city'] ?? ''}',
          '${d['country'] ?? ''}',
        ].where((s) => s.isNotEmpty).join(' – ');
        final address = '${d['address'] ?? ''}'.trim();
        final mapUrl = '${d['mapUrl'] ?? ''}'.trim();
        return Card(
          margin: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Liten informationsrad, inte en rubrik.
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (place.isNotEmpty)
                  Text(
                    place,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                SelectableText(
                  address.isEmpty ? l10n.officeAddressMissing : address,
                ),
                if (mapUrl.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.map_outlined),
                    label: Text(l10n.openMap),
                    onPressed: () => launchUrl(
                      Uri.parse(mapUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
