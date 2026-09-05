import 'package:panjang_umur_frontend/core/network/dio_client.dart';

import '../../domain/models/conversation_summary.dart';
import '../../domain/models/message.dart';

class ChatRemoteDataSource {
  final DioClient _client;

  ChatRemoteDataSource({required this._client});

  Future<List<Message>> getMessages({
    required String friendId,
    DateTime? before,
    int? limit,
  }) async {
    final response = await _client.get(
      '/chat/$friendId/messages',
      queryParameters: {
        'before': ?before?.toUtc().toIso8601String(),
        'limit': ?limit?.toString(),
      },
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Message.fromJson(json)).toList();
  }

  Future<void> markAsRead(String friendId) async {
    await _client.post('/chat/$friendId/read');
  }

  Future<List<ConversationSummary>> getConversations() async {
    final response = await _client.get('/chat/conversations');
    final List<dynamic> data = response.data;
    return data.map((json) => ConversationSummary.fromJson(json)).toList();
  }
}
