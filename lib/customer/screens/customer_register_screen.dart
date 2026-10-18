import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils/client_id.dart';
import '../../widgets/customer_welcome_screen.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    User? createdUser;

    try {
      final email = _emailCtrl.text.trim();
      final firstName = _firstNameCtrl.text.trim();
      final lastName = _lastNameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();

      // 1. Skapa auth-konto
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _passwordCtrl.text.trim(),
      );
      createdUser = cred.user;
      final uid = cred.user!.uid;

      final db = FirebaseFirestore.instance;

      // 2. Skapa users/{uid} med role: customer
      await db.collection('users').doc(uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'role': 'customer',
        'createAt': FieldValue.serverTimestamp(),
      });

      // 3. Hämta nästa klient-ID från den gemensamma räknaren och skapa
      //    customers/{uid} i samma transaktion, så att två kunder aldrig
      //    kan få samma ID.
      final metaRef = db.collection('meta').doc('customers');
      final customerRef = db.collection('customers').doc(uid);

      final int clientId = await db.runTransaction<int>((tx) async {
        final snap = await tx.get(metaRef);
        final last = (snap.data()?['lastClientId'] as num?)?.toInt() ?? 0;
        final next = last + 1;

        tx.set(metaRef, {'lastClientId': next}, SetOptions(merge: true));
        tx.set(customerRef, {
          'clientId': next,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'userId': uid,
          'createAt': FieldValue.serverTimestamp(),
        });

        return next;
      });

      final fullName = '$firstName $lastName'.trim();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => CustomerWelcomeScreen(
            clientId: formatClientId(clientId),
            fullName: fullName,
            phone: phone,
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fel vid registrering: ${e.message}')),
      );
    } catch (e) {
      // Något gick fel efter att kontot skapats: ta bort det halvfärdiga
      // kontot så att personen kan försöka igen med samma e-postadress.
      try {
        await createdUser?.delete();
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte skapa kund: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrera dig som kund')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Förnamn'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ange förnamn' : null,
              ),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Efternamn'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ange efternamn' : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'E‑post'),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Ange giltig e‑post' : null,
              ),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Telefon'),
              ),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Lösenord'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 6 ? 'Minst 6 tecken' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _registerCustomer,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Registrera'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
