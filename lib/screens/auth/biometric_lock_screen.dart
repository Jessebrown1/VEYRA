import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../state/onboarding_controller.dart';
import '../../state/theme_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../home/home_shell.dart';
import 'welcome_screen.dart';

class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen>
    with TickerProviderStateMixin {
  bool _checking = false;
  bool _failed = false;

  late final AnimationController _pulseController;
  late final AnimationController _orbitController;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _attempt());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _attempt() async {
    setState(() {
      _checking = true;
      _failed = false;
    });

    final appState = context.read<AppState>();
    final companionName = appState.companion?.name ?? 'VEYRA';

    final ok = await appState.biometrics.authenticate(
      reason: 'Unlock $companionName',
    );

    if (!mounted) return;

    setState(() => _checking = false);

    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeShell(),
        ),
        (route) => false,
      );
    } else {
      setState(() => _failed = true);
    }
  }

  Future<void> _signOutInstead() async {
    await context.read<AppState>().signOut();

    if (!mounted) return;

    context.read<OnboardingController>().reset();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final appState = context.watch<AppState>();
    final companionName = appState.companion?.name ?? 'VEYRA';

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      body: Stack(
        children: [
          // ============================================================
          // ATMOSPHERIC BACKGROUND
          // ============================================================

          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF15101B),
                    Color(0xFF09080C),
                    Color(0xFF050507),
                  ],
                  stops: [0.0, 0.48, 1.0],
                ),
              ),
            ),
          ),

          // ============================================================
          // AMBIENT GLOW
          // ============================================================

          Positioned(
            top: -180,
            left: -150,
            child: _AmbientGlow(
              size: 470,
              color: const Color(0xFFB579DF),
              opacity: 0.13,
            ),
          ),

          Positioned(
            right: -180,
            top: 220,
            child: _AmbientGlow(
              size: 420,
              color: const Color(0xFF7650A0),
              opacity: 0.09,
            ),
          ),

          Positioned(
            bottom: -180,
            left: 40,
            child: _AmbientGlow(
              size: 360,
              color: const Color(0xFF9B65C5),
              opacity: 0.055,
            ),
          ),

          // ============================================================
          // SUBTLE GRID
          // ============================================================

          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _TechGridPainter(),
              ),
            ),
          ),

          // ============================================================
          // CONTENT
          // ============================================================

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        // ==================================================
                        // TOP BAR
                        // ==================================================

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFD8B8F3),
                                    Color(0xFF76518F),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB47BD7)
                                        .withOpacity(0.18),
                                    blurRadius: 22,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'V',
                                  style: TextStyle(
                                    color: Color(0xFF08070A),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'VEYRA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 54),

                        // ==================================================
                        // CONNECTION STATUS
                        // ==================================================

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            key: ValueKey('$_checking-$_failed'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.035),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.055),
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
                                    color: _failed
                                        ? const Color(0xFFE19A9A)
                                        : const Color(0xFFB99ADF),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_failed
                                                ? const Color(0xFFE19A9A)
                                                : const Color(0xFFB99ADF))
                                            .withOpacity(0.55),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _checking
                                      ? 'VERIFYING IDENTITY'
                                      : _failed
                                          ? 'VERIFICATION FAILED'
                                          : 'PRIVATE SESSION',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.38),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 42),

                        // ==================================================
                        // FUTURISTIC BIOMETRIC CORE
                        // ==================================================

                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _pulseController,
                            _orbitController,
                            _floatController,
                          ]),
                          builder: (context, child) {
                            final pulse = Curves.easeInOut.transform(
                              _pulseController.value,
                            );

                            final floating =
                                math.sin(_floatController.value * math.pi) *
                                    5;

                            return Transform.translate(
                              offset: Offset(0, -floating),
                              child: SizedBox(
                                width: 270,
                                height: 270,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Large atmospheric glow
                                    Container(
                                      width: 235 + pulse * 18,
                                      height: 235 + pulse * 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            const Color(0xFFB883DF)
                                                .withOpacity(
                                              0.13 + pulse * 0.03,
                                            ),
                                            const Color(0xFF6B477E)
                                                .withOpacity(0.035),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Orbital ring
                                    Transform.rotate(
                                      angle: _orbitController.value *
                                          math.pi *
                                          2,
                                      child: CustomPaint(
                                        size: const Size(220, 220),
                                        painter: _OrbitPainter(
                                          color: _failed
                                              ? const Color(0xFFE09C9C)
                                              : const Color(0xFFC79BE8),
                                        ),
                                      ),
                                    ),

                                    // Secondary orbit
                                    Transform.rotate(
                                      angle: -_orbitController.value *
                                          math.pi *
                                          2 *
                                          0.65,
                                      child: CustomPaint(
                                        size: const Size(185, 185),
                                        painter: _OrbitPainter(
                                          color: Colors.white.withOpacity(0.16),
                                          reverse: true,
                                        ),
                                      ),
                                    ),

                                    // Core glass orb
                                    Container(
                                      width: 128,
                                      height: 128,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          center: const Alignment(-0.3, -0.35),
                                          colors: [
                                            Colors.white.withOpacity(0.12),
                                            const Color(0xFF17131D),
                                            const Color(0xFF0B090D),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: _failed
                                              ? const Color(0xFFE3A5A5)
                                                  .withOpacity(0.42)
                                              : const Color(0xFFD0A9EF)
                                                  .withOpacity(0.30),
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_failed
                                                    ? const Color(0xFFE3A5A5)
                                                    : const Color(0xFFB67DDB))
                                                .withOpacity(0.20),
                                            blurRadius: 40,
                                            spreadRadius: 2,
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.55,
                                            ),
                                            blurRadius: 30,
                                            offset: const Offset(0, 15),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: _checking
                                              ? const SizedBox(
                                                  key: ValueKey('checking'),
                                                  width: 34,
                                                  height: 34,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 1.5,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                      Color(0xFFD6B8EF),
                                                    ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons
                                                      .fingerprint_rounded,
                                                  key: ValueKey(
                                                    _failed
                                                        ? 'failed'
                                                        : 'ready',
                                                  ),
                                                  size: 48,
                                                  color: _failed
                                                      ? const Color(0xFFE0A3A3)
                                                      : Colors.white
                                                          .withOpacity(0.9),
                                                ),
                                        ),
                                      ),
                                    ),

                                    // Small orbit node
                                    Positioned(
                                      top: 26,
                                      right: 55,
                                      child: Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFFD4B0EF),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFD4B0EF)
                                                  .withOpacity(0.8),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Bottom node
                                    Positioned(
                                      bottom: 30,
                                      left: 58,
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // ==================================================
                        // TITLE
                        // ==================================================

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _checking
                                ? 'Verifying you'
                                : _failed
                                    ? 'Access denied'
                                    : 'Welcome back',
                            key: ValueKey('$_checking-$_failed-title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              height: 1.05,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // AI DESCRIPTION
                        // ==================================================

                        Text(
                          _checking
                              ? 'Establishing a secure connection to your private space.'
                              : _failed
                                  ? 'We couldn’t confirm your identity.'
                                  : '$companionName is waiting for you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.42),
                            fontSize: 13,
                            height: 1.55,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 12),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _checking
                                ? 'SECURE BIOMETRIC HANDSHAKE'
                                : _failed
                                    ? 'Try again to continue'
                                    : 'YOUR CONVERSATION • YOUR SPACE • YOURS',
                            key: ValueKey('$_checking-$_failed-status'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _failed
                                  ? const Color(0xFFE0A3A3).withOpacity(0.65)
                                  : const Color(0xFFC9A5E5).withOpacity(0.48),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 42),

                        // ==================================================
                        // ACTION
                        // ==================================================

                        if (!_checking) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFD9B9F3),
                                    Color(0xFFA474C7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB77BDC)
                                        .withOpacity(0.18),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: PrimaryButton(
                                label: _failed
                                    ? 'Try again'
                                    : 'Unlock $companionName',
                                onPressed: _attempt,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          TextButton(
                            onPressed: _signOutInstead,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Use another account',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 34),

                        // ==================================================
                        // SECURITY CARD
                        // ==================================================

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.025),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.055),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 27,
                                height: 27,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFC79AE6)
                                      .withOpacity(0.08),
                                ),
                                child: Icon(
                                  Icons.shield_outlined,
                                  size: 14,
                                  color: const Color(0xFFD1B1E9)
                                      .withOpacity(0.55),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PRIVATE SESSION',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.42),
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Protected by device biometrics',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.25),
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// ================================================================
// AMBIENT GLOW
// ================================================================

class _AmbientGlow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _AmbientGlow({
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
              color.withOpacity(opacity * 0.3),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}


// ================================================================
// ORBITAL RINGS
// ================================================================

class _OrbitPainter extends CustomPainter {
  final Color color;
  final bool reverse;

  const _OrbitPainter({
    required this.color,
    this.reverse = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.78,
      height: size.height * 0.36,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = color.withOpacity(0.42);

    canvas.drawOval(rect, paint);

    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.8);

    final angle = reverse ? math.pi * 0.75 : math.pi * 0.2;

    final x = center.dx + (rect.width / 2) * math.cos(angle);
    final y = center.dy + (rect.height / 2) * math.sin(angle);

    canvas.drawCircle(
      Offset(x, y),
      2.4,
      nodePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.reverse != reverse;
  }
}


// ================================================================
// SUBTLE TECH GRID
// ================================================================

class _TechGridPainter extends CustomPainter {
  const _TechGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.018)
      ..strokeWidth = 0.5;

    const spacing = 42.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TechGridPainter oldDelegate) {
    return false;
  }
}