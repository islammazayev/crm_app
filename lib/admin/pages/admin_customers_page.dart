import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../sections/admin_customers_section.dart';

/// Admin: skapa, söka, ändra och ta bort kunder.
class AdminCustomersPage extends StatelessWidget {
  const AdminCustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.customers)),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: AdminCustomersSection(),
      ),
    );
  }
}
