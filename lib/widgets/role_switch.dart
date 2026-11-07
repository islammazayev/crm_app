import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../cashier/screens/cashier_home_screen.dart';
import '../l10n/locale_controller.dart';
import '../manager/screens/manager_home_screen.dart';
import '../screens/auth_gate.dart';
import '../theme/app_theme.dart';
import 'action_card.dart';
import 'language_button.dart';

Stream<DocumentSnapshot<Map<String, dynamic>>> _me() => FirebaseFirestore
    .instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
    .snapshots();

/// Byter mellan manager- och kassörsmenyn.
void switchRole(BuildContext context, {required bool toCashier}) => _open(
  context,
  toCashier ? const CashierHomeScreen() : const ManagerHomeScreen(),
);

void _open(BuildContext context, Widget home) {
  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => home),
    (route) => false,
  );
}

/// Startpunkt för en manager: är managern också kassör väljer hen först
/// vilken meny hen vill använda.
class ManagerEntry extends StatelessWidget {
  const ManagerEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _me(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snap.data!.data()?['alsoCashier'] == true
            ? const RoleChooserScreen()
            : const ManagerHomeScreen();
      },
    );
  }
}

/// Val mellan manager- och kassörsmenyn efter inloggning.
class RoleChooserScreen extends StatelessWidget {
  const RoleChooserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chooseRoleTitle),
        actions: [
          const LanguageButton(),
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => signOutToLogin(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chooseRoleIntro,
              style: TextStyle(color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 20),
            ActionCardGrid(
              children: [
                ActionCard(
                  icon: Icons.badge_outlined,
                  iconColor: AppColors.warning,
                  title: l10n.roleManager,
                  subtitle: l10n.roleManagerSubtitle,
                  badge: '→',
                  onTap: () => _open(context, const ManagerHomeScreen()),
                ),
                ActionCard(
                  icon: Icons.point_of_sale,
                  iconColor: AppColors.primary,
                  title: l10n.roleCashier,
                  subtitle: l10n.roleCashierSubtitle,
                  badge: '→',
                  onTap: () => _open(context, const CashierHomeScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
