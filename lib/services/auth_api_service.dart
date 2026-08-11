import '../models/user_profile.dart';
import 'api_client.dart';

class AuthApiService {
  final ApiClient _client;

  AuthApiService(this._client);

  Future<UserProfile> register({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
      });
      final token = res.data['accessToken'] as String;
      await ApiClient.saveToken(token);
      return UserProfile.fromJson(res.data['user'] as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<UserProfile> login({required String email, required String password}) async {
    try {
      final res = await _client.dio.post('/auth/login', data: {'email': email, 'password': password});
      final token = res.data['accessToken'] as String;
      await ApiClient.saveToken(token);
      return UserProfile.fromJson(res.data['user'] as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<UserProfile> me() async {
    try {
      final res = await _client.dio.get('/users/me');
      return UserProfile.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<UserProfile> updateProfile({required String preferredName}) async {
    try {
      final res = await _client.dio.patch('/users/me', data: {'preferredName': preferredName});
      return UserProfile.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<void> logout() => ApiClient.clearToken();

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _client.dio.patch('/users/me/password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    try {
      final res = await _client.dio.get('/users/me/export');
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _client.dio.delete('/users/me');
    } catch (e) {
      throw ApiClient.toApiException(e);
    } finally {
      await ApiClient.clearToken();
    }
  }
}
