import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerList extends StatelessWidget {
  final List<Customer> customers;
  final void Function(int index)? onDelete;

  const CustomerList({
    super.key,
    required this.customers,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Inga kunder ännu."),
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
              Text("Telefon: ${c.phone}"),
              if (c.email.isNotEmpty) Text("E-post: ${c.email}"),
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
                        title: const Text('Ta bort kund'),
                        content: Text(
                          'Vill du verkligen ta bort #$idText '
                          '${c.firstName} ${c.lastName}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Avbryt'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Ta bort'),
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
