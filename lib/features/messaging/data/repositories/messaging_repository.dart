import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';

class MessagingRepository {
  final Dio _dio;
  MessagingRepository(this._dio);

  Future<List<Map<String, dynamic>>> getConversations() async {
    final res = await _dio.get(ApiConstants.conversations);
    return List<Map<String, dynamic>>.from(res.data['results'] ?? res.data);
  }

  Future<Map<String, dynamic>> createConversation(String type, List<String> participantIds, {String? title, String? initialMessage}) async {
    final res = await _dio.post(ApiConstants.conversations, data: {
      'type': type, 'participant_ids': participantIds, 'title': title ?? '', 'initial_message': initialMessage ?? '',
    });
    return res.data;
  }

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    final res = await _dio.get('${ApiConstants.conversations}$conversationId/messages/');
    return List<Map<String, dynamic>>.from(res.data['results'] ?? res.data);
  }

  Future<Map<String, dynamic>> sendMessage(String conversationId, String content) async {
    final res = await _dio.post('${ApiConstants.conversations}$conversationId/messages/', data: {'content': content});
    return res.data;
  }

  Future<void> markRead(String conversationId) async {
    await _dio.post('${ApiConstants.conversations}$conversationId/messages/mark-read/');
  }
}
