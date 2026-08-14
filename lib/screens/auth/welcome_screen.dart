import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/theme_controller.dart';
import '../../theme/app_colors.dart';
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

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─────────────────────────────────────────────
          // BACKGROUND GLOW
          // ─────────────────────────────────────────────

          Positioned(
            top: -180,
            left: -120,
            child: _GlowOrb(
              size: 420,
              color: AppColors.accent,
              opacity: 0.16,
            ),
          ),

          Positioned(
            top: size.height * 0.32,
            right: -220,
            child: _GlowOrb(
              size: 430,
              color: AppColors.accent,
              opacity: 0.07,
            ),
          ),

          Positioned(
            bottom: -260,
            left: size.width * 0.15,
            child: _GlowOrb(
              size: 420,
              color: AppColors.accent,
              opacity: 0.05,
            ),
          ),

          // ─────────────────────────────────────────────
          // DECORATIVE ORBIT
          // ─────────────────────────────────────────────

          Positioned(
            top: size.height * 0.15,
            right: -95,
            child: _OrbitDecoration(),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                children: [
                  // ─────────────────────────────────────
                  // TOP BRAND
                  // ─────────────────────────────────────

                  const Spacer(flex: 2),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          'VEYRA',
                          style: AppTextStyles.wordmark.copyWith(
                            letterSpacing: 8,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.18),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'YOUR COMPANION • YOUR WORLD',
                                style: AppTextStyles.bodyEmphasis.copyWith(
                                  fontSize: 9,
                                  letterSpacing: 1.4,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ─────────────────────────────────────
                  // HERO CONTENT
                  // ─────────────────────────────────────

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          "Let's create",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.hero.copyWith(
                            fontSize: 40,
                            height: 1.05,
                          ),
                        ),

                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.accent.withOpacity(0.75),
                                AppColors.accent,
                                AppColors.accent.withOpacity(0.7),
                              ],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'someone special.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.hero.copyWith(
                              fontSize: 40,
                              height: 1.05,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 330,
                          ),
                          child: Text(
                            'Build a companion with a personality, presence, and story that feels uniquely yours.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              height: 1.65,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ─────────────────────────────────────
                  // ACTION AREA
                  // ─────────────────────────────────────

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1300),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        // Primary CTA
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.18),
                                blurRadius: 28,
                                spreadRadius: -4,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: PrimaryButton(
                            label: 'Begin',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Secondary CTA
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  AppColors.textPrimary.withOpacity(0.025),
                              side: BorderSide(
                                color: AppColors.dividerFaint.withOpacity(0.9),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'I already have an account',
                                  style: AppTextStyles.bodyEmphasis.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 17,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Microcopy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 13,
                              color: AppColors.textSecondary.withOpacity(0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Private by design',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 11,
                                color:
                                    AppColors.textSecondary.withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// GLOW ORB
// ─────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(opacity * 0.35),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// ORBIT DECORATION
// ─────────────────────────────────────────────────────

class _OrbitDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 190,
        height: 190,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.dividerFaint.withOpacity(0.25),
                  width: 1,
                ),
              ),
            ),

            Transform.rotate(
              angle: -0.45,
              child: Container(
                width: 140,
                height: 190,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.10),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.35),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}