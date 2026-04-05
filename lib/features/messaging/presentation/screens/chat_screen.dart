import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/websocket_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../data/repositories/messaging_repository.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherName;
  const ChatScreen({super.key, required this.conversationId, required this.otherName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  StreamSubscription? _chatSub;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectWS();
  }

  Future<void> _loadMessages() async {
    final repo = MessagingRepository(ref.read(dioProvider));
    final msgs = await repo.getMessages(widget.conversationId);
    if (mounted) {
      setState(() { _messages = msgs; _loading = false; });
      _scrollToBottom();
    }
    repo.markRead(widget.conversationId);
  }

  void _connectWS() {
    final ws = ref.read(webSocketServiceProvider);
    ws.connectChat(widget.conversationId);
    _chatSub = ws.chatStream.listen((data) {
      if (data['type'] == 'message_sent') {
        if (mounted) {
          setState(() {
            final exists = _messages.any((m) => m['id'] == data['id']);
            if (!exists) _messages.add(data);
          });
          _scrollToBottom();
        }
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _send() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    ref.read(webSocketServiceProvider).sendChatMessage(text);
    _msgController.clear();
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    ref.read(webSocketServiceProvider).disconnectChat();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE6DD), // WhatsApp-like wallpaper color
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const Text('متصل الآن', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final currentUserId = ref.watch(authStateProvider).value?.id.toString();
                      final senderStr = (msg['sender_id'] ?? msg['sender']).toString();
                      final isMine = senderStr == currentUserId;
                      // Determine if previous message was from same sender to handle tail visibility
                      final prevMsg = index > 0 ? _messages[index - 1] : null;
                      final isPrevSame = prevMsg != null && (prevMsg['sender_id'] ?? prevMsg['sender']).toString() == senderStr;

                      return _ChatBubble(
                        content: msg['content'] ?? '',
                        senderName: msg['sender_name'] ?? '',
                        time: msg['created_at'] ?? '',
                        isMine: isMine,
                        showTail: !isPrevSame,
                      );
                    },
                  ),
          ),
          // Input bar
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: TextField(
                              controller: _msgController,
                              decoration: const InputDecoration(
                                hintText: 'المراسلة',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              maxLines: 5,
                              minLines: 1,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file_rounded, color: Colors.grey),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
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

class _ChatBubble extends StatelessWidget {
  final String content;
  final String senderName;
  final String time;
  final bool isMine;
  final bool showTail;

  const _ChatBubble({
    required this.content, 
    required this.senderName, 
    required this.time, 
    required this.isMine,
    this.showTail = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: EdgeInsetsDirectional.only(
          bottom: showTail ? 8 : 2, 
          start: isMine ? 50 : 0, 
          end: isMine ? 0 : 50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFFE1FFC7) : Colors.white,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(12),
            topEnd: const Radius.circular(12),
            bottomStart: Radius.circular(!isMine && showTail ? 0 : 12),
            bottomEnd: Radius.circular(isMine && showTail ? 0 : 12),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine && showTail)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(senderName, style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              alignment: WrapAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 4, bottom: 4, top: 2),
                  child: Text(content, style: const TextStyle(color: Colors.black87, fontSize: 15)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(time),
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String t) {
    try { final d = DateTime.parse(t).toLocal(); return '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}'; } catch (_) { return ''; }
  }
}
