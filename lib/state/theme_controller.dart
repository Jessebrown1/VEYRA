import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

/// Drives dark/light/system mode. Screens that read AppColors call
/// `context.watch<ThemeController>()` once in their build method so they
/// re-render (and re-read the freshly swapped AppColors values) whenever
/// the mode changes.
class ThemeController extends ChangeNotifier with WidgetsBindingObserver {
  static const _prefsKey = 'veyra.theme_mode';

  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  ThemeController() {
    AppColors.applyBrightness(_resolveBrightness());
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored == null) return;
    final restored = ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => _mode,
    );
    if (restored != _mode) {
      _mode = restored;
      AppColors.applyBrightness(_resolveBrightness());
      notifyListeners();
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    AppColors.applyBrightness(_resolveBrightness());
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  Brightness _resolveBrightness() {
    if (_mode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
    return _mode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }

  @override
  void didChangePlatformBrightness() {
    if (_mode == ThemeMode.system) {
      AppColors.applyBrightness(_resolveBrightness());
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
