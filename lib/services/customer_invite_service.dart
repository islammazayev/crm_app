import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/pickup_code.dart';

/// Inbjudan för kunder utan konto: managern skickar en länk via SMS och
/// kunden registrerar sig med den. Kunden behåller då sitt klient-ID och
/// sin nivå (se firestore.rules, claimsInvite).
class CustomerInviteService {
  CustomerInviteService._();

  static final _db = FirebaseFirestore.instance;

  /// Länken till appen med kundpostens ID och den hemliga koden. Pekar på
  /// samma adress som appen körs på (livelänken, eller testlänken vid test).
  static String inviteLink(String customerDocId, String code) =>
      '${Uri.base.origin}/?invite=$customerDocId.$code';

  /// Läser "?invite=..." ur adressen, eller null om det inte finns någon.
  static ({String docId, String code})? inviteFromUrl() {
    final raw = Uri.base.queryParameters['invite'];
    if (raw == null) return null;
    final parts = raw.split('.');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].length < 24) {
      return null;
    }
    return (docId: parts[0], code: parts[1]);
  }

  /// Ny kund på kontoret som vill bli kund: nästa klient-ID och en inbjudan.
  static Future<({String docId, int clientId, String code})> createCustomer({
    required String managerId,
    required String name,
    required String phone,
  }) async {
    final metaRef = _db.collection('meta').doc('customers');
    final ref = _db.collection('customers').doc();
    final code = newPickupToken();
    final clientId = await _db.runTransaction<int>((tx) async {
      final snap = await tx.get(metaRef);
      final next = ((snap.data()?['lastClientId'] as num?)?.toInt() ?? 0) + 1;
      tx.set(metaRef, {'lastClientId': next}, SetOptions(merge: true));
      tx.set(ref, {
        'clientId': next,
        'firstName': name,
        'lastName': '',
        'phone': phone,
        'createAt': FieldValue.serverTimestamp(),
        'inviteCode': code,
        'invitedAt': FieldValue.serverTimestamp(),
        'createdByManagerId': managerId,
      });
      return next;
    });
    return (docId: ref.id, clientId: clientId, code: code);
  }

  /// Bjuder in en befintlig kund utan konto. En tidigare kod återanvänds,
  /// så att en gammal länk fortsätter att fungera.
  static Future<String> inviteExisting(
    String customerDocId,
    String? existingCode,
  ) async {
    final code = (existingCode != null && existingCode.length >= 24)
        ? existingCode
        : newPickupToken();
    await _db.collection('customers').doc(customerDocId).update({
      'inviteCode': code,
      'invitedAt': FieldValue.serverTimestamp(),
    });
    return code;
  }

  /// Öppnar SMS-appen på telefonen med numret och meddelandet ifyllda.
  /// "?&body=" fungerar både på iPhone och Android.
  static Future<bool> openSms(String phone, String message) => launchUrl(
    Uri.parse(
      'sms:${phone.replaceAll(' ', '')}?&body=${Uri.encodeComponent(message)}',
    ),
  );
}
