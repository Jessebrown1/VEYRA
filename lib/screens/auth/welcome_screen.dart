import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/theme_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
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
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.dividerFaint, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                      ),
                      child: Text(
                        'I already have an account',
                        style: AppTextStyles.bodyEmphasis.copyWith(color: AppColors.textPrimary),
                      ),
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
