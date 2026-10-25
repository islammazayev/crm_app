import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/locale_controller.dart';
import '../../utils/pickup_code.dart';

/// Kameravy som läser kundens QR-kod för uthämtning. Stängs och lämnar
/// tillbaka transaktion och nyckel så fort en giltig kod har lästs.
class PickupScannerPage extends StatefulWidget {
  const PickupScannerPage({super.key});

  @override
  State<PickupScannerPage> createState() => _PickupScannerPageState();
}

class _PickupScannerPageState extends State<PickupScannerPage> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _done = false;
  bool _warned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final code in capture.barcodes) {
      final parsed = parsePickupQr(code.rawValue ?? '');
      if (parsed != null) {
        _done = true;
        Navigator.pop(context, parsed);
        return;
      }
    }
    // En annan QR-kod: säg till en gång, fortsätt sedan leta.
    if (!_warned && capture.barcodes.isNotEmpty) {
      _warned = true;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.notAPickupQr)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanPickupQr)),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.cameraError(error.errorCode.name),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.pointCameraAtQr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
