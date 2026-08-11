import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash/splash_screen.dart';
import 'state/theme_controller.dart';
import 'theme/app_theme.dart';

class VeyraApp extends StatelessWidget {
  const VeyraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeController>().mode;
    return MaterialApp(
      title: 'VEYRA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: const SplashScreen(),
    );
  }
}
