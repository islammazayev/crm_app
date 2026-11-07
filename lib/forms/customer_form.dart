import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';
import '../widgets/phone_field.dart';

class CustomerForm extends StatefulWidget {
  final Future<void> Function({
    int? clientId,
    required String firstName,
    required String lastName,
    required String phone,
    String email,
    bool sendInvite,
    bool sendEmailInvite,
  }) onSubmit;

  const CustomerForm({super.key, required this.onSubmit});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  /// Skicka länk till appen via SMS (bara när admin själv ger klient-ID
  /// och kunden har telefon).
  bool _sendInvite = true;
  bool _sendEmailInvite = true;

  bool get _canEmailInvite =>
      _clientIdController.text.trim().isNotEmpty &&
      _emailController.text.trim().contains('@');

  bool get _canInvite =>
      _clientIdController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _clientIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    int? clientId;
    if (_clientIdController.text.trim().isNotEmpty) {
      clientId = int.tryParse(_clientIdController.text.trim());
      if (clientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.clientIdMustBeInteger)),
        );
        return;
      }
    }

    await widget.onSubmit(
      clientId: clientId,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      sendInvite: _canInvite && _sendInvite,
      sendEmailInvite: _canEmailInvite && _sendEmailInvite,
    );

    // Formuläret kan redan vara stängt (rutan stängs efter sparat).
    if (!mounted) return;
    _clientIdController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _phoneController.clear();
    _emailController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.customerSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.createUpdateCustomer,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _clientIdController,
            decoration: InputDecoration(
              labelText: l10n.clientIdOptional,
              hintText: l10n.clientIdHint,
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: l10n.firstName),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.enterFirstName : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: l10n.lastName),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? l10n.enterLastName
                          : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PhoneField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: l10n.phone),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.email),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 4),
          // Admin gav klient-ID: kunden kan få en länk och bara skapa
          // lösenord, så att klient-ID:t följer med.
          if (_canInvite)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _sendInvite,
              onChanged: (v) => setState(() => _sendInvite = v ?? false),
              secondary: const Icon(Icons.sms_outlined),
              title: Text(l10n.sendAppInvite),
              subtitle: Text(l10n.adminInviteHintAuto),
            ),
          if (_canEmailInvite)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _sendEmailInvite,
              onChanged: (v) => setState(() => _sendEmailInvite = v ?? false),
              secondary: const Icon(Icons.email_outlined),
              title: Text(l10n.sendAppInviteEmail),
              subtitle: Text(l10n.adminInviteEmailHint),
            ),
          if (!_canInvite &&
              !_canEmailInvite &&
              _clientIdController.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.adminInvitePhoneHint,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _submit,
            child: Text(l10n.saveCustomer),
          ),
        ],
      ),
    );
  }
}
