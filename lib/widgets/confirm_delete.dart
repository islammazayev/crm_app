import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';

/// Frågar innan något raderas. Ger true bara om användaren bekräftar.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final l10n = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.deleteAction),
        ),
      ],
    ),
  );
  return ok == true;
}
