import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

    try {
      // 1. Skapa auth‑konto
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      // 2. Skapa users/{uid} med role: customer
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': _emailCtrl.text.trim(),
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'role': 'customer',
        'createAt': FieldValue.serverTimestamp(),
      });

      // 3. Räkna fram nästa clientId (001, 002, 003 ...)
      final snap =
          await FirebaseFirestore.instance.collection('customers').get();
      final nextNumber = (snap.docs.length + 1).toString().padLeft(3, '0');
      final clientId = nextNumber;

      // 4. Skapa customers‑post kopplad till userId
      await FirebaseFirestore.instance.collection('customers').add({
        'clientId': clientId,
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'userId': uid,
        'createAt': FieldValue.serverTimestamp(),
      });

      final fullName =
          '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}';
      final phone = _phoneCtrl.text.trim();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => CustomerWelcomeScreen(
            clientId: clientId,
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
