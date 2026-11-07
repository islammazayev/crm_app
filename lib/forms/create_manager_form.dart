import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/auth_error_text.dart';
import '../services/account_creator.dart';
import '../services/cashier_service.dart';
import '../l10n/locale_controller.dart';

class CreateManagerForm extends StatefulWidget {
  final List<QueryDocumentSnapshot> officeDocs;

  /// Anropas när managern är skapad (t.ex. för att stänga formuläret).
  final VoidCallback? onCreated;

  const CreateManagerForm({super.key, required this.officeDocs, this.onCreated});

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

  /// Managern är också kassör på kontoret (egen kassa).
  bool _alsoCashier = false;

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

  /// Skapar en manager utan att admin loggas ut.
  ///
  /// `createUserWithEmailAndPassword` loggar in den nya användaren på den
  /// FirebaseApp den anropas på. Därför skapas kontot på en tillfällig,
  /// sekundär app-instans. Admin förblir inloggad på standardinstansen och
  /// skriver sedan `users/{uid}` som admin (reglerna tillåter bara admin att
  /// skapa användare med rollen manager).
  Future<void> _createManager() async {
    if (!_formKey.currentState!.validate() || _selectedOfficeId == null) {
      return;
    }

    setState(() => _creating = true);

    try {
      await createAccountAsAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        writeProfile: (uid) async {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'email': _emailController.text.trim(),
            'role': 'manager',
            'officeId': _selectedOfficeId,
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'createAt': FieldValue.serverTimestamp(),
          });
          if (_alsoCashier) {
            await CashierService.setManagerAlsoCashier(
              uid: uid,
              enabled: true,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              officeId: _selectedOfficeId,
              officeLabel: officeLabelOf(widget.officeDocs, _selectedOfficeId),
            );
          }
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.managerCreated)));

      _formKey.currentState!.reset();
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      setState(() => _alsoCashier = false);
      widget.onCreated?.call();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.couldNotCreateManager(authErrorText(context.l10n, e)),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.unexpectedError('$e'))),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (widget.officeDocs.isEmpty) {
      return Text(l10n.createOfficeBeforeManager);
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.createNewManager,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: l10n.firstName),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.enterFirstName
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: l10n.lastName),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.enterLastName
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.email),
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.enterEmail : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: l10n.phone),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: l10n.password),
            obscureText: true,
            validator: (v) =>
                (v == null || v.length < 6) ? l10n.passwordMinLength : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedOfficeId),
            initialValue: _selectedOfficeId,
            items: [
              for (final doc in widget.officeDocs)
                DropdownMenuItem(
                  value: doc.id,
                  child: Text('${doc['country']} – ${doc['city']}'),
                ),
            ],
            onChanged: (v) => setState(() => _selectedOfficeId = v),
            decoration: InputDecoration(labelText: l10n.office),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _alsoCashier,
            onChanged: (v) => setState(() => _alsoCashier = v ?? false),
            title: Text(l10n.alsoCashier),
            subtitle: Text(l10n.alsoCashierHint),
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
            label: Text(l10n.createManager),
          ),
        ],
      ),
    );
  }
}

/// "Land – Stad" för kontoret med [officeId], eller tomt.
String officeLabelOf(List<QueryDocumentSnapshot> officeDocs, String? officeId) {
  for (final o in officeDocs) {
    if (o.id == officeId) {
      final d = o.data() as Map<String, dynamic>;
      return '${d['country'] ?? ''} – ${d['city'] ?? ''}';
    }
  }
  return '';
}
