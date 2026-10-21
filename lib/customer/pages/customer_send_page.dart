import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../widgets/send_section.dart';

/// Kunden skickar pengar via ett kontor.
class CustomerSendPage extends StatelessWidget {
  const CustomerSendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.sendMoney)),
      body: const SendSection(),
    );
  }
}
