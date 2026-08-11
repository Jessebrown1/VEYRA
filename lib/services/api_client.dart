import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class ApiException implements Exception {
  final String code;
  final String message;

  const ApiException(this.code, this.message);

  @override
  String toString() => message;
}

/// Shared Dio client: attaches the stored JWT to every request and unwraps
/// the backend's `{error:{code,message}}` shape into an ApiException so
/// callers never touch raw Dio/HTTP errors.
class ApiClient {
  static const _tokenKey = 'veyra.access_token';
  static const _storage = FlutterSecureStorage();

  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 90),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(_mapError(error));
        },
      ),
    );
  }

  DioException _mapError(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final err = data['error'] as Map;
      return DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: ApiException(
          err['code']?.toString() ?? 'ERROR',
          err['message']?.toString() ?? 'Something went wrong. Please try again.',
        ),
      );
    }
    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: const ApiException('NETWORK_ERROR', "Couldn't reach VEYRA. Check your connection and try again."),
    );
  }

  /// Fire-and-forget nudge sent as early as possible (app launch) so the
  /// free-tier AI service starts waking up while the user is still going
  /// through onboarding, instead of only when they send their first message.
  void warmupAi() async {
    try {
      await dio.get('/ai/warmup');
    } catch (_) {
      // Expected while cold — the request itself is what triggers the wake.
    }
  }

  static Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  static Future<String?> readToken() => _storage.read(key: _tokenKey);

  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  static ApiException toApiException(Object error) {
    if (error is DioException && error.error is ApiException) {
      return error.error as ApiException;
    }
    return const ApiException('UNKNOWN_ERROR', 'Something went wrong. Please try again.');
  }
}
