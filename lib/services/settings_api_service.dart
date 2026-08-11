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

  Future<Map<String, dynamic>> updateNotificationSettings({
    bool? enabled,
    bool? companionCheckins,
    bool? sleepReminders,
    bool? quietHoursEnabled,
    String? quietStart,
    String? quietEnd,
    String? frequency,
  }) async {
    try {
      final res = await _client.dio.patch('/notifications/settings', data: {
        if (enabled != null) 'enabled': enabled,
        if (companionCheckins != null) 'companionCheckins': companionCheckins,
        if (sleepReminders != null) 'sleepReminders': sleepReminders,
        if (quietHoursEnabled != null) 'quietHoursEnabled': quietHoursEnabled,
        if (quietStart != null) 'quietStart': quietStart,
        if (quietEnd != null) 'quietEnd': quietEnd,
        if (frequency != null) 'frequency': frequency,
      });
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<Map<String, dynamic>> updateLocationSettings({
    bool? enabled,
    String? permissionType,
    String? lastArea,
  }) async {
    try {
      final res = await _client.dio.patch('/location/settings', data: {
        if (enabled != null) 'enabled': enabled,
        if (permissionType != null) 'permissionType': permissionType,
        if (lastArea != null) 'lastArea': lastArea,
      });
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<void> clearAllMemories(String companionId) async {
    try {
      await _client.dio.post('/companions/$companionId/memories/clear');
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
