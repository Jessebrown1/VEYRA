import 'package:flutter/foundation.dart';

/// Holds every selection made across the onboarding flow. Screens read and
/// write into this via Provider so later steps can react to earlier choices.
/// The actual account/companion creation happens against the real backend
/// (see CompanionCreationScreen) — this is just in-progress local state.
class OnboardingController extends ChangeNotifier {
  String userEmail = '';

  String? personalityId;
  String? relationshipId;
  String companionName = '';
  String userPreferredName = '';
  String? termOfAddressId;

  String? skinAssetId;
  String? hairAssetId;
  String? eyeAssetId;
  String? outfitAssetId;
  String? accessoryAssetId;

  String? wallpaperId;
  bool locationEnabled = false;
  bool notificationsEnabled = false;

  void setUserEmail(String value) {
    userEmail = value;
    notifyListeners();
  }

  void setPersonality(String id) {
    personalityId = id;
    notifyListeners();
  }

  void setRelationship(String id) {
    relationshipId = id;
    // Term of address depends on relationship; reset so the next screen
    // doesn't inherit a term that isn't offered for the new role.
    termOfAddressId = null;
    notifyListeners();
  }

  void setCompanionName(String name) {
    companionName = name.trim();
    notifyListeners();
  }

  void setUserPreferredName(String name) {
    userPreferredName = name.trim();
    notifyListeners();
  }

  void setTermOfAddress(String id) {
    termOfAddressId = id;
    notifyListeners();
  }

  void setAvatarAsset(String category, String? assetId) {
    switch (category) {
      case 'skin':
        skinAssetId = assetId;
      case 'hair':
        hairAssetId = assetId;
      case 'eyes':
        eyeAssetId = assetId;
      case 'outfit':
        outfitAssetId = assetId;
      case 'accessory':
        accessoryAssetId = assetId;
    }
    notifyListeners();
  }

  void setWallpaper(String id) {
    wallpaperId = id;
    notifyListeners();
  }

  void setLocationEnabled(bool value) {
    locationEnabled = value;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void reset() {
    userEmail = '';
    personalityId = null;
    relationshipId = null;
    companionName = '';
    userPreferredName = '';
    termOfAddressId = null;
    skinAssetId = null;
    hairAssetId = null;
    eyeAssetId = null;
    outfitAssetId = null;
    accessoryAssetId = null;
    wallpaperId = null;
    locationEnabled = false;
    notificationsEnabled = false;
    notifyListeners();
  }

  bool get isReadyToCreateCompanion =>
      personalityId != null &&
      relationshipId != null &&
      companionName.isNotEmpty &&
      userPreferredName.isNotEmpty &&
      termOfAddressId != null;
}
