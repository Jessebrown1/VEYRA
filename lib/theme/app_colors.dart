import 'package:flutter/material.dart';

/// Centralized VEYRA palette. Never hard-code colors elsewhere — reference these.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B0B0D);
  static const Color surface = Color(0xFF151519);
  static const Color elevated = Color(0xFF1D1D22);
  static const Color elevatedHigh = Color(0xFF232329);

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA4A4AA);
  static const Color textMuted = Color(0xFF6F6F77);

  /// Refined warm violet/lilac accent — the primary accent color for the app.
  static const Color accent = Color(0xFFB7A2F3);
  static const Color accentBright = Color(0xFFD3C4FA);
  static const Color accentDeep = Color(0xFF6E5AA8);
  static const Color accentMuted = Color(0xFF7C6BA8);

  /// Warm champagne — used sparingly for VEYRA+ / premium moments only,
  /// never as a general UI color.
  static const Color champagne = Color(0xFFE3C793);

  static const Color success = Color(0xFF7FD9A8);
  static const Color warning = Color(0xFFE8C27A);
  static const Color danger = Color(0xFFE08A8A);

  static const Color divider = Color(0xFF26262C);
  static const Color dividerFaint = Color(0xFF1B1B20);

  /// Subtle diagonal sheen used behind hero moments (splash, welcome,
  /// personalized welcome, creation). Never applied to dense content areas.
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

  static RadialGradient glow(Color color, {double opacity = 0.35}) => RadialGradient(
        colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
      );
}
