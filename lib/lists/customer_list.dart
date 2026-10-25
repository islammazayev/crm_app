import 'package:flutter/material.dart';
import '../l10n/locale_controller.dart';
import '../models/customer.dart';

class CustomerList extends StatelessWidget {
  final List<Customer> customers;
  final void Function(int index)? onDelete;

  const CustomerList({super.key, required this.customers, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (customers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.noCustomersYet),
      );
    }
    return ListView.builder(
      itemCount: customers.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final c = customers[index];
        final idText = c.clientId.toString().padLeft(3, '0');
        return ListTile(
          title: Text("#$idText ${c.firstName} ${c.lastName}"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.phoneValue(c.phone)),
              if (c.email.isNotEmpty) Text(l10n.emailValue(c.email)),
            ],
          ),
          isThreeLine: c.email.isNotEmpty,
          trailing: onDelete == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.deleteCustomerTitle),
                        content: Text(
                          l10n.deleteCustomerConfirm(
                            idText,
                            '${c.firstName} ${c.lastName}',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(l10n.delete),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      onDelete!(index);
                    }
                  },
                ),
        );
      },
    );
  }
}
