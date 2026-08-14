import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/theme_controller.dart';
import '../../services/location_service.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import 'notification_permission_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState
    extends State<LocationPermissionScreen>
    with TickerProviderStateMixin {
  final _locationService = LocationService();

  bool _requesting = false;

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
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
    String? area,
  }) async {
    context
        .read<OnboardingController>()
        .setLocationEnabled(granted, area: area);

    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 500),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const NotificationPermissionScreen();
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
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
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

    final result =
        await _locationService.requestPermission();
    final granted = result == LocationPermissionResult.granted;

    String? area;
    if (granted) {
      area = await _locationService.getApproximateArea();
    }

    if (!mounted) return;

    setState(() {
      _requesting = false;
    });

    await _continueTo(
      granted: granted,
      area: area,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return OnboardingScaffold(
      step: 6,
      totalSteps: 7,
      title: 'Let me know where you are.',
      subtitle:
          'A little context can make your companion feel more connected to your world.',

      child: AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) {
          final value =
              CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ).value;

          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(
                0,
                24 * (1 - value),
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
              const SizedBox(height: 8),

              // ═══════════════════════════════
              // LOCATION VISUAL
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
                  child: const _LocationOrb(),
                ),
              ),

              const SizedBox(height: 28),

              // ═══════════════════════════════
              // WHY LOCATION
              // ═══════════════════════════════

              Text(
                'WHY IT HELPS',
                style: AppTextStyles.bodyEmphasis
                    .copyWith(
                  fontSize: 10,
                  letterSpacing: 1.8,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              _InfoTile(
                icon: Icons
                    .explore_outlined,
                title: 'More relevant conversations',
                description:
                    'Your companion can understand your surroundings and make context-aware suggestions.',
                delay: 0,
              ),

              const SizedBox(height: 9),

              _InfoTile(
                icon: Icons
                    .auto_awesome_outlined,
                title: 'A more personal experience',
                description:
                    'Location can help VEYRA make certain interactions feel more natural and timely.',
                delay: 100,
              ),

              const SizedBox(height: 9),

              _InfoTile(
                icon: Icons
                    .shield_outlined,
                title: 'You stay in control',
                description:
                    'Location access is optional and can be changed anytime from your settings.',
                delay: 200,
              ),

              const SizedBox(height: 18),

              // ═══════════════════════════════
              // PRIVACY MESSAGE
              // ═══════════════════════════════

              AnimatedContainer(
                duration:
                    const Duration(milliseconds: 300),
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
                    Icon(
                      Icons
                          .lock_outline_rounded,
                      size: 16,
                      color: AppColors.accent
                          .withOpacity(0.8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your permission is required before VEYRA can access your location.',
                        style:
                            AppTextStyles.body.copyWith(
                          fontSize: 11,
                          height: 1.45,
                          color:
                              AppColors.textSecondary,
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
          PrimaryButton(
            label: _requesting
                ? 'Waiting for permission…'
                : 'Allow Location',
            enabled: !_requesting,
            onPressed: _requesting
                ? null
                : _allow,
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
                  : () =>
                      _continueTo(
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
// LOCATION ORB
// ═══════════════════════════════════════════════════════

class _LocationOrb extends StatefulWidget {
  const _LocationOrb();

  @override
  State<_LocationOrb> createState() =>
      _LocationOrbState();
}

class _LocationOrbState
    extends State<_LocationOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // ═════════════════════════════
              // OUTER RADAR RINGS
              // ═════════════════════════════

              ...List.generate(
                3,
                (index) {
                  final progress =
                      (_controller.value +
                              index / 3) %
                          1.0;

                  final scale =
                      0.35 +
                          progress * 0.65;

                  final opacity =
                      (1 - progress) * 0.20;

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 160,
                      height: 160,
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
                          .withOpacity(
                        0.18,
                      ),
                      AppColors.accent
                          .withOpacity(
                        0.05,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // ═════════════════════════════
              // ORB
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
                          .withOpacity(0.28),
                      blurRadius: 35,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons
                      .location_on_rounded,
                  size: 36,
                  color:
                      AppColors.background,
                ),
              ),

              // ═════════════════════════════
              // ORBITING DOT
              // ═════════════════════════════

              Transform.rotate(
                angle:
                    _controller.value *
                        math.pi *
                        2,
                child: Align(
                  alignment:
                      Alignment.topCenter,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 14,
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
                              0.65,
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
// INFORMATION TILE
// ═══════════════════════════════════════════════════════

class _InfoTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final int delay;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.delay,
  });

  @override
  State<_InfoTile> createState() =>
      _InfoTileState();
}

class _InfoTileState extends State<_InfoTile>
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
              15 * (1 - value),
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