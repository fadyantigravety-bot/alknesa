import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/websocket_service.dart';
import '../../../../core/network/dio_client.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectWS();
  }

  Future<void> _loadMessages() async {
    final repo = MessagingRepository(ref.read(dioProvider));
    final msgs = await repo.getMessages(widget.conversationId);
    setState(() { _messages = msgs; _loading = false; });
    _scrollToBottom();
    repo.markRead(widget.conversationId);
  }

  void _connectWS() {
    final ws = ref.read(webSocketServiceProvider);
    ws.connectChat(widget.conversationId);
    ws.chatStream.listen((data) {
      if (data['type'] == 'message_sent') {
        setState(() => _messages.add(data));
        _scrollToBottom();
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
    ref.read(webSocketServiceProvider).disconnectChat();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherName),
        leading: IconButton(icon: const Icon(Icons.arrow_forward_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMine = msg['sender_id'] == ''; // TODO: compare with current user id
                      return _ChatBubble(
                        content: msg['content'] ?? '',
                        senderName: msg['sender_name'] ?? '',
                        time: msg['created_at'] ?? '',
                        isMine: isMine,
                      );
                    },
                  ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _msgController,
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالة...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
  const _ChatBubble({required this.content, required this.senderName, required this.time, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 4 : 16),
            bottomRight: Radius.circular(isMine ? 16 : 4),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Text(senderName, style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
            Text(content, style: TextStyle(color: isMine ? Colors.white : AppColors.textPrimary, fontSize: 14)),
            const SizedBox(height: 2),
            Text(
              _formatTime(time),
              style: TextStyle(fontSize: 10, color: isMine ? Colors.white60 : AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String t) {
    try { final d = DateTime.parse(t); return '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}'; } catch (_) { return ''; }
  }
}
