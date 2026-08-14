import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/theme_controller.dart';
import '../../models/avatar_config.dart';
import '../../services/api_client.dart';
import '../../state/app_state.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../home/home_shell.dart';

class CompanionCreationScreen extends StatefulWidget {
  const CompanionCreationScreen({super.key});

  @override
  State<CompanionCreationScreen> createState() => _CompanionCreationScreenState();
}

class _CompanionCreationScreenState extends State<CompanionCreationScreen>
    with SingleTickerProviderStateMixin {
  String? _error;

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _create());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _error = null);
    final onboarding = context.read<OnboardingController>();
    final appState = context.read<AppState>();

    try {
      final updatedUser = await appState.authApi.updateProfile(preferredName: onboarding.userPreferredName);

      var companion = await appState.companionApi.create(
        name: onboarding.companionName,
        relationshipId: onboarding.relationshipId!,
        personalityTraits: {onboarding.personalityId!: 1.0},
        preferredUserName: onboarding.userPreferredName,
        preferredTermId: onboarding.termOfAddressId!,
        wallpaperId: onboarding.wallpaperId,
      );

      final avatarSelections = AvatarConfig(
        skinAssetId: onboarding.skinAssetId,
        hairAssetId: onboarding.hairAssetId,
        eyeAssetId: onboarding.eyeAssetId,
        outfitAssetId: onboarding.outfitAssetId,
        accessoryAssetId: onboarding.accessoryAssetId,
      );
      if (avatarSelections.toJson().isNotEmpty) {
        final updatedAvatar = await appState.avatarApi.updateAvatar(companion.id, avatarSelections);
        companion = companion.copyWith(avatarConfig: updatedAvatar);
      }

      await appState.settingsApi.updateNotificationSettings(
        enabled: onboarding.notificationsEnabled,
        companionCheckins: onboarding.notificationsEnabled,
        sleepReminders: onboarding.notificationsEnabled,
      );
      await appState.settingsApi.updateLocationSettings(
        enabled: onboarding.locationEnabled,
        permissionType: onboarding.locationEnabled ? 'approximate' : 'none',
        lastArea: onboarding.locationArea,
      );

      // Brief, deliberate pause so "Creating Luna…" reads as a real moment
      // rather than flashing past.
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      await appState.completeOnboarding(updatedUser, companion);
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = ApiClient.toApiException(e).message);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final companionName = context.read<OnboardingController>().companionName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _error == null
                ? [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final t = _pulseController.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100 + t * 24,
                              height: 100 + t * 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.glow(AppColors.accent, opacity: 0.35 - t * 0.15),
                              ),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.accentGradient,
                              ),
                              child: Icon(Icons.auto_awesome, color: AppColors.background, size: 24),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Creating $companionName…', style: AppTextStyles.title),
                  ]
                : [
                    Text(
                      "Couldn't create $companionName",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(_error!, textAlign: TextAlign.center, style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(label: 'Try again', onPressed: _create),
                  ],
          ),
        ),
      ),
    );
  }
}
