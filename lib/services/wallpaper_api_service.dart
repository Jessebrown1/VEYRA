import '../models/wallpaper_catalog_item.dart';
import 'api_client.dart';

class WallpaperApiService {
  final ApiClient _client;

  WallpaperApiService(this._client);

  Future<List<WallpaperCatalogItem>> list() async {
    try {
      final res = await _client.dio.get('/wallpapers');
      return (res.data as List).map((e) => WallpaperCatalogItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
