import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../screens/auth_gate.dart';
import '../../services/cashier_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/balances.dart';
import '../../utils/merged_query.dart';
import '../../widgets/action_card.dart';
import '../../widgets/language_button.dart';
import '../pages/cashier_send_page.dart';
import '../pages/cashier_transfers_page.dart';
import '../widgets/transfer_list.dart';

/// Kassörens startsida: saldo per valuta och kort för att skicka, ta emot
/// och se överföringar.
class CashierHomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cashierAppBarTitle),
        actions: [
          const LanguageButton(),
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => signOutToLogin(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: CashierService.directory(uid).snapshots(),
        builder: (context, dirSnap) {
          if (dirSnap.hasError) {
            return Center(
              child: Text(l10n.errorWithDetails('${dirSnap.error}')),
            );
          }
          if (!dirSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!dirSnap.data!.exists) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.cashierNotSetUp, textAlign: TextAlign.center),
              ),
            );
          }
          final me = CashierEntry.fromDoc(dirSnap.data!);

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: CashierService.cashier(uid).snapshots(),
            builder: (context, cashSnap) {
              final balances = parseBalances(
                cashSnap.data?.data()?['balances'],
                officeId: uid,
              );
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeName(me.name),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (me.officeLabel.isNotEmpty ||
                        me.managerName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (me.officeLabel.isNotEmpty)
                            l10n.officeValue(me.officeLabel),
                          if (me.managerName.isNotEmpty)
                            l10n.managerValue(me.managerName),
                        ].join('  ·  '),
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                    const SizedBox(height: 16),
                    BalancesCard(balances: balances),
                    const SizedBox(height: 20),
                    ActionCardGrid(
                      children: [
                        ActionCard(
                          icon: Icons.send_outlined,
                          iconColor: AppColors.primary,
                          title: l10n.sendMoney,
                          subtitle: l10n.cashierSendSubtitle,
                          badge: '+',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CashierSendPage(me: me, balances: balances),
                            ),
                          ),
                        ),
                        StreamBuilder<
                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                        >(
                          stream: myTransfers(uid),
                          builder: (context, snap) {
                            final docs = snap.data ?? const [];
                            final incoming = docs
                                .where(
                                  (d) =>
                                      d.data()['toId'] == uid &&
                                      d.data()['status'] == 'pending',
                                )
                                .length;
                            return ActionCard(
                              icon: Icons.move_to_inbox_outlined,
                              iconColor: AppColors.warning,
                              title: l10n.incomingTransfers,
                              subtitle: incoming > 0
                                  ? l10n.incomingWaiting(incoming)
                                  : l10n.incomingSubtitle,
                              badge: snap.hasData ? '$incoming' : '…',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CashierTransfersPage(
                                    cashierId: uid,
                                    onlyIncomingPending: true,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        ActionCard(
                          icon: Icons.receipt_long_outlined,
                          iconColor: AppColors.info,
                          title: l10n.myTransfers,
                          subtitle: l10n.myTransfersSubtitle,
                          badge: '≡',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CashierTransfersPage(cashierId: uid),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
