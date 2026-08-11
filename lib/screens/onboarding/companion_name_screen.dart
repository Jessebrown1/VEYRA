import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/theme_controller.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';
import 'user_name_screen.dart';

class CompanionNameScreen extends StatefulWidget {
  const CompanionNameScreen({super.key});

  @override
  State<CompanionNameScreen> createState() => _CompanionNameScreenState();
}

class _CompanionNameScreenState extends State<CompanionNameScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<OnboardingController>().companionName;
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final name = _controller.text.trim();

    return OnboardingScaffold(
      step: 3,
      totalSteps: 7,
      title: 'What should my name be?',
      subtitle: "This is their name. You'll see it throughout VEYRA.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.words,
            style: AppTextStyles.hero,
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              hintText: 'Luna',
              hintStyle: AppTextStyles.hero.copyWith(color: AppColors.textMuted),
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: name.isNotEmpty
                ? Padding(
                    key: ValueKey(name),
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Nice to meet you, $name.', style: AppTextStyles.bodyEmphasis),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      footer: PrimaryButton(
        label: 'Continue',
        enabled: name.isNotEmpty,
        onPressed: () {
          context.read<OnboardingController>().setCompanionName(name);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UserNameScreen()),
          );
        },
      ),
    );
  }
}
