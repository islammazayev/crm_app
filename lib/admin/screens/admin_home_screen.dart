import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../services/currency_migration_service.dart';
import '../../services/customer_counter_service.dart';
import '../../services/office_listing_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/action_card.dart';
import '../../widgets/language_button.dart';
import '../pages/admin_customers_page.dart';
import '../pages/admin_managers_page.dart';
import '../pages/admin_offices_page.dart';
import '../pages/admin_orders_page.dart';

/// Adminens startsida: ett kort per område, som på managerns startsida.
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    _selfHeal();
  }

  /// Rättar data som kan ha hamnat fel: publika kontorsposter som saknas
  /// och en kundräknare som ligger efter redan utdelade klient-ID:n.
  Future<void> _selfHeal() async {
    // Varje steg körs för sig, så att ett fel i det ena inte stoppar det andra,
    // och så att loggen visar vilket steg som misslyckades.
    try {
      await OfficeListingService.syncAll();
    } catch (e) {
      debugPrint('Självläkning (officeListings) misslyckades: $e');
    }
    try {
      await CurrencyMigrationService.run();
    } catch (e) {
      debugPrint('Självläkning (valutakoder) misslyckades: $e');
    }
    try {
      await CustomerCounterService.ensureAtLeastMax();
    } catch (e) {
      debugPrint('Självläkning (kundräknare) misslyckades: $e');
    }
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminAppBarTitle),
        actions: [
          const LanguageButton(),
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: l10n.adminPanel),
            const SizedBox(height: 8),
            Text(
              l10n.adminPanelIntro,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 760;
                return GridView.count(
                  crossAxisCount: isWide ? 2 : 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 2.5 : 2.1,
                  children: [
                    _CountCard(
                      query: db.collection('customers'),
                      icon: Icons.people_outline,
                      iconColor: AppColors.primary,
                      title: l10n.customers,
                      subtitle: l10n.customersCardSubtitle,
                      onTap: () => _open(const AdminCustomersPage()),
                    ),
                    _CountCard(
                      query: db.collection('offices'),
                      icon: Icons.storefront_outlined,
                      iconColor: AppColors.info,
                      title: l10n.offices,
                      subtitle: l10n.officesCardSubtitle,
                      onTap: () => _open(const AdminOfficesPage()),
                    ),
                    _CountCard(
                      query: db
                          .collection('users')
                          .where('role', isEqualTo: 'manager'),
                      icon: Icons.badge_outlined,
                      iconColor: AppColors.warning,
                      title: l10n.managers,
                      subtitle: l10n.managersCardSubtitle,
                      onTap: () => _open(const AdminManagersPage()),
                    ),
                    _CountCard(
                      query: db.collection('transactions'),
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppColors.success,
                      title: l10n.orderHistory,
                      subtitle: l10n.ordersCardSubtitle,
                      onTap: () => _open(const AdminOrdersPage()),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// [ActionCard] med antalet dokument i [query] som etikett.
class _CountCard extends StatelessWidget {
  final Query query;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CountCard({
    required this.query,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length;
        return ActionCard(
          icon: icon,
          iconColor: iconColor,
          title: title,
          subtitle: subtitle,
          badge: count == null ? '…' : '$count',
          onTap: onTap,
        );
      },
    );
  }
}
