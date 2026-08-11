import '../models/avatar_catalog_item.dart';
import '../models/avatar_config.dart';
import 'api_client.dart';

class AvatarApiService {
  final ApiClient _client;

  AvatarApiService(this._client);

  Future<List<AvatarCatalogItem>> listAssets() async {
    try {
      final res = await _client.dio.get('/avatar/assets');
      return (res.data as List).map((e) => AvatarCatalogItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<AvatarConfig> updateAvatar(String companionId, AvatarConfig config) async {
    try {
      final res = await _client.dio.patch('/companions/$companionId/avatar', data: config.toJson());
      return AvatarConfig.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
