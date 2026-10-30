import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/merged_query.dart';
import 'receipt_service.dart';

/// Vilket ärende en chatt hör till och vilka som är med (se chats i
/// firestore.rules). Chatten skapas först när någon skriver.
class ChatRef {
  final String type; // 'tx', 'ex' eller 'ct'
  final String refId;
  final String title;
  final List<String?> officeIds;
  final List<String?> managerIds;
  final List<String?> cashierOfficeIds;
  final List<String?> cashierIds;
  final String partnerId;

  const ChatRef({
    required this.type,
    required this.refId,
    required this.title,
    this.officeIds = const [],
    this.managerIds = const [],
    this.cashierOfficeIds = const [],
    this.cashierIds = const [],
    this.partnerId = '',
  });

  String get id => '${type}_$refId';

  /// Kundtransaktion: kontorets manager och kassörer.
  factory ChatRef.transaction(
    String id,
    Map<String, dynamic> d, {
    required String title,
  }) => ChatRef(
    type: 'tx',
    refId: id,
    title: title,
    officeIds: ['${d['officeId']}'],
    cashierOfficeIds: ['${d['officeId']}'],
  );

  /// Partnerväxling: kontorets manager och kassörer, och partnern.
  factory ChatRef.exchange(
    String id,
    Map<String, dynamic> d, {
    required String title,
  }) => ChatRef(
    type: 'ex',
    refId: id,
    title: title,
    officeIds: ['${d['officeId']}'],
    cashierOfficeIds: ['${d['officeId']}'],
    partnerId: '${d['partnerId']}',
  );

  /// Överföring mellan kassörer: båda kassörerna och deras managers.
  factory ChatRef.transfer(
    String id,
    Map<String, dynamic> d, {
    required String title,
  }) => ChatRef(
    type: 'ct',
    refId: id,
    title: title,
    officeIds: [d['fromOfficeId'] as String?, d['toOfficeId'] as String?],
    managerIds: [d['fromManagerId'] as String?, d['toManagerId'] as String?],
    cashierIds: [d['fromId'] as String?, d['toId'] as String?],
  );

  /// Från en befintlig chatt (listan över chattar).
  factory ChatRef.fromChat(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    List<String?> list(String key) =>
        (d[key] as List? ?? const []).map((e) => e as String?).toList();
    return ChatRef(
      type: '${d['type'] ?? ''}',
      refId: '${d['refId'] ?? ''}',
      title: '${d['title'] ?? ''}',
      officeIds: list('officeIds'),
      managerIds: list('managerIds'),
      cashierOfficeIds: list('cashierOfficeIds'),
      cashierIds: list('cashierIds'),
      partnerId: '${d['partnerId'] ?? ''}',
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type,
    'refId': refId,
    'title': title,
    'officeIds': officeIds,
    'managerIds': managerIds,
    'cashierOfficeIds': cashierOfficeIds,
    'cashierIds': cashierIds,
    'partnerId': partnerId,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

class ChatService {
  ChatService._();

  static final _db = FirebaseFirestore.instance;
  static String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  static DocumentReference<Map<String, dynamic>> chat(String id) =>
      _db.collection('chats').doc(id);

  static Stream<QuerySnapshot<Map<String, dynamic>>> messages(String id) =>
      chat(id).collection('messages').orderBy('createdAt').snapshots();

  static String? _myName;

  static Future<String> _senderName() async {
    if (_myName != null) return _myName!;
    final d = (await _db.collection('users').doc(_uid).get()).data() ?? {};
    final name = '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
    return _myName = name.isEmpty ? '${d['email'] ?? ''}' : name;
  }

  /// Skapar chatten om den inte finns.
  static Future<void> _ensure(ChatRef ref) async {
    final snap = await chat(ref.id).get();
    if (!snap.exists) await chat(ref.id).set(ref.toMap());
  }

  /// Skickar ett meddelande, med en valfri bild eller PDF.
  static Future<void> send(
    ChatRef ref, {
    String text = '',
    PickedReceipt? attachment,
  }) async {
    await _ensure(ref);
    final name = await _senderName();
    String? path;
    if (attachment != null) {
      path = await ReceiptService.uploadTo('chats/${ref.id}', attachment);
    }
    final batch = _db.batch();
    batch.set(chat(ref.id).collection('messages').doc(), {
      'senderId': _uid,
      'senderName': name,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      if (path != null) ...{
        'attachmentPath': path,
        'attachmentName': attachment!.name,
        'attachmentContentType': attachment.contentType,
      },
    });
    batch.update(chat(ref.id), {
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastText': text.isNotEmpty ? text : '📎 ${attachment?.name ?? ''}',
      'lastSenderId': _uid,
      'lastSenderName': name,
      'readBy.$_uid': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// Markerar chatten som läst av mig.
  static Future<void> markRead(String id) async {
    try {
      await chat(id).update({'readBy.$_uid': FieldValue.serverTimestamp()});
    } catch (_) {
      // Chatten finns inte än.
    }
  }

  /// Sant om det finns meddelanden från andra som jag inte har läst.
  static bool isUnread(Map<String, dynamic>? d) {
    if (d == null) return false;
    final last = d['lastMessageAt'] as Timestamp?;
    if (last == null || d['lastSenderId'] == _uid) return false;
    final read = (d['readBy'] as Map?)?[_uid] as Timestamp?;
    return read == null || read.compareTo(last) < 0;
  }

  /// Alla chattar jag är med i (en fråga per villkor, så att reglerna kan
  /// godkänna dem).
  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  myChats() async* {
    final uid = _uid;
    final me = (await _db.collection('users').doc(uid).get()).data() ?? {};
    final chats = _db.collection('chats');
    final role = me['role'];
    final queries = <Query<Map<String, dynamic>>>[];
    if (role == 'manager') {
      final office = me['officeId'] as String?;
      if (office != null) {
        queries.add(chats.where('officeIds', arrayContains: office));
      }
      queries.add(chats.where('managerIds', arrayContains: uid));
    } else if (role == 'cashier') {
      final c = (await _db.collection('cashiers').doc(uid).get()).data();
      final office = (c?['officeId'] ?? c?['cashOfficeId']) as String?;
      if (office != null) {
        queries.add(chats.where('cashierOfficeIds', arrayContains: office));
      }
      queries.add(chats.where('cashierIds', arrayContains: uid));
    } else if (role == 'partner') {
      queries.add(chats.where('partnerId', isEqualTo: uid));
    } else if (role == 'admin') {
      queries.add(chats);
    }
    yield* mergedQuery(queries);
  }
}
