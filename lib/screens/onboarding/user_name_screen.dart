import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/avatar_look_presets.dart';
import '../../state/theme_controller.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';
import 'wallpaper_screen.dart';

class UserNameScreen extends StatefulWidget {
  const UserNameScreen({super.key});

  @override
  State<UserNameScreen> createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<OnboardingController>().userPreferredName;
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
    final companionName = context.watch<OnboardingController>().companionName;
    final name = _controller.text.trim();

    return OnboardingScaffold(
      step: 4,
      totalSteps: 7,
      title: 'What should $companionName call you?',
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
              hintText: 'Your name',
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
        ],
      ),
      footer: PrimaryButton(
        label: 'Continue',
        enabled: name.isNotEmpty,
        onPressed: () {
          final onboarding = context.read<OnboardingController>();
          onboarding.setUserPreferredName(name);
          onboarding.setTermOfAddress('first_name');
          if (onboarding.skinAssetId == null) {
            final defaultLook = avatarLookPresets.firstWhere((p) => !p.isPremium);
            onboarding.applyAvatarLook(
              skinId: defaultLook.skinId,
              hairId: defaultLook.hairId,
              eyeId: defaultLook.eyeId,
              outfitId: defaultLook.outfitId,
              accessoryId: defaultLook.accessoryId,
            );
          }
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const WallpaperScreen()),
          );
        },
      ),
    );
  }
}
