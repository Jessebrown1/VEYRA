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
}
