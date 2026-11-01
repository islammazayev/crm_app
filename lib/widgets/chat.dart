import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';
import '../services/chat_service.dart';
import '../services/receipt_service.dart';
import '../theme/app_theme.dart';
import 'action_card.dart';
import 'receipt_button.dart';

/// Knapp till ärendets chatt, med en prick när det finns olästa meddelanden.
class ChatButton extends StatelessWidget {
  final ChatRef chatRef;

  const ChatButton({super.key, required this.chatRef});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ChatService.chat(chatRef.id).snapshots(),
      builder: (context, snap) {
        final unread = ChatService.isUnread(snap.data?.data());
        return IconButton(
          tooltip: l10n.chat,
          icon: Badge(
            isLabelVisible: unread,
            smallSize: 10,
            child: const Icon(Icons.chat_bubble_outline),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatPage(chatRef: chatRef)),
          ),
        );
      },
    );
  }
}

/// Chatten i ett ärende.
class ChatPage extends StatefulWidget {
  final ChatRef chatRef;

  const ChatPage({super.key, required this.chatRef});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  PickedReceipt? _attachment;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    ChatService.markRead(widget.chatRef.id);
  }

  @override
  void dispose() {
    ChatService.markRead(widget.chatRef.id);
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await ReceiptService.pick();
    if (picked == null || !mounted) return;
    if (picked.bytes.length > ReceiptService.maxBytes) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.receiptTooLarge)));
      return;
    }
    setState(() => _attachment = picked);
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty && _attachment == null) return;
    setState(() => _sending = true);
    try {
      await ChatService.send(
        widget.chatRef,
        text: text,
        attachment: _attachment,
      );
      _text.clear();
      setState(() => _attachment = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorWithDetails('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatRef.title)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ChatService.messages(widget.chatRef.id),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text(l10n.errorWithDetails('${snap.error}')),
                  );
                }
                final docs = snap.data?.docs ?? const [];
                if (snap.hasData && docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.chatEmpty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  );
                }
                // Nya meddelanden när chatten är öppen räknas som lästa.
                if (docs.isNotEmpty) {
                  ChatService.markRead(widget.chatRef.id);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scroll.hasClients) {
                      _scroll.jumpTo(_scroll.position.maxScrollExtent);
                    }
                  });
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) => _Bubble(
                    data: docs[i].data(),
                    mine: docs[i]['senderId'] == uid,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_attachment != null)
                    Chip(
                      avatar: const Icon(Icons.attach_file, size: 18),
                      label: Text(_attachment!.name),
                      onDeleted: () => setState(() => _attachment = null),
                    ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: l10n.attachFile,
                        icon: const Icon(Icons.attach_file),
                        onPressed: _sending ? null : _pick,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _text,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 2000,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: l10n.writeMessage,
                            counterText: '',
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.send,
                        icon: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send, color: AppColors.primary),
                        onPressed: _sending ? null : _send,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool mine;

  const _Bubble({required this.data, required this.mine});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final at = (data['createdAt'] as Timestamp?)?.toDate().toLocal();
    final time = at == null
        ? ''
        : '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    final text = '${data['text'] ?? ''}';
    final path = '${data['attachmentPath'] ?? ''}';
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: mine ? AppColors.primaryDim : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!mine)
              Text(
                '${data['senderName'] ?? ''}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (text.isNotEmpty) SelectableText(text),
            if (path.isNotEmpty)
              ReceiptButton(
                path: path,
                label: '${data['attachmentName'] ?? l10n.attachFile}',
              ),
            Text(
              time,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alla mina chattar, senaste först, olästa i fetstil.
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late final _chats = ChatService.myChats();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.messagesTitle)),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: _chats,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text(l10n.errorWithDetails('${snap.error}')));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          DateTime at(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              (d.data()['lastMessageAt'] as Timestamp?)?.toDate() ??
              DateTime(2000);
          final docs =
              snap.data!
                  .where((d) => d.data()['lastMessageAt'] != null)
                  .toList()
                ..sort((a, b) => at(b).compareTo(at(a)));
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.noMessagesYet, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final d in docs)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Badge(
                      isLabelVisible: ChatService.isUnread(d.data()),
                      smallSize: 10,
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      '${d.data()['title'] ?? ''}',
                      style: TextStyle(
                        fontWeight: ChatService.isUnread(d.data())
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${d.data()['lastSenderName'] ?? ''}: ${d.data()['lastText'] ?? ''}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(chatRef: ChatRef.fromChat(d)),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Kort på startsidan med antalet chattar som har olästa meddelanden.
class MessagesCard extends StatefulWidget {
  const MessagesCard({super.key});

  @override
  State<MessagesCard> createState() => _MessagesCardState();
}

class _MessagesCardState extends State<MessagesCard> {
  // Skapas en gång, så att startsidan inte prenumererar på nytt vid
  // varje omritning.
  late final _chats = ChatService.myChats();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: _chats,
      builder: (context, snap) {
        final unread = (snap.data ?? const [])
            .where((d) => ChatService.isUnread(d.data()))
            .length;
        return ActionCard(
          icon: Icons.forum_outlined,
          iconColor: AppColors.info,
          title: l10n.messagesTitle,
          subtitle: unread > 0
              ? l10n.unreadChats(unread)
              : l10n.messagesCardSubtitle,
          badge: snap.hasData ? '$unread' : '…',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MessagesPage()),
          ),
        );
      },
    );
  }
}
