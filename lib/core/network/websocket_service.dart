import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

class WebSocketService {
  WebSocketChannel? _notificationChannel;
  WebSocketChannel? _chatChannel;
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _chatController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  Stream<Map<String, dynamic>> get chatStream => _chatController.stream;

  Future<void> connectNotifications() async {
    final token = await TokenStorage.read('access_token');
    if (token == null) return;

    final uri = Uri.parse('${ApiConstants.wsUrl}/notifications/?token=$token');
    _notificationChannel = WebSocketChannel.connect(uri);
    _notificationChannel!.stream.listen(
      (data) {
        final decoded = jsonDecode(data as String) as Map<String, dynamic>;
        _notificationController.add(decoded);
      },
      onError: (error) {
        Future.delayed(const Duration(seconds: 5), connectNotifications);
      },
      onDone: () {
        Future.delayed(const Duration(seconds: 5), connectNotifications);
      },
    );
  }

  Future<void> connectChat(String conversationId) async {
    final token = await TokenStorage.read('access_token');
    if (token == null) return;

    final uri = Uri.parse('${ApiConstants.wsUrl}/chat/$conversationId/?token=$token');
    _chatChannel = WebSocketChannel.connect(uri);
    _chatChannel!.stream.listen(
      (data) {
        final decoded = jsonDecode(data as String) as Map<String, dynamic>;
        _chatController.add(decoded);
      },
      onError: (_) {},
    );
  }

  void sendChatMessage(String content) {
    _chatChannel?.sink.add(jsonEncode({
      'type': 'chat_message',
      'content': content,
    }));
  }

  void markChatSeen() {
    _chatChannel?.sink.add(jsonEncode({'type': 'mark_seen'}));
  }

  void requestCounts() {
    _notificationChannel?.sink.add(jsonEncode({'type': 'get_counts'}));
  }

  void disconnectChat() {
    _chatChannel?.sink.close();
    _chatChannel = null;
  }

  void dispose() {
    _notificationChannel?.sink.close();
    _chatChannel?.sink.close();
    _notificationController.close();
    _chatController.close();
  }
}
