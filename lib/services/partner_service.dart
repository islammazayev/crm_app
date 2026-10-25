import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/merged_query.dart';

/// Vilken sida av en växling den inloggade står på.
enum ExchangeSide { office, partner }

/// Villkoren i en växling sett från kontoret: kontoret ger
/// [officeGivesAmount] [officeGivesCurrency] och får [partnerGivesAmount]
/// [partnerGivesCurrency] av kompanjonen. Ingen avgift.
class ExchangeTerms {
  final String officeGivesCurrency;
  final double officeGivesAmount;
  final String partnerGivesCurrency;
  final double partnerGivesAmount;

  const ExchangeTerms({
    required this.officeGivesCurrency,
    required this.officeGivesAmount,
    required this.partnerGivesCurrency,
    required this.partnerGivesAmount,
  });

  factory ExchangeTerms.fromMap(Map<String, dynamic> d) => ExchangeTerms(
    officeGivesCurrency: '${d['officeGivesCurrency'] ?? ''}',
    officeGivesAmount: ((d['officeGivesAmount'] ?? 0) as num).toDouble(),
    partnerGivesCurrency: '${d['partnerGivesCurrency'] ?? ''}',
    partnerGivesAmount: ((d['partnerGivesAmount'] ?? 0) as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'officeGivesCurrency': officeGivesCurrency,
    'officeGivesAmount': officeGivesAmount,
    'partnerGivesCurrency': partnerGivesCurrency,
    'partnerGivesAmount': partnerGivesAmount,
  };

  /// Kursen: hur mycket av partnerGives man får per 1 officeGives.
  double get rate =>
      officeGivesAmount == 0 ? 0 : partnerGivesAmount / officeGivesAmount;
}

/// Växlingar mellan kontor och kompanjoner (se firestore.rules).
class PartnerService {
  PartnerService._();

  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get exchanges =>
      _db.collection('partnerExchanges');
  static CollectionReference<Map<String, dynamic>> get partners =>
      _db.collection('partners');
  static DocumentReference<Map<String, dynamic>> partner(String uid) =>
      partners.doc(uid);

  /// Kompanjoner kopplade till managern eller managerns kontor (en fråga
  /// per villkor, så att reglerna kan godkänna dem).
  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> partnersFor(
    String managerId,
    String? officeId,
  ) => mergedQuery([
    partners.where('managerId', isEqualTo: managerId),
    if (officeId != null) partners.where('officeId', isEqualTo: officeId),
  ]);

  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  exchangesForOffice(String officeId) =>
      mergedQuery([exchanges.where('officeId', isEqualTo: officeId)]);

  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  exchangesForPartner(String partnerId) =>
      mergedQuery([exchanges.where('partnerId', isEqualTo: partnerId)]);

  static Future<void> propose({
    required ExchangeSide by,
    required String officeId,
    required String officeLabel,
    required String managerId,
    required String partnerId,
    required String partnerName,
    required ExchangeTerms terms,
    String note = '',
  }) => exchanges.add({
    'officeId': officeId,
    'officeLabel': officeLabel,
    'managerId': managerId,
    'partnerId': partnerId,
    'partnerName': partnerName,
    ...terms.toMap(),
    'note': note,
    'status': 'proposed',
    'proposedBy': by.name,
    'createdAt': FieldValue.serverTimestamp(),
  });

  /// Motförslag: nya belopp, och nu är det den andra sidan som ska svara.
  static Future<void> counter(
    DocumentReference ref,
    ExchangeSide by, {
    required double officeGivesAmount,
    required double partnerGivesAmount,
    String note = '',
  }) => ref.update({
    'officeGivesAmount': officeGivesAmount,
    'partnerGivesAmount': partnerGivesAmount,
    'proposedBy': by.name,
    'note': note,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  static Future<void> decide(DocumentReference ref, String status) =>
      ref.update({'status': status, 'decidedAt': FieldValue.serverTimestamp()});

  static Future<void> markSent(DocumentReference ref, ExchangeSide side) =>
      ref.update({
        '${side.name}Sent': true,
        '${side.name}SentAt': FieldValue.serverTimestamp(),
      });

  /// Markerar att den andra sidans pengar har kommit. Har den andra redan
  /// gjort samma sak blir växlingen genomförd och båda saldona bokförs.
  static Future<void> markReceived(
    DocumentSnapshot<Map<String, dynamic>> exchange,
    ExchangeSide side,
  ) async {
    final d = exchange.data()!;
    final other = side == ExchangeSide.office ? 'partner' : 'office';
    final last = d['${other}Received'] == true;
    final batch = _db.batch();
    batch.update(exchange.reference, {
      '${side.name}Received': true,
      '${side.name}ReceivedAt': FieldValue.serverTimestamp(),
      if (last) 'status': 'completed',
      if (last) 'completedAt': FieldValue.serverTimestamp(),
    });
    if (last) {
      final t = ExchangeTerms.fromMap(d);
      batch.update(_db.collection('offices').doc('${d['officeId']}'), {
        'balances.${t.officeGivesCurrency}': FieldValue.increment(
          -t.officeGivesAmount,
        ),
        'balances.${t.partnerGivesCurrency}': FieldValue.increment(
          t.partnerGivesAmount,
        ),
        'lastPartnerExchangeId': exchange.id,
      });
      batch.update(partner('${d['partnerId']}'), {
        'balances.${t.officeGivesCurrency}': FieldValue.increment(
          t.officeGivesAmount,
        ),
        'balances.${t.partnerGivesCurrency}': FieldValue.increment(
          -t.partnerGivesAmount,
        ),
        'lastExchangeId': exchange.id,
      });
    }
    await batch.commit();
  }
}
