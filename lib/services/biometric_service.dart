import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over local_auth — gates access to an already-signed-in
/// session with Face ID / Touch ID / fingerprint. This never replaces
/// email+password login; it only unlocks the JWT already stored securely
/// on-device after the user has enabled it from Settings.
class BiometricService {
  static const _prefsKey = 'veyra.biometric_enabled';

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }

  Future<bool> get isAvailable async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Unlock VEYRA'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
