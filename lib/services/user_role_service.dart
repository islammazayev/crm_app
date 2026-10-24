import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { admin, manager, customer, cashier }

class UserRoleService {
  static Future<UserRole?> getCurrentUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final role = snap.data()?['role'] as String?;
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'customer':
        return UserRole.customer;
      case 'cashier':
        return UserRole.cashier;
      default:
        return null;
    }
  }
}
