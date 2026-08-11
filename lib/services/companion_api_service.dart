import '../models/companion_profile.dart';
import 'api_client.dart';

class CompanionApiService {
  final ApiClient _client;

  CompanionApiService(this._client);

  Future<List<CompanionProfile>> list() async {
    try {
      final res = await _client.dio.get('/companions');
      return (res.data as List).map((e) => CompanionProfile.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<CompanionProfile> create({
    required String name,
    required String relationshipId,
    required Map<String, double> personalityTraits,
    required String preferredUserName,
    required String preferredTermId,
    String? wallpaperId,
  }) async {
    try {
      final res = await _client.dio.post('/companions', data: {
        'name': name,
        'relationshipId': relationshipId,
        'personalityTraits': personalityTraits,
        'preferredUserName': preferredUserName,
        'preferredTermId': preferredTermId,
        if (wallpaperId != null) 'wallpaperId': wallpaperId,
      });
      return CompanionProfile.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<CompanionProfile> update(String id, Map<String, dynamic> patch) async {
    try {
      final res = await _client.dio.patch('/companions/$id', data: patch);
      return CompanionProfile.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
