import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/balances.dart';

/// Kassör så som den visas i listan över mottagare (cashierDirectory).
class CashierEntry {
  final String id;
  final String name;
  final String? officeId;
  final String officeLabel;
  final String? managerId;
  final String managerName;

  const CashierEntry({
    required this.id,
    required this.name,
    this.officeId,
    this.officeLabel = '',
    this.managerId,
    this.managerName = '',
  });

  factory CashierEntry.fromDoc(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? const {};
    return CashierEntry(
      id: doc.id,
      name: '${d['name'] ?? ''}',
      officeId: d['officeId'] as String?,
      officeLabel: '${d['officeLabel'] ?? ''}',
      managerId: d['managerId'] as String?,
      managerName: '${d['managerName'] ?? ''}',
    );
  }

  /// "Ahmed – Grozny-kontoret" eller "Ahmed – Manager Ali".
  String get label {
    final where = officeLabel.isNotEmpty ? officeLabel : managerName;
    return where.isEmpty ? name : '$name – $where';
  }
}

/// Överföringar mellan kassörer. Saldot flyttas i samma batch som
/// överföringen ändrar status; reglerna kontrollerar att det stämmer.
class CashierService {
  CashierService._();

  static final _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get transfers =>
      _db.collection('cashierTransfers');
  static DocumentReference<Map<String, dynamic>> cashier(String uid) =>
      _db.collection('cashiers').doc(uid);
  static DocumentReference<Map<String, dynamic>> directory(String uid) =>
      _db.collection('cashierDirectory').doc(uid);

  /// Alla kassörer i katalogen (för listan över mottagare).
  static Stream<List<CashierEntry>> directoryStream() => _db
      .collection('cashierDirectory')
      .snapshots()
      .map((snap) => snap.docs.map(CashierEntry.fromDoc).toList());

  /// Skickar och reserverar beloppet direkt från avsändarens saldo.
  static Future<void> send({
    required CashierEntry from,
    required CashierEntry to,
    required String currency,
    required double amount,
    String note = '',
  }) async {
    final own = await cashier(from.id).get();
    final balance =
        parseBalances(own.data()?['balances'], officeId: from.id)[currency] ??
        0;
    if (amount <= 0 || amount > balance + 0.000001) {
      throw const InsufficientBalance();
    }
    final ref = transfers.doc();
    final batch = _db.batch();
    batch.set(ref, {
      'fromId': from.id,
      'fromName': from.name,
      'toId': to.id,
      'toName': to.name,
      'currency': currency,
      'amount': amount,
      'note': note,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'fromOfficeId': from.officeId,
      'fromManagerId': from.managerId,
      'toOfficeId': to.officeId,
      'toManagerId': to.managerId,
    });
    batch.update(cashier(from.id), {
      'balances.$currency': FieldValue.increment(-amount),
      'lastTransferId': ref.id,
    });
    await batch.commit();
  }

  /// Mottagaren tar emot: beloppet läggs till mottagarens saldo.
  static Future<void> accept(DocumentSnapshot transfer) =>
      _decide(transfer, status: 'accepted', creditTo: _field(transfer, 'toId'));

  /// Mottagaren nekar: beloppet går tillbaka till avsändaren.
  static Future<void> reject(DocumentSnapshot transfer) => _decide(
    transfer,
    status: 'rejected',
    creditTo: _field(transfer, 'fromId'),
  );

  /// Avsändaren avbryter medan överföringen väntar: beloppet går tillbaka.
  static Future<void> cancel(DocumentSnapshot transfer) => _decide(
    transfer,
    status: 'cancelled',
    creditTo: _field(transfer, 'fromId'),
  );

  static String _field(DocumentSnapshot doc, String key) =>
      '${(doc.data() as Map<String, dynamic>)[key]}';

  static Future<void> _decide(
    DocumentSnapshot transfer, {
    required String status,
    required String creditTo,
  }) async {
    final d = transfer.data() as Map<String, dynamic>;
    final amount = (d['amount'] as num).toDouble();
    final batch = _db.batch();
    batch.update(transfer.reference, {
      'status': status,
      'decidedAt': FieldValue.serverTimestamp(),
    });
    batch.update(cashier(creditTo), {
      'balances.${d['currency']}': FieldValue.increment(amount),
      'lastTransferId': transfer.id,
    });
    await batch.commit();
  }
}

class InsufficientBalance implements Exception {
  const InsufficientBalance();
}
