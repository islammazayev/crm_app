import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';

class CustomerForm extends StatefulWidget {
  final Future<void> Function({
    int? clientId,
    required String firstName,
    required String lastName,
    required String phone,
    String email,
  })
  onSubmit;

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
    );

    _clientIdController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _phoneController.clear();
    _emailController.clear();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.customerSaved)));
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
            controller: _phoneController,
            decoration: InputDecoration(labelText: l10n.phone),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.email),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _submit, child: Text(l10n.saveCustomer)),
        ],
      ),
    );
  }
}
