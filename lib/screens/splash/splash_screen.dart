import 'package:flutter/material.dart';
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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
  );
  late final Animation<double> _scale = Tween(begin: 0.92, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
  );
  late final Animation<double> _glow = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final appState = context.read<AppState>();
    await appState.loadFromSession();
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Widget destination;
    if (appState.status == AppLaunchStatus.ready) {
      final biometricEnabled = await appState.biometrics.isEnabled;
      destination = biometricEnabled ? const BiometricLockScreen() : const HomeShell();
    } else {
      destination = const WelcomeScreen();
    }
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: _glow.value * 0.5,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.glow(AppColors.accent, opacity: 0.6),
                    ),
                  ),
                ),
                Opacity(
                  opacity: _opacity.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: ShaderMask(
                      shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
                      child: Text('VEYRA', style: AppTextStyles.display.copyWith(color: Colors.white)),
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
}
