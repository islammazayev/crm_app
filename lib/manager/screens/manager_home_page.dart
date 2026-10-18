import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/manager_transactions_page.dart';

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  String? _officeId;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadManagerOffice();
  }

  Future<void> _loadManagerOffice() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Ingen inloggad användare.';
          _loading = false;
        });
        return;
      }
      final userId = user.uid;

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final data = snap.data();
      if (data == null) {
        setState(() {
          _error = 'Ingen user‑profil hittades.';
          _loading = false;
        });
        return;
      }

      if (data['role'] != 'manager') {
        setState(() {
          _error = 'Endast manager har tillgång till denna sida.';
          _loading = false;
        });
        return;
      }

      final officeId = data['officeId']?.toString();
      if (officeId == null || officeId.isEmpty) {
        setState(() {
          _error = 'Ingen officeId satt på manager‑profilen.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _officeId = officeId;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Fel vid hämtning av manager: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manager')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manager')),
        body: Center(child: Text(_error!)),
      );
    }

    return ManagerTransactionsPage(officeId: _officeId!);
  }
}
