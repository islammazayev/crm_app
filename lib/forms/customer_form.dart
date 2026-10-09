import 'package:flutter/material.dart';

class CustomerForm extends StatefulWidget {
  final Future<void> Function({
    int? clientId,
    required String firstName,
    required String lastName,
    required String phone,
    String email,
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
          const SnackBar(content: Text('Klient-ID måste vara ett heltal')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kund sparad!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skapa / uppdatera kund',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _clientIdController,
            decoration: const InputDecoration(
              labelText: 'Klient-ID (valfritt)',
              hintText: 't.ex. 007',
            ),
            keyboardType: TextInputType.number,
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
                      (v == null || v.trim().isEmpty)
                          ? 'Ange efternamn'
                          : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Telefon'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'E-post'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Spara kund'),
          ),
        ],
      ),
    );
  }
}
