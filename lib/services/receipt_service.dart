import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

/// En vald kvittofil (bild eller PDF) innan den laddas upp.
class PickedReceipt {
  final String name;
  final Uint8List bytes;
  final String contentType;

  const PickedReceipt(this.name, this.bytes, this.contentType);
}

/// Kvitton som kunden bifogar till en betalning. Sparas i Firebase Storage
/// under receipts/{transaktions-ID}/ (se storage.rules).
class ReceiptService {
  ReceiptService._();

  static const maxBytes = 10 * 1024 * 1024;

  /// Låter kunden välja en bild eller PDF. Null om inget valdes.
  static Future<PickedReceipt?> pick() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'heic', 'webp', 'pdf'],
      withData: true,
    );
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return null;
    return PickedReceipt(file.name, bytes, contentTypeFor(file.name));
  }

  static String contentTypeFor(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Laddar upp kvittot och returnerar sökvägen i Storage.
  static Future<String> upload(String transactionId, PickedReceipt r) async {
    final safeName = r.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final path =
        'receipts/$transactionId/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    await FirebaseStorage.instance
        .ref(path)
        .putData(r.bytes, SettableMetadata(contentType: r.contentType));
    return path;
  }

  /// Öppnar kvittot i en ny flik (webb) eller i telefonens visare.
  static Future<void> open(String path) async {
    final url = await FirebaseStorage.instance.ref(path).getDownloadURL();
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
