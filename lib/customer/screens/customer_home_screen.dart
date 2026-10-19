import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/locale_controller.dart';
import '../../widgets/customer_welcome_screen.dart';
import '../../widgets/language_button.dart';
import 'customer_register_screen.dart';


class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  bool _loading = true;
  /// Felet översätts först när det visas (språket kan bytas under tiden).
  String Function(AppLocalizations l10n)? _error;
  String? _clientId;
  String? _fullName;
  String? _phone;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = (l10n) => l10n.noSignedInUser;
          _loading = false;
        });
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('customers')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        setState(() {
          _loading = false;
        });
      } else {
        final data = snap.docs.first.data();
        final first = data['firstName'] as String? ?? '';
        final last = data['lastName'] as String? ?? '';
        final phone = data['phone'] as String? ?? '';

        setState(() {
          _clientId = data['clientId']?.toString();
          _fullName = '$first $last'.trim();
          _phone = phone;
          _loading = false;
        });

      }
    } catch (e) {
      setState(() {
        _error = (l10n) => l10n.couldNotLoadCustomer('$e');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.customerAppBarTitle),
          actions: [
            const LanguageButton(),
            IconButton(
              tooltip: context.l10n.logout,
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: Center(child: Text(_error!(context.l10n))),
      );
    }

if (_clientId != null && _fullName != null && _phone != null) {
  return CustomerWelcomeScreen(
    clientId: _clientId!,
    fullName: _fullName!,
    phone: _phone!,
  );
}

    // Skulle bara hända om du manuellt skapat user utan customer
    return const CustomerRegisterScreen();
  }
}
