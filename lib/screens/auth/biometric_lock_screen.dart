import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../state/onboarding_controller.dart';
import '../../state/theme_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../home/home_shell.dart';
import 'welcome_screen.dart';

/// Shown at launch when the user has enabled biometric unlock — gates the
/// already-signed-in session behind Face ID / Touch ID / fingerprint rather
/// than asking for credentials again.
class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  bool _checking = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attempt());
  }

  Future<void> _attempt() async {
    setState(() {
      _checking = true;
      _failed = false;
    });
    final appState = context.read<AppState>();
    final companionName = appState.companion?.name ?? 'VEYRA';
    final ok = await appState.biometrics.authenticate(reason: 'Unlock $companionName');
    if (!mounted) return;
    setState(() => _checking = false);
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
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
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final appState = context.watch<AppState>();
    final companionName = appState.companion?.name ?? 'VEYRA';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.accentGradient,
                  boxShadow: AppShadows.accentGlowSoft,
                ),
                child: const Icon(Icons.fingerprint, color: Colors.black, size: 40),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Welcome back', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _checking
                    ? 'Confirming it\'s you…'
                    : _failed
                        ? "Couldn't verify — try again."
                        : 'Unlock to continue to $companionName.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const Spacer(flex: 3),
              if (!_checking) ...[
                PrimaryButton(label: 'Try again', onPressed: _attempt),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _signOutInstead,
                  child: Text('Sign out instead', style: AppTextStyles.body),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
