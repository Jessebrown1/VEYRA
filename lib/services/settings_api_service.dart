import 'api_client.dart';

class SettingsApiService {
  final ApiClient _client;

  SettingsApiService(this._client);

  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final res = await _client.dio.get('/notifications/settings');
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getLocationSettings() async {
    try {
      final res = await _client.dio.get('/location/settings');
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<void> updateNotificationSettings({
    required bool enabled,
    bool? companionCheckins,
    bool? sleepReminders,
  }) async {
    try {
      await _client.dio.patch('/notifications/settings', data: {
        'enabled': enabled,
        if (companionCheckins != null) 'companionCheckins': companionCheckins,
        if (sleepReminders != null) 'sleepReminders': sleepReminders,
      });
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<void> updateLocationSettings({required bool enabled, String? permissionType}) async {
    try {
      await _client.dio.patch('/location/settings', data: {
        'enabled': enabled,
        if (permissionType != null) 'permissionType': permissionType,
      });
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
