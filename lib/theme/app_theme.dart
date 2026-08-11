import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(AppColors.darkPalette, Brightness.dark);

  static ThemeData get light => _build(AppColors.lightPalette, Brightness.light);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      primaryColor: p.accent,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.accent,
        onPrimary: p.background,
        secondary: p.accent,
        onSecondary: p.background,
        surface: p.surface,
        onSurface: p.textPrimary,
        error: p.danger,
        onError: p.background,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display,
        headlineLarge: AppTextStyles.headline,
        titleLarge: AppTextStyles.title,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodyEmphasis,
        bodySmall: AppTextStyles.caption,
        labelSmall: AppTextStyles.microcopy,
      ),
      dividerColor: p.divider,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title,
        iconTheme: IconThemeData(color: p.textPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.elevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.dividerFaint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
        hintStyle: AppTextStyles.body,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
