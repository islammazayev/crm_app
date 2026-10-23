import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/receipt_service.dart';

/// Knapp som öppnar ett kvitto i en ny flik.
///
/// Länken hämtas i förväg när knappen visas. Webbläsare (särskilt Safari)
/// blockerar annars fönstret, eftersom det då öppnas efter en väntan och
/// inte direkt av klicket.
class ReceiptButton extends StatefulWidget {
  final String path;
  final String label;

  const ReceiptButton({super.key, required this.path, required this.label});

  @override
  State<ReceiptButton> createState() => _ReceiptButtonState();
}

class _ReceiptButtonState extends State<ReceiptButton> {
  late Future<String> _url;

  @override
  void initState() {
    super.initState();
    _url = ReceiptService.downloadUrl(widget.path);
  }

  @override
  void didUpdateWidget(ReceiptButton old) {
    super.didUpdateWidget(old);
    if (old.path != widget.path) {
      _url = ReceiptService.downloadUrl(widget.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _url,
      builder: (context, snapshot) {
        final url = snapshot.data;
        return TextButton.icon(
          icon: snapshot.connectionState == ConnectionState.waiting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  snapshot.hasError ? Icons.error_outline : Icons.receipt_long,
                ),
          label: Text(widget.label),
          // Öppnas direkt i klicket, utan någon väntan dessförinnan.
          onPressed: url == null
              ? null
              : () => launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                  webOnlyWindowName: '_blank',
                ),
        );
      },
    );
  }
}
