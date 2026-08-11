import '../models/entitlements.dart';
import 'api_client.dart';

class EntitlementsApiService {
  final ApiClient _client;

  EntitlementsApiService(this._client);

  Future<Entitlements> get() async {
    try {
      final res = await _client.dio.get('/entitlements');
      return Entitlements.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  /// Dev-only: flips subscription status without a real store — the swap
  /// point for real StoreKit/Play Billing verification later.
  Future<void> mockSetSubscription(String status) async {
    try {
      await _client.dio.post('/subscription/mock-set', data: {'status': status});
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
