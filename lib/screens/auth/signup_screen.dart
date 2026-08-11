import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import '../../state/app_state.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/veyra_text_field.dart';
import '../onboarding/personality_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  bool get _canContinue =>
      _emailController.text.trim().contains('@') && _passwordController.text.length >= 8 && !_submitting;

  Future<void> _continue() async {
    setState(() => _submitting = true);
    try {
      final appState = context.read<AppState>();
      await appState.authApi.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      context.read<OnboardingController>().setUserEmail(_emailController.text.trim());
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PersonalityScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      final message = ApiClient.toApiException(e).message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
              Text('GET STARTED', style: AppTextStyles.eyebrow),
              const SizedBox(height: AppSpacing.xs),
              Text("Let's begin.", style: AppTextStyles.display),
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
                hint: 'Password (min. 8 characters)',
                obscureText: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: _submitting ? 'Creating account…' : 'Continue',
                enabled: _canContinue,
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
