import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_role_service.dart';
import '../admin/screens/admin_home_screen.dart';
import '../manager/screens/manager_home_screen.dart';
//import '../manager/screens/manager_home_page.dart';
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
                        ? 'Fel: ${snapshot.error}'
                        : 'Ingen roll hittades för användaren',
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text('Logga ut'),
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
