import 'package:flutter/foundation.dart';
import '../models/companion_profile.dart';
import '../models/entitlements.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';
import '../services/auth_api_service.dart';
import '../services/avatar_api_service.dart';
import '../services/biometric_service.dart';
import '../services/companion_api_service.dart';
import '../services/conversation_api_service.dart';
import '../services/entitlements_api_service.dart';
import '../services/memory_api_service.dart';
import '../services/settings_api_service.dart';
import '../services/wallpaper_api_service.dart';

enum AppLaunchStatus { loading, needsOnboarding, ready }

/// App-wide session state: the signed-in user, their companion, entitlements,
/// and every typed API service the rest of the app talks to. The JWT in
/// secure storage — not this object — is what makes the session "remembered"
/// across launches.
class AppState extends ChangeNotifier {
  final ApiClient apiClient = ApiClient();

  late final AuthApiService authApi = AuthApiService(apiClient);
  late final CompanionApiService companionApi = CompanionApiService(apiClient);
  late final ConversationApiService conversationApi = ConversationApiService(apiClient);
  late final MemoryApiService memoryApi = MemoryApiService(apiClient);
  late final AvatarApiService avatarApi = AvatarApiService(apiClient);
  late final WallpaperApiService wallpaperApi = WallpaperApiService(apiClient);
  late final EntitlementsApiService entitlementsApi = EntitlementsApiService(apiClient);
  late final SettingsApiService settingsApi = SettingsApiService(apiClient);
  final BiometricService biometrics = BiometricService();

  AppLaunchStatus status = AppLaunchStatus.loading;
  UserProfile? user;
  CompanionProfile? companion;
  String? conversationId;
  Entitlements entitlements = Entitlements.free;

  Future<void> loadFromSession() async {
    final token = await ApiClient.readToken();
    if (token == null) {
      status = AppLaunchStatus.needsOnboarding;
      notifyListeners();
      return;
    }

    try {
      final loadedUser = await authApi.me();
      final companions = await companionApi.list();
      if (companions.isEmpty) {
        user = loadedUser;
        status = AppLaunchStatus.needsOnboarding;
        notifyListeners();
        return;
      }
      user = loadedUser;
      companion = companions.first;
      conversationId = await conversationApi.getOrCreateForCompanion(companion!.id);
      await refreshEntitlements();
      status = AppLaunchStatus.ready;
    } catch (_) {
      await ApiClient.clearToken();
      status = AppLaunchStatus.needsOnboarding;
    }
    notifyListeners();
  }

  Future<void> refreshEntitlements() async {
    entitlements = await entitlementsApi.get();
    notifyListeners();
  }

  Future<void> completeOnboarding(UserProfile newUser, CompanionProfile newCompanion) async {
    user = newUser;
    companion = newCompanion;
    conversationId = await conversationApi.getOrCreateForCompanion(newCompanion.id);
    await refreshEntitlements();
    status = AppLaunchStatus.ready;
    notifyListeners();
  }

  void updateCompanion(CompanionProfile updated) {
    companion = updated;
    notifyListeners();
  }

  void updateUser(UserProfile updated) {
    user = updated;
    notifyListeners();
  }

  Future<void> signOut() async {
    await authApi.logout();
    user = null;
    companion = null;
    conversationId = null;
    entitlements = Entitlements.free;
    status = AppLaunchStatus.needsOnboarding;
    notifyListeners();
  }
}
