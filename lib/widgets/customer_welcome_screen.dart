import 'package:flutter/material.dart';

import '../customer/widgets/send_section.dart';
import '../customer/screens/customer_transactions_screen.dart';

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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CRM – Customer'),
          actions: [
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Mina transaktioner',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerTransactionsScreen(),
                  ),
                );
              },
            ),
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
                    'Välkommen, $fullName',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text('Telefon: $phone'),
                  const SizedBox(height: 4),
                  Text('Klient‑ID: $clientId'),
                ],
              ),
            ),
            const Divider(height: 1),

            const TabBar(
              tabs: [
                Tab(text: 'Skicka'),
                Tab(text: 'Köpa'),
                Tab(text: 'Sälja'),
                Tab(text: 'Växla'),
              ],
            ),

            const Expanded(
              child: TabBarView(
                children: [
                  SendSection(),
                  Center(child: Text('Köpa – innehåll kommer senare')),
                  Center(child: Text('Sälja – innehåll kommer senare')),
                  Center(child: Text('Växla – innehåll kommer senare')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
