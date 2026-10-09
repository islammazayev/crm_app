import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OfficeBalanceService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> topUp({
    required String currency, // 'EURO', 'RUBLE', 'SEK', 'USD'
    required num amount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // hämta managerns officeId från users-dokumentet
    final userDoc =
        await _firestore.collection('users').doc(user.uid).get();
    final officeId = userDoc.data()?['officeId'] as String?;
    if (officeId == null) {
      throw Exception('Manager har inget officeId');
    }

    await _firestore.collection('offices').doc(officeId).update({
      'balance.$currency': FieldValue.increment(amount),
    });
  }
}
