import '../models/memory_entry.dart';
import 'api_client.dart';

class MemoryApiService {
  final ApiClient _client;

  MemoryApiService(this._client);

  Future<List<MemoryEntry>> listForCompanion(String companionId) async {
    try {
      final res = await _client.dio.get('/companions/$companionId/memories');
      return (res.data as List).map((e) => MemoryEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<void> update(String memoryId, String content) async {
    try {
      await _client.dio.patch('/memories/$memoryId', data: {'content': content});
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  /// Actually deactivates the memory server-side — never just hides it locally.
  Future<void> forget(String memoryId) async {
    try {
      await _client.dio.delete('/memories/$memoryId');
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
