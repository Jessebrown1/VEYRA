import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../state/theme_controller.dart';
import '../../data/avatar_look_presets.dart';
import '../../state/app_state.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/premium_lock_sheet.dart';
import '../../widgets/primary_button.dart';
import 'wallpaper_screen.dart';

/// A gallery of ready-made avatar looks — users pick a complete look rather
/// than assembling one piece by piece. Each look is a curated combination of
/// the existing procedural SVG layers.
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  Map<String, String>? _assetPaths;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final appState = context.read<AppState>();
    final assets = await appState.avatarApi.listAssets();
    if (!mounted) return;

    final paths = {for (final a in assets) a.id: a.assetPath};

    final onboarding = context.read<OnboardingController>();
    if (onboarding.skinAssetId == null) {
      final firstFree = avatarLookPresets.firstWhere((p) => !p.isPremium);
      onboarding.applyAvatarLook(
        skinId: firstFree.skinId,
        hairId: firstFree.hairId,
        eyeId: firstFree.eyeId,
        outfitId: firstFree.outfitId,
        accessoryId: firstFree.accessoryId,
      );
    }

    setState(() => _assetPaths = paths);
  }

  bool _isSelected(OnboardingController onboarding, AvatarLookPreset preset) {
    return onboarding.skinAssetId == preset.skinId &&
        onboarding.hairAssetId == preset.hairId &&
        onboarding.eyeAssetId == preset.eyeId &&
        onboarding.outfitAssetId == preset.outfitId &&
        onboarding.accessoryAssetId == preset.accessoryId;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final onboarding = context.watch<OnboardingController>();
    final companionName = onboarding.companionName;
    final paths = _assetPaths;

    return OnboardingScaffold(
      step: 5,
      totalSteps: 8,
      title: 'How should $companionName look?',
      subtitle: 'Pick a look — you can change this any time.',
      child: paths == null
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.82,
              children: avatarLookPresets.map((preset) {
                final isSelected = _isSelected(onboarding, preset);
                return _LookCard(
                  preset: preset,
                  paths: paths,
                  isSelected: isSelected,
                  onTap: () {
                    if (preset.isPremium) {
                      showPremiumLockSheet(context, featureName: '${preset.name} look');
                    } else {
                      onboarding.applyAvatarLook(
                        skinId: preset.skinId,
                        hairId: preset.hairId,
                        eyeId: preset.eyeId,
                        outfitId: preset.outfitId,
                        accessoryId: preset.accessoryId,
                      );
                    }
                  },
                );
              }).toList(),
            ),
      footer: PrimaryButton(
        label: 'Continue',
        enabled: paths != null && onboarding.skinAssetId != null,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WallpaperScreen()),
        ),
      ),
    );
  }
}

class _LookCard extends StatelessWidget {
  final AvatarLookPreset preset;
  final Map<String, String> paths;
  final bool isSelected;
  final VoidCallback onTap;

  const _LookCard({
    required this.preset,
    required this.paths,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final layers = [
      paths[preset.skinId],
      paths[preset.outfitId],
      paths[preset.eyeId],
      paths[preset.hairId],
      if (preset.accessoryId != null) paths[preset.accessoryId],
    ].whereType<String>().toList();

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.dividerFaint,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.accentGlowSoft : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      color: AppColors.elevated,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [for (final path in layers) SvgPicture.asset(path, fit: BoxFit.contain)],
                      ),
                    ),
                  ),
                  if (preset.isPremium)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Icon(Icons.lock, size: 14, color: AppColors.textMuted),
                    ),
                  if (isSelected)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Icon(Icons.check_circle, color: AppColors.accent, size: 18),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(preset.name, style: AppTextStyles.bodyEmphasis),
          ],
        ),
      ),
    );
  }
}
