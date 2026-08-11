import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Central typography hierarchy. Built once here so the rest of the app
/// never calls GoogleFonts directly.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    double? letterSpacing,
    double? height,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle get hero => _base(
        size: 40,
        weight: FontWeight.w600,
        letterSpacing: -0.8,
        height: 1.08,
      );

  static TextStyle get display => _base(
        size: 34,
        weight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.15,
      );

  /// The "VEYRA" wordmark — wide tracking, used only for the brand mark itself.
  static TextStyle get wordmark => _base(
        size: 14,
        weight: FontWeight.w600,
        letterSpacing: 6,
        height: 1,
        color: AppColors.textSecondary,
      );

  /// Small accent-colored label, e.g. above a headline or on a premium badge.
  static TextStyle get eyebrow => _base(
        size: 12,
        weight: FontWeight.w600,
        letterSpacing: 2,
        height: 1.2,
        color: AppColors.accent,
      );

  static TextStyle get headline => _base(
        size: 26,
        weight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.2,
      );

  static TextStyle get title => _base(
        size: 19,
        weight: FontWeight.w600,
        height: 1.25,
      );

  static TextStyle get body => _base(
        size: 15,
        weight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyEmphasis => _base(
        size: 15,
        weight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get caption => _base(
        size: 13,
        weight: FontWeight.w400,
        height: 1.3,
        color: AppColors.textMuted,
      );

  static TextStyle get microcopy => _base(
        size: 11,
        weight: FontWeight.w500,
        letterSpacing: 0.4,
        height: 1.2,
        color: AppColors.textMuted,
      );
}
