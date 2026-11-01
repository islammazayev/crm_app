import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/auth_error_text.dart';
import '../../l10n/locale_controller.dart';
import '../../screens/auth_gate.dart';
import '../../screens/login_screen.dart';
import '../../widgets/language_button.dart';

class CustomerRegisterScreen extends StatefulWidget {
  /// Inbjudan från managern (länk via SMS). Kunden tar då över sin
  /// befintliga kundpost och behåller klient-ID och nivå.
  final ({String docId, String code})? invite;

  const CustomerRegisterScreen({super.key, this.invite});

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

  /// Den inbjudna kundposten (läses med ID:t i länken).
  Map<String, dynamic>? _invited;
  bool _inviteInvalid = false;

  @override
  void initState() {
    super.initState();
    if (widget.invite != null) _loadInvite();
  }

  Future<void> _loadInvite() async {
    final invite = widget.invite!;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('customers')
          .doc(invite.docId)
          .get();
      final d = snap.data();
      if (!mounted) return;
      if (d == null || d['inviteCode'] != invite.code) {
        setState(() => _inviteInvalid = true);
        return;
      }
      setState(() {
        _invited = d;
        _firstNameCtrl.text = '${d['firstName'] ?? ''}';
        _lastNameCtrl.text = '${d['lastName'] ?? ''}';
        _phoneCtrl.text = '${d['phone'] ?? ''}';
      });
    } catch (_) {
      if (mounted) setState(() => _inviteInvalid = true);
    }
  }

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

      final metaRef = db.collection('meta').doc('customers');
      final customerRef = db.collection('customers').doc(uid);
      final invited = _invited;

      if (invited != null) {
        // 3a. Inbjudan: ta över den befintliga kundposten. Klient-ID och
        //     nivå följer med, och den gamla posten tas bort i samma batch.
        final batch = db.batch();
        batch.set(customerRef, {
          'clientId': invited['clientId'],
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'userId': uid,
          'createAt': FieldValue.serverTimestamp(),
          'inviteDocId': widget.invite!.docId,
          'inviteCode': widget.invite!.code,
          if (invited['tier'] != null) 'tier': invited['tier'],
          if (invited['tierDiscount'] != null)
            'tierDiscount': invited['tierDiscount'],
        });
        batch.delete(db.collection('customers').doc(widget.invite!.docId));
        await batch.commit();
        inviteHandled = true;
        if (!mounted) return;
        restartFromAuthGate(context);
        return;
      }

      // 3. Hämta nästa klient-ID från den gemensamma räknaren och skapa
      //    customers/{uid} i samma transaktion, så att två kunder aldrig
      //    kan få samma ID.
      await db.runTransaction<int>((tx) async {
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

      if (!mounted) return;

      // Börja om från startpunkten, som nu visar kundens startsida. Allt är
      // sparat innan dess, så roll och kundpost finns när sidan laddas.
      restartFromAuthGate(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authErrorText(context.l10n, e))));
    } catch (e) {
      // Något gick fel efter att kontot skapats: ta bort det halvfärdiga
      // kontot så att personen kan försöka igen med samma e-postadress.
      try {
        await createdUser?.delete();
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.couldNotCreateCustomer('$e'))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerTitle),
        actions: const [LanguageButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.invite != null) ...[
                Text(
                  _inviteInvalid
                      ? l10n.inviteInvalid
                      : l10n.inviteWelcome(
                          _invited == null ? '' : '${_invited!['clientId']}',
                        ),
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      inviteHandled = true;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: Text(l10n.alreadyHaveAccountLogin),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _firstNameCtrl,
                decoration: InputDecoration(labelText: l10n.firstName),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.enterFirstName : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: InputDecoration(labelText: l10n.lastName),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.enterLastName : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(labelText: l10n.email),
                validator: (v) =>
                    v == null || !v.contains('@') ? l10n.enterValidEmail : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneCtrl,
                decoration: InputDecoration(labelText: l10n.phone),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(labelText: l10n.password),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 6 ? l10n.passwordMinLength : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _loading ||
                          (widget.invite != null &&
                              _invited == null &&
                              !_inviteInvalid)
                      ? null
                      : _registerCustomer,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.register),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
