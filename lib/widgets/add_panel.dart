import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';

/// En knapp, t.ex. "+ Lägg till kund", som öppnar ett formulär i ett kort.
/// [builder] får en funktion som stänger kortet; anropa den när något har
/// sparats.
class AddPanel extends StatefulWidget {
  final String label;
  final Widget Function(BuildContext context, VoidCallback close) builder;

  const AddPanel({super.key, required this.label, required this.builder});

  @override
  State<AddPanel> createState() => _AddPanelState();
}

class _AddPanelState extends State<AddPanel> {
  bool _open = false;

  void _close() {
    if (mounted) setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_open) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(widget.label),
          onPressed: () => setState(() => _open = true),
        ),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: context.l10n.cancel,
                icon: const Icon(Icons.close),
                onPressed: _close,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: widget.builder(context, _close),
            ),
          ],
        ),
      ),
    );
  }
}
