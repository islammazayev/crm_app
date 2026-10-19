import 'package:flutter/material.dart';

import '../customer/widgets/send_section.dart';
import '../l10n/locale_controller.dart';
import '../utils/client_id.dart';
import '../customer/screens/customer_transactions_screen.dart';
import 'language_button.dart';

class CustomerWelcomeScreen extends StatelessWidget {
  final String clientId;
  final String fullName;
  final String phone;

  const CustomerWelcomeScreen({
    super.key,
    required this.clientId,
    required this.fullName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.customerAppBarTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: l10n.myTransactions,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerTransactionsScreen(),
                  ),
                );
              },
            ),
            const LanguageButton(),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kundinfo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.welcomeName(fullName),
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.phoneValue(phone)),
                  const SizedBox(height: 4),
                  Text(l10n.clientIdValue(formatClientId(clientId))),
                ],
              ),
            ),
            const Divider(height: 1),

            TabBar(
              tabs: [
                Tab(text: l10n.tabSend),
                Tab(text: l10n.tabBuy),
                Tab(text: l10n.tabSell),
                Tab(text: l10n.tabExchange),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  const SendSection(),
                  Center(child: Text(l10n.comingSoon(l10n.tabBuy))),
                  Center(child: Text(l10n.comingSoon(l10n.tabSell))),
                  Center(child: Text(l10n.comingSoon(l10n.tabExchange))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
