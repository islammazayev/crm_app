import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../widgets/trade_section.dart';

/// Kunden köper eller säljer valuta via ett kontor, kontant eller via banken.
class CustomerTradePage extends StatelessWidget {
  final TradeKind kind;

  const CustomerTradePage({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(kind == TradeKind.buy ? l10n.tabBuy : l10n.tabSell),
      ),
      body: TradeSection(kind: kind),
    );
  }
}
