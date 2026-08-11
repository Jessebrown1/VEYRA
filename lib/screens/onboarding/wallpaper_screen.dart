import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../models/wallpaper_catalog_item.dart';
import '../../state/app_state.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/premium_lock_sheet.dart';
import '../../widgets/primary_button.dart';
import 'location_permission_screen.dart';

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({super.key});

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  List<WallpaperCatalogItem>? _wallpapers;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final appState = context.read<AppState>();
    final wallpapers = await appState.wallpaperApi.list();
    if (!mounted) return;
    setState(() => _wallpapers = wallpapers);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();
    final wallpapers = _wallpapers;

    return OnboardingScaffold(
      step: 6,
      totalSteps: 8,
      title: 'Choose their world.',
      subtitle: 'You can change this any time.',
      child: wallpapers == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.8,
              children: wallpapers.map((option) {
                final isSelected = controller.wallpaperId == option.id;
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    if (option.isPremium) {
                      showPremiumLockSheet(context, featureName: '${option.name} wallpaper');
                    } else {
                      context.read<OnboardingController>().setWallpaper(option.id);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.dividerFaint,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? AppShadows.accentGlowSoft : null,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SvgPicture.asset(option.assetPath, fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Positioned(
                            right: AppSpacing.sm,
                            top: AppSpacing.sm,
                            child: Icon(Icons.check_circle, color: AppColors.accent, size: 20),
                          ),
                        Positioned(
                          left: AppSpacing.sm,
                          right: AppSpacing.sm,
                          bottom: AppSpacing.sm,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option.name,
                                  style: AppTextStyles.bodyEmphasis,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (option.isPremium)
                                const Icon(Icons.lock, size: 12, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
      footer: PrimaryButton(
        label: 'Continue',
        enabled: wallpapers != null,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
        ),
      ),
    );
  }
}
