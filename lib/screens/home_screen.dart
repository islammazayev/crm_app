import 'package:flutter/material.dart';
import '../l10n/locale_controller.dart';
import 'auth_gate.dart';
import '../services/user_role_service.dart';
import '../admin/screens/admin_home_screen.dart';
import '../manager/screens/manager_home_screen.dart';
import '../customer/screens/customer_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole?>(
      future: UserRoleService.getCurrentUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    snapshot.hasError
                        ? context.l10n.errorWithDetails('${snapshot.error}')
                        : context.l10n.noRoleFound,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => signOutToLogin(context),
                    child: Text(context.l10n.logout),
                  ),
                ],
              ),
            ),
          );
        }

        final role = snapshot.data;
        if (role == UserRole.admin) {
          return const AdminHomeScreen();
        } else if (role == UserRole.manager) {
          return const ManagerHomeScreen();
        } else {
          return const CustomerHomeScreen();
        }
      },
    );
  }
}
