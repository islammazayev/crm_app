import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateManagerForm extends StatefulWidget {
  final List<QueryDocumentSnapshot> officeDocs;

  const CreateManagerForm({
    super.key,
    required this.officeDocs,
  });

  @override
  State<CreateManagerForm> createState() => _CreateManagerFormState();
}

class _CreateManagerFormState extends State<CreateManagerForm> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedOfficeId;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    if (widget.officeDocs.isNotEmpty) {
      _selectedOfficeId = widget.officeDocs.first.id;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createManager() async {
    if (!_formKey.currentState!.validate() || _selectedOfficeId == null) {
      print('CreateManager: validation failed or no office selected');
      return;
    }

    setState(() => _creating = true);
    print('CreateManager: starting');

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      print('CreateManager: calling createUserWithEmailAndPassword');
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = cred.user!.uid;
      print('CreateManager: got uid $uid');

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'role': 'manager',
        'officeId': _selectedOfficeId,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'createAt': FieldValue.serverTimestamp(),
      });
      print('CreateManager: user doc created in Firestore');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Manager skapad. Du är nu inloggad som den nya användaren.'),
        ),
      );

      _formKey.currentState!.reset();
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      print('CreateManager: form cleared');
    } on FirebaseAuthException catch (e) {
      print('CreateManager: FirebaseAuthException ${e.code} ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte skapa manager: ${e.message}')),
      );
    } catch (e) {
      print('CreateManager: unexpected error $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oväntat fel: $e')),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
      print('CreateManager: finished');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.officeDocs.isEmpty) {
      return const Text('Skapa minst ett kontor innan du lägger till manager.');
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skapa ny manager',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Förnamn'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ange förnamn' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Efternamn'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ange efternamn' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'E-post'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ange e-post' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Telefon'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Lösenord'),
            obscureText: true,
            validator: (v) =>
                (v == null || v.length < 6) ? 'Minst 6 tecken' : null,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedOfficeId,
            items: [
              for (final doc in widget.officeDocs)
                DropdownMenuItem(
                  value: doc.id,
                  child: Text('${doc['country']} – ${doc['city']}'),
                ),
            ],
            onChanged: (v) => setState(() => _selectedOfficeId = v),
            decoration: const InputDecoration(labelText: 'Kontor'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _creating ? null : _createManager,
            icon: _creating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_add),
            label: const Text('Skapa manager'),
          ),
        ],
      ),
    );
  }
}
