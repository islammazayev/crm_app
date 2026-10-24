import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../screens/cashier_home_screen.dart';
import '../widgets/transfer_list.dart';

/// Kassörens egna överföringar, eller bara inkommande som väntar.
class CashierTransfersPage extends StatelessWidget {
  final String cashierId;
  final bool onlyIncomingPending;

  const CashierTransfersPage({
    super.key,
    required this.cashierId,
    this.onlyIncomingPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          onlyIncomingPending ? l10n.incomingTransfers : l10n.myTransfers,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TransferList(
          cashierId: cashierId,
          actorId: cashierId,
          onlyIncomingPending: onlyIncomingPending,
          stream: CashierHomeScreen.myTransfers(cashierId),
        ),
      ),
    );
  }
}
