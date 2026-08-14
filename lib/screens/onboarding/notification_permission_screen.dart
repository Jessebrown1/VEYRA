import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/theme_controller.dart';
import '../../services/notification_permission_service.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import 'companion_creation_screen.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen>
    with TickerProviderStateMixin {
  final _notificationService =
      NotificationPermissionService();

  bool _requesting = false;

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _continueTo({
    required bool granted,
  }) async {
    final controller =
        context.read<OnboardingController>();

    controller.setNotificationsEnabled(granted);

    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 650),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const CompanionCreationScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.97,
                end: 1.0,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _allow() async {
    if (_requesting) return;

    setState(() {
      _requesting = true;
    });

    final granted =
        await _notificationService.requestPermission();

    if (!mounted) return;

    setState(() {
      _requesting = false;
    });

    await _continueTo(granted: granted);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final companionName =
        context
            .watch<OnboardingController>()
            .companionName;

    return OnboardingScaffold(
      step: 7,
      totalSteps: 7,

      title:
          'Let $companionName check in on you.',

      subtitle:
          'Stay connected without feeling overwhelmed.',

      child: AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) {
          final value = CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ).value;

          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(
                0,
                25 * (1 - value),
              ),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),

              // ═══════════════════════════════
              // NOTIFICATION EXPERIENCE
              // ═══════════════════════════════

              Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _pulseController,
                    _floatController,
                  ]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        math.sin(
                              _floatController
                                      .value *
                                  math.pi,
                            ) *
                            5,
                      ),
                      child: child,
                    );
                  },
                  child: _NotificationOrb(
                    pulse:
                        _pulseController,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ═══════════════════════════════
              // SECTION LABEL
              // ═══════════════════════════════

              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors
                              .accent
                              .withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'A LITTLE PRESENCE',
                    style: AppTextStyles
                        .bodyEmphasis
                        .copyWith(
                      fontSize: 10,
                      letterSpacing: 1.7,
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ═══════════════════════════════
              // BENEFIT CARDS
              // ═══════════════════════════════

              _NotificationFeature(
                icon:
                    Icons.chat_bubble_outline_rounded,
                title:
                    '$companionName can reach out',
                description:
                    'Your companion can gently check in when there has been some time between conversations.',
                delay: 0,
              ),

              const SizedBox(height: 9),

              _NotificationFeature(
                icon:
                    Icons.nightlight_outlined,
                title:
                    'Gentle reminders',
                description:
                    'Useful reminders can arrive when the timing feels right, including later in the evening.',
                delay: 100,
              ),

              const SizedBox(height: 9),

              _NotificationFeature(
                icon:
                    Icons.tune_rounded,
                title:
                    'You control the rhythm',
                description:
                    'Quiet hours, frequency and notifications can always be changed later.',
                delay: 200,
              ),

              const SizedBox(height: 16),

              // ═══════════════════════════════
              // PRIVACY / CONTROL
              // ═══════════════════════════════

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent
                      .withOpacity(0.035),
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accent
                        .withOpacity(0.08),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent
                            .withOpacity(0.08),
                      ),
                      child: Icon(
                        Icons
                            .notifications_active_outlined,
                        size: 15,
                        color:
                            AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Notifications are completely optional. You stay in control of when and how often $companionName can reach you.',
                        style:
                            AppTextStyles.body
                                .copyWith(
                          fontSize: 11,
                          height: 1.45,
                          color: AppColors
                              .textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ═══════════════════════════════════════
      // FOOTER
      // ═══════════════════════════════════════

      footer: Column(
        children: [
          AnimatedSwitcher(
            duration:
                const Duration(milliseconds: 250),
            child: PrimaryButton(
              key: ValueKey(_requesting),
              label: _requesting
                  ? 'Waiting for permission…'
                  : 'Allow Notifications',
              enabled: !_requesting,
              onPressed:
                  _requesting ? null : _allow,
            ),
          ),

          const SizedBox(
            height: AppSpacing.xs,
          ),

          AnimatedOpacity(
            duration:
                const Duration(milliseconds: 250),
            opacity: _requesting ? 0.35 : 1,
            child: SecondaryButton(
              label: 'Not Now',
              onPressed: _requesting
                  ? null
                  : () => _continueTo(
                        granted: false,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// NOTIFICATION ORB
// ═══════════════════════════════════════════════════════

class _NotificationOrb extends StatelessWidget {
  final Animation<double> pulse;

  const _NotificationOrb({
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // ═════════════════════════════
              // PULSE RINGS
              // ═════════════════════════════

              ...List.generate(
                3,
                (index) {
                  final progress =
                      (pulse.value +
                              index / 3) %
                          1.0;

                  final scale =
                      0.38 +
                          progress * 0.62;

                  final opacity =
                      (1 - progress) * 0.18;

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 155,
                      height: 155,
                      decoration:
                          BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors
                              .accent
                              .withOpacity(
                            opacity,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ═════════════════════════════
              // AMBIENT GLOW
              // ═════════════════════════════

              Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent
                          .withOpacity(0.18),
                      AppColors.accent
                          .withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // ═════════════════════════════
              // CENTRAL ORB
              // ═════════════════════════════

              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      AppColors.accentGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent
                          .withOpacity(0.3),
                      blurRadius: 36,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons
                      .notifications_none_rounded,
                  size: 37,
                  color:
                      AppColors.background,
                ),
              ),

              // ═════════════════════════════
              // FLOATING MESSAGE
              // ═════════════════════════════

              Positioned(
                top: 27,
                right: 24,
                child: Transform.scale(
                  scale:
                      0.92 +
                          math.sin(
                                pulse.value *
                                    math.pi *
                                    2,
                              ) *
                              0.08,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .background,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      border: Border.all(
                        color: AppColors.divider,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(
                            0.10,
                          ),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .auto_awesome_rounded,
                          size: 10,
                          color:
                              AppColors.accent,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          'hey...',
                          style: AppTextStyles
                              .bodyEmphasis
                              .copyWith(
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ═════════════════════════════
              // SMALL ORBIT DOT
              // ═════════════════════════════

              Transform.rotate(
                angle:
                    pulse.value *
                        math.pi *
                        2,
                child: Align(
                  alignment:
                      Alignment.topCenter,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 12,
                    ),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color:
                            AppColors.accent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors
                                .accent
                                .withOpacity(
                              0.7,
                            ),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// FEATURE TILE
// ═══════════════════════════════════════════════════════

class _NotificationFeature
    extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final int delay;

  const _NotificationFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.delay,
  });

  @override
  State<_NotificationFeature> createState() =>
      _NotificationFeatureState();
}

class _NotificationFeatureState
    extends State<_NotificationFeature>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 600),
    );

    Future.delayed(
      Duration(milliseconds: widget.delay),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ).value;

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              16 * (1 - value),
              0,
            ),
            child: child,
          ),
        );
      },
      child: Container(
        padding:
            const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.textPrimary
              .withOpacity(0.018),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.divider
                .withOpacity(0.7),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent
                    .withOpacity(0.07),
              ),
              child: Icon(
                widget.icon,
                size: 18,
                color: AppColors.accent
                    .withOpacity(0.85),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTextStyles
                        .bodyEmphasis
                        .copyWith(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.description,
                    style: AppTextStyles.body
                        .copyWith(
                      fontSize: 11,
                      height: 1.4,
                      color: AppColors
                          .textSecondary,
                    ),
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