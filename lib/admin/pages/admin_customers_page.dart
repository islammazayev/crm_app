import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../sections/admin_customers_section.dart';

/// Admin: skapa, söka, ändra och ta bort kunder.
class AdminCustomersPage extends StatelessWidget {
  /// Nivå att filtrera på från början (t.ex. från Kundnivåer).
  final String? initialTier;

  const AdminCustomersPage({super.key, this.initialTier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.customers)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AdminCustomersSection(initialTier: initialTier),
      ),
    );
  }
}
