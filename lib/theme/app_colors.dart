import 'package:flutter/material.dart';

/// Centralized VEYRA palette. Never hard-code colors elsewhere — reference
/// these. Values are mutable (not const) so [applyBrightness] can swap the
/// whole palette between dark and light mode at runtime; every screen that
/// reads these also calls `context.watch<ThemeController>()` once in its
/// build method so it re-renders — and re-reads the fresh values — whenever
/// the mode changes.
class AppColors {
  AppColors._();

  static Color background = _Dark.background;
  static Color surface = _Dark.surface;
  static Color elevated = _Dark.elevated;
  static Color elevatedHigh = _Dark.elevatedHigh;

  static Color textPrimary = _Dark.textPrimary;
  static Color textSecondary = _Dark.textSecondary;
  static Color textMuted = _Dark.textMuted;

  static Color accent = _Dark.accent;
  static Color accentBright = _Dark.accentBright;
  static Color accentDeep = _Dark.accentDeep;
  static Color accentMuted = _Dark.accentMuted;

  static Color champagne = _Dark.champagne;

  static Color success = _Dark.success;
  static Color warning = _Dark.warning;
  static Color danger = _Dark.danger;

  static Color divider = _Dark.divider;
  static Color dividerFaint = _Dark.dividerFaint;

  static LinearGradient ambientGradient = _Dark.ambientGradient;
  static LinearGradient accentGradient = _Dark.accentGradient;
  static LinearGradient cardGradient = _Dark.cardGradient;

  static bool isDark = true;

  static const AppPalette darkPalette = _Dark.values;
  static const AppPalette lightPalette = _Light.values;

  static void applyBrightness(Brightness brightness) {
    final p = brightness == Brightness.dark ? _Dark.values : _Light.values;
    isDark = brightness == Brightness.dark;
    background = p.background;
    surface = p.surface;
    elevated = p.elevated;
    elevatedHigh = p.elevatedHigh;
    textPrimary = p.textPrimary;
    textSecondary = p.textSecondary;
    textMuted = p.textMuted;
    accent = p.accent;
    accentBright = p.accentBright;
    accentDeep = p.accentDeep;
    accentMuted = p.accentMuted;
    champagne = p.champagne;
    success = p.success;
    warning = p.warning;
    danger = p.danger;
    divider = p.divider;
    dividerFaint = p.dividerFaint;
    ambientGradient = p.ambientGradient;
    accentGradient = p.accentGradient;
    cardGradient = p.cardGradient;
  }

  static RadialGradient glow(Color color, {double opacity = 0.35}) => RadialGradient(
        colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
      );
}

class AppPalette {
  final Color background;
  final Color surface;
  final Color elevated;
  final Color elevatedHigh;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentBright;
  final Color accentDeep;
  final Color accentMuted;
  final Color champagne;
  final Color success;
  final Color warning;
  final Color danger;
  final Color divider;
  final Color dividerFaint;
  final LinearGradient ambientGradient;
  final LinearGradient accentGradient;
  final LinearGradient cardGradient;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.elevated,
    required this.elevatedHigh,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentBright,
    required this.accentDeep,
    required this.accentMuted,
    required this.champagne,
    required this.success,
    required this.warning,
    required this.danger,
    required this.divider,
    required this.dividerFaint,
    required this.ambientGradient,
    required this.accentGradient,
    required this.cardGradient,
  });
}

/// Original VEYRA dark palette — deep near-black with a warm violet accent.
class _Dark {
  static const Color background = Color(0xFF0B0B0D);
  static const Color surface = Color(0xFF151519);
  static const Color elevated = Color(0xFF1D1D22);
  static const Color elevatedHigh = Color(0xFF232329);

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA4A4AA);
  static const Color textMuted = Color(0xFF6F6F77);

  static const Color accent = Color(0xFFB7A2F3);
  static const Color accentBright = Color(0xFFD3C4FA);
  static const Color accentDeep = Color(0xFF6E5AA8);
  static const Color accentMuted = Color(0xFF7C6BA8);

  static const Color champagne = Color(0xFFE3C793);

  static const Color success = Color(0xFF7FD9A8);
  static const Color warning = Color(0xFFE8C27A);
  static const Color danger = Color(0xFFE08A8A);

  static const Color divider = Color(0xFF26262C);
  static const Color dividerFaint = Color(0xFF1B1B20);

  static const LinearGradient ambientGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF15121E), background],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBright, accent, accentDeep],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [elevatedHigh, surface],
  );

  static const AppPalette values = AppPalette(
    background: background,
    surface: surface,
    elevated: elevated,
    elevatedHigh: elevatedHigh,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textMuted: textMuted,
    accent: accent,
    accentBright: accentBright,
    accentDeep: accentDeep,
    accentMuted: accentMuted,
    champagne: champagne,
    success: success,
    warning: warning,
    danger: danger,
    divider: divider,
    dividerFaint: dividerFaint,
    ambientGradient: ambientGradient,
    accentGradient: accentGradient,
    cardGradient: cardGradient,
  );
}

/// Light counterpart — soft lilac-white surfaces, the same accent hue
/// deepened slightly for contrast against white.
class _Light {
  static const Color background = Color(0xFFFAF9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color elevated = Color(0xFFF3F1F8);
  static const Color elevatedHigh = Color(0xFFEAE6F4);

  static const Color textPrimary = Color(0xFF1B1B1F);
  static const Color textSecondary = Color(0xFF55545F);
  static const Color textMuted = Color(0xFF8B8A94);

  static const Color accent = Color(0xFF7C6BC9);
  static const Color accentBright = Color(0xFF9C8CE0);
  static const Color accentDeep = Color(0xFF5A4A96);
  static const Color accentMuted = Color(0xFF8E7FC7);

  static const Color champagne = Color(0xFFC9A868);

  static const Color success = Color(0xFF3F9B6C);
  static const Color warning = Color(0xFFC98A2E);
  static const Color danger = Color(0xFFC24B4B);

  static const Color divider = Color(0xFFE4E1EC);
  static const Color dividerFaint = Color(0xFFEDEBF3);

  static const LinearGradient ambientGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF1EDFA), background],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBright, accent, accentDeep],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [elevatedHigh, surface],
  );

  static const AppPalette values = AppPalette(
    background: background,
    surface: surface,
    elevated: elevated,
    elevatedHigh: elevatedHigh,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textMuted: textMuted,
    accent: accent,
    accentBright: accentBright,
    accentDeep: accentDeep,
    accentMuted: accentMuted,
    champagne: champagne,
    success: success,
    warning: warning,
    danger: danger,
    divider: divider,
    dividerFaint: dividerFaint,
    ambientGradient: ambientGradient,
    accentGradient: accentGradient,
    cardGradient: cardGradient,
  );
}
