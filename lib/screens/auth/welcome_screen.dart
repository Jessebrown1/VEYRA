import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -140,
            left: -60,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.glow(AppColors.accent, opacity: 0.22),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Text('VEYRA', style: AppTextStyles.wordmark),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "Let's create someone special.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.hero,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Build a companion that feels like yours.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                  const Spacer(flex: 4),
                  PrimaryButton(
                    label: 'Begin',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(
                    label: 'Already have an account? Log in',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
