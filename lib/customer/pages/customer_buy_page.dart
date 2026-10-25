import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../widgets/buy_section.dart';

/// Kunden köper valuta via ett kontor, kontant eller till sin bank.
class CustomerBuyPage extends StatelessWidget {
  const CustomerBuyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tabBuy)),
      body: const BuySection(),
    );
  }
}
