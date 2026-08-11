import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/veyra_text_field.dart';
import '../home/home_shell.dart';
import '../onboarding/personality_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  bool get _canContinue =>
      _emailController.text.trim().contains('@') && _passwordController.text.isNotEmpty && !_submitting;

  Future<void> _continue() async {
    setState(() => _submitting = true);
    try {
      final appState = context.read<AppState>();
      await appState.authApi.login(email: _emailController.text.trim(), password: _passwordController.text);
      await appState.loadFromSession();
      if (!mounted) return;

      if (appState.status == AppLaunchStatus.ready) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeShell()),
          (route) => false,
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PersonalityScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = ApiClient.toApiException(e).message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _notAvailable(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in isn\'t available in this build yet.')),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: ListView(
            children: [
              const SizedBox(height: AppSpacing.md),
              Text('WELCOME BACK', style: AppTextStyles.eyebrow),
              const SizedBox(height: AppSpacing.xs),
              Text('Good to see you.', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.xl),
              VeyraTextField(
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              VeyraTextField(
                controller: _passwordController,
                hint: 'Password',
                obscureText: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: SecondaryButton(label: 'Forgot password?', onPressed: () {}),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: _submitting ? 'Signing in…' : 'Continue',
                enabled: _canContinue,
                onPressed: _continue,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text('or', style: AppTextStyles.caption),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => _notAvailable('Apple'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: AppColors.dividerFaint),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.apple, size: 20, color: AppColors.textPrimary),
                label: Text('Continue with Apple', style: AppTextStyles.bodyEmphasis),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => _notAvailable('Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: AppColors.dividerFaint),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.g_mobiledata, size: 24, color: AppColors.textPrimary),
                label: Text('Continue with Google', style: AppTextStyles.bodyEmphasis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
