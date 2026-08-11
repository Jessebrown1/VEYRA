import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'state/app_state.dart';
import 'state/onboarding_controller.dart';
import 'state/theme_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: const VeyraApp(),
    ),
  );
}
 
  