import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../home/home_shell.dart';

class PersonalizedWelcomeScreen extends StatefulWidget {
  const PersonalizedWelcomeScreen({super.key});

  @override
  State<PersonalizedWelcomeScreen> createState() => _PersonalizedWelcomeScreenState();
}

class _PersonalizedWelcomeScreenState extends State<PersonalizedWelcomeScreen> {
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWelcomeMessage());
  }

  Future<void> _loadWelcomeMessage() async {
    final appState = context.read<AppState>();
    final conversationId = appState.conversationId;
    if (conversationId == null) return;

    final messages = await appState.conversationApi.listMessages(conversationId);
    if (!mounted) return;
    setState(() {
      _message = messages.isNotEmpty ? messages.first.content : "Hey, I'm ${appState.companion!.name}.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final companion = appState.companion!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 60,
            left: -80,
            right: -80,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.glow(AppColors.accent, opacity: 0.24),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    width: 96,
                    height: 96,
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.accentGradient,
                    ),
                    child: CircleAvatar(
                      backgroundColor: AppColors.surface,
                      child: Text(
                        companion.name.isNotEmpty ? companion.name[0].toUpperCase() : '?',
                        style: AppTextStyles.display,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('VEYRA', style: AppTextStyles.wordmark),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _message == null
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accent),
                          )
                        : Text(
                            _message!,
                            key: ValueKey(_message),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.title,
                          ),
                  ),
                  const Spacer(flex: 3),
                  PrimaryButton(
                    label: 'Talk to ${companion.name}',
                    enabled: _message != null,
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeShell()),
                      (route) => false,
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
