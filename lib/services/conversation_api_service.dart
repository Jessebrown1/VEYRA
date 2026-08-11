import '../models/chat_message_entry.dart';
import 'api_client.dart';

class ConversationApiService {
  final ApiClient _client;

  ConversationApiService(this._client);

  Future<String> getOrCreateForCompanion(String companionId) async {
    try {
      final res = await _client.dio.post('/conversations', data: {'companionId': companionId});
      return res.data['id'] as String;
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<List<ChatMessageEntry>> listMessages(String conversationId) async {
    try {
      final res = await _client.dio.get('/conversations/$conversationId/messages');
      return (res.data as List).map((e) => ChatMessageEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  /// Posts the user's message and waits for the companion's real reply
  /// (the backend handles the whole AI orchestration synchronously).
  Future<ChatMessageEntry> postMessage(String conversationId, String content) async {
    try {
      final res = await _client.dio.post('/conversations/$conversationId/messages', data: {'content': content});
      return ChatMessageEntry.fromJson(res.data['companionMessage'] as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
