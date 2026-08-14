import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../state/theme_controller.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../auth/biometric_lock_screen.dart';
import '../auth/welcome_screen.dart';
import '../home/home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _ambientController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _loadingOpacity;

  @override
  void initState() {
    super.initState();

    // Make the splash completely fullscreen.
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        0.05,
        0.42,
        curve: Curves.easeOut,
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.72,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(
          0.0,
          0.50,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _glowOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        0.0,
        0.75,
        curve: Curves.easeOut,
      ),
    );

    _ringOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        0.18,
        0.80,
        curve: Curves.easeOut,
      ),
    );

    _loadingOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        0.50,
        0.90,
        curve: Curves.easeOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _bootstrap(),
    );
  }

  Future<void> _bootstrap() async {
    final appState = context.read<AppState>();

    // Wake AI service while splash is running.
    appState.apiClient.warmupAi();

    // Load existing session.
    await appState.loadFromSession();

    if (!mounted) return;

    // Keep splash visible for a while.
    await Future.delayed(
      const Duration(milliseconds: 3500),
    );

    if (!mounted) return;

    Widget destination;

    if (appState.status == AppLaunchStatus.ready) {
      final biometricEnabled =
          await appState.biometrics.isEnabled;

      destination = biometricEnabled
          ? const BiometricLockScreen()
          : const HomeShell();
    } else {
      destination = const WelcomeScreen();
    }

    if (!mounted) return;

    // Restore normal system UI before leaving splash.
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) {
          return destination;
        },
        transitionDuration: const Duration(
          milliseconds: 800,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 400,
        ),
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          final scaleAnimation = Tween<double>(
            begin: 0.97,
            end: 1.0,
          ).animate(
            fadeAnimation,
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _ambientController.dispose();
    _pulseController.dispose();

    // Safety: restore system UI if this screen gets disposed.
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _introController,
            _ambientController,
            _pulseController,
          ]),
          builder: (context, child) {
            final ambient =
                _ambientController.value;

            final pulse =
                _pulseController.value;

            final rotation =
                ambient * math.pi * 2;

            final breathing =
                0.94 + (pulse * 0.06);

            return Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // ═════════════════════════════════════
                // BACKGROUND
                // ═════════════════════════════════════

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                  ),
                ),

                // ═════════════════════════════════════
                // TOP ATMOSPHERIC GLOW
                // ═════════════════════════════════════

                Positioned(
                  top: -180,
                  left: -180,
                  child: _AtmosphericGlow(
                    size: 450,
                    opacity:
                        _glowOpacity.value * 0.25,
                  ),
                ),

                // ═════════════════════════════════════
                // BOTTOM ATMOSPHERIC GLOW
                // ═════════════════════════════════════

                Positioned(
                  bottom: -220,
                  right: -190,
                  child: _AtmosphericGlow(
                    size: 470,
                    opacity:
                        _glowOpacity.value * 0.14,
                  ),
                ),

                // ═════════════════════════════════════
                // CENTRAL GLOW
                // ═════════════════════════════════════

                Center(
                  child: Transform.scale(
                    scale: breathing,
                    child: Opacity(
                      opacity:
                          _glowOpacity.value * 0.45,
                      child: Container(
                        width: 360,
                        height: 360,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accent
                                  .withOpacity(0.32),
                              AppColors.accent
                                  .withOpacity(0.12),
                              Colors.transparent,
                            ],
                            stops: const [
                              0.0,
                              0.42,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ═════════════════════════════════════
                // OUTER ORBIT
                // ═════════════════════════════════════

                Center(
                  child: Transform.rotate(
                    angle: rotation,
                    child: Opacity(
                      opacity:
                          _ringOpacity.value * 0.85,
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: CustomPaint(
                          painter: _OrbitPainter(
                            color: AppColors.accent,
                            strokeOpacity: 0.14,
                            glowOpacity: 0.06,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ═════════════════════════════════════
                // SECOND ORBIT
                // ═════════════════════════════════════

                Center(
                  child: Transform.rotate(
                    angle: -rotation * 0.65,
                    child: Opacity(
                      opacity:
                          _ringOpacity.value * 0.6,
                      child: SizedBox(
                        width: 245,
                        height: 245,
                        child: CustomPaint(
                          painter: _OrbitPainter(
                            color: AppColors.accent,
                            oval: true,
                            strokeOpacity: 0.16,
                            glowOpacity: 0.05,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ═════════════════════════════════════
                // INNER ORBIT
                // ═════════════════════════════════════

                Center(
                  child: Transform.rotate(
                    angle: rotation * 0.35,
                    child: Opacity(
                      opacity:
                          _ringOpacity.value * 0.38,
                      child: SizedBox(
                        width: 185,
                        height: 185,
                        child: CustomPaint(
                          painter: _OrbitPainter(
                            color: AppColors.accent,
                            oval: true,
                            strokeOpacity: 0.12,
                            glowOpacity: 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ═════════════════════════════════════
                // MOVING PARTICLES
                // ═════════════════════════════════════

                ..._buildParticles(ambient),

                // ═════════════════════════════════════
                // VEYRA LOGO
                // ═════════════════════════════════════

                Center(
                  child: Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          math.sin(
                                ambient *
                                    math.pi *
                                    2,
                              ) *
                              3,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors
                                        .accent
                                        .withOpacity(
                                      0.10 +
                                          (pulse *
                                              0.10),
                                    ),
                                    blurRadius:
                                        55 +
                                            (pulse *
                                                20),
                                    spreadRadius:
                                        4 +
                                            (pulse *
                                                5),
                                  ),
                                ],
                              ),
                              child: ShaderMask(
                                shaderCallback:
                                    (bounds) {
                                  return AppColors
                                      .accentGradient
                                      .createShader(
                                    bounds,
                                  );
                                },
                                child: Text(
                                  'VEYRA',
                                  style: AppTextStyles
                                      .display
                                      .copyWith(
                                    color:
                                        Colors.white,
                                    letterSpacing: 9,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            Transform.scale(
                              scaleX:
                                  _loadingOpacity.value,
                              child: Container(
                                width: 40,
                                height: 1,
                                decoration:
                                    BoxDecoration(
                                  color: AppColors
                                      .accent
                                      .withOpacity(
                                    0.55,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors
                                          .accent
                                          .withOpacity(
                                        0.35,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            Opacity(
                              opacity:
                                  _loadingOpacity.value,
                              child:
                                  _LoadingIndicator(
                                animation:
                                    ambient,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ═════════════════════════════════════
                // BOTTOM STATUS
                // ═════════════════════════════════════

                Positioned(
                  bottom: 45,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity:
                          _loadingOpacity.value *
                              0.7,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration:
                                BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  AppColors.accent,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors
                                      .accent
                                      .withOpacity(
                                    0.5,
                                  ),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'INITIALIZING VEYRA',
                            style: AppTextStyles.body
                                .copyWith(
                              fontSize: 9,
                              letterSpacing: 2.2,
                              color: AppColors
                                  .textSecondary
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildParticles(
    double animation,
  ) {
    final particles = <Widget>[];

    const particleData = [
      _ParticleData(
        angle: 0.25,
        radius: 150,
        size: 3,
        speed: 1.0,
      ),
      _ParticleData(
        angle: 1.45,
        radius: 125,
        size: 2,
        speed: 0.75,
      ),
      _ParticleData(
        angle: 2.35,
        radius: 165,
        size: 2.5,
        speed: 1.15,
      ),
      _ParticleData(
        angle: 3.15,
        radius: 135,
        size: 2,
        speed: 0.65,
      ),
      _ParticleData(
        angle: 4.20,
        radius: 155,
        size: 3,
        speed: 0.9,
      ),
      _ParticleData(
        angle: 5.35,
        radius: 120,
        size: 2,
        speed: 1.2,
      ),
    ];

    for (final particle in particleData) {
      final angle =
          particle.angle +
          animation *
              math.pi *
              2 *
              particle.speed;

      final x =
          math.cos(angle) * particle.radius;

      final y =
          math.sin(angle) * particle.radius;

      final opacity =
          0.25 +
          math.sin(
                animation *
                    math.pi *
                    2 *
                    particle.speed,
              ).abs() *
              0.55;

      particles.add(
        Center(
          child: Transform.translate(
            offset: Offset(x, y),
            child: Opacity(
              opacity:
                  _ringOpacity.value *
                      opacity,
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration:
                    BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      AppColors.accent,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent
                          .withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return particles;
  }
}

// ═══════════════════════════════════════════════════════
// ATMOSPHERIC GLOW
// ═══════════════════════════════════════════════════════

class _AtmosphericGlow extends StatelessWidget {
  final double size;
  final double opacity;

  const _AtmosphericGlow({
    required this.size,
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
              AppColors.accent.withOpacity(
                opacity,
              ),
              AppColors.accent.withOpacity(
                opacity * 0.25,
              ),
              Colors.transparent,
            ],
            stops: const [
              0.0,
              0.45,
              1.0,
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ORBIT PAINTER
// ═══════════════════════════════════════════════════════

class _OrbitPainter extends CustomPainter {
  final Color color;
  final bool oval;
  final double strokeOpacity;
  final double glowOpacity;

  _OrbitPainter({
    required this.color,
    this.oval = false,
    this.strokeOpacity = 0.15,
    this.glowOpacity = 0.05,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center =
        Offset(size.width / 2, size.height / 2);

    final rect = Rect.fromCenter(
      center: center,
      width: oval
          ? size.width * 0.58
          : size.width * 0.78,
      height: oval
          ? size.height * 0.94
          : size.height * 0.78,
    );

    final paint = Paint()
      ..color =
          color.withOpacity(strokeOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawOval(rect, paint);

    final glowPaint = Paint()
      ..color =
          color.withOpacity(glowOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        9,
      );

    canvas.drawOval(rect, glowPaint);

    // Small orbit highlight.
    final highlightPaint = Paint()
      ..color =
          color.withOpacity(strokeOpacity * 2);

    const angle = -1.0;

    final highlight = Offset(
      center.dx +
          math.cos(angle) *
              rect.width /
              2,
      center.dy +
          math.sin(angle) *
              rect.height /
              2,
    );

    canvas.drawCircle(
      highlight,
      2,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _OrbitPainter oldDelegate,
  ) {
    return oldDelegate.color != color ||
        oldDelegate.oval != oval ||
        oldDelegate.strokeOpacity !=
            strokeOpacity ||
        oldDelegate.glowOpacity !=
            glowOpacity;
  }
}

// ═══════════════════════════════════════════════════════
// LOADING INDICATOR
// ═══════════════════════════════════════════════════════

class _LoadingIndicator extends StatelessWidget {
  final double animation;

  const _LoadingIndicator({
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) {
          final phase =
              (animation +
                      index * 0.12) %
                  1.0;

          final wave = math.sin(
            phase * math.pi * 2,
          );

          final opacity =
              0.25 +
              wave.abs() * 0.7;

          final scale =
              0.72 +
              wave.abs() * 0.28;

          return Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 5,
                height: 5,
                decoration:
                    BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent
                      .withOpacity(opacity),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent
                          .withOpacity(
                        opacity * 0.45,
                      ),
                      blurRadius: 7,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// PARTICLE DATA
// ═══════════════════════════════════════════════════════

class _ParticleData {
  final double angle;
  final double radius;
  final double size;
  final double speed;

  const _ParticleData({
    required this.angle,
    required this.radius,
    required this.size,
    required this.speed,
  });
}