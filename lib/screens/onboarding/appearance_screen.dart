import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../models/avatar_catalog_item.dart';
import '../../state/app_state.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/premium_lock_sheet.dart';
import '../../widgets/primary_button.dart';
import 'wallpaper_screen.dart';

/// The real avatar builder — every tap here changes what actually renders in
/// the live preview and gets persisted to the companion's avatar_config once
/// the companion is created.
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  List<AvatarCatalogItem>? _assets;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final appState = context.read<AppState>();
    final assets = await appState.avatarApi.listAssets();
    if (!mounted) return;

    final onboarding = context.read<OnboardingController>();
    _ensureDefault(onboarding, assets, 'skin', onboarding.skinAssetId, (id) => onboarding.setAvatarAsset('skin', id));
    _ensureDefault(onboarding, assets, 'hair', onboarding.hairAssetId, (id) => onboarding.setAvatarAsset('hair', id));
    _ensureDefault(onboarding, assets, 'eyes', onboarding.eyeAssetId, (id) => onboarding.setAvatarAsset('eyes', id));
    _ensureDefault(
        onboarding, assets, 'outfit', onboarding.outfitAssetId, (id) => onboarding.setAvatarAsset('outfit', id));

    setState(() => _assets = assets);
  }

  void _ensureDefault(
    OnboardingController onboarding,
    List<AvatarCatalogItem> assets,
    String category,
    String? current,
    void Function(String) apply,
  ) {
    if (current != null) return;
    final free = assets.where((a) => a.category == category && !a.isPremium);
    if (free.isNotEmpty) apply(free.first.id);
  }

  List<AvatarCatalogItem> _forCategory(String category) =>
      _assets?.where((a) => a.category == category).toList() ?? [];

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingController>();
    final companionName = onboarding.companionName;
    final assets = _assets;

    return OnboardingScaffold(
      step: 5,
      totalSteps: 8,
      title: 'How should $companionName look?',
      child: assets == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _LivePreview(onboarding: onboarding, assets: assets)),
                  const SizedBox(height: AppSpacing.lg),
                  _CategorySection(
                    label: 'Skin',
                    options: _forCategory('skin'),
                    selectedId: onboarding.skinAssetId,
                    allowNone: false,
                    onSelect: (id) => onboarding.setAvatarAsset('skin', id),
                    swatchStyle: true,
                  ),
                  _CategorySection(
                    label: 'Hair',
                    options: _forCategory('hair'),
                    selectedId: onboarding.hairAssetId,
                    allowNone: false,
                    onSelect: (id) => onboarding.setAvatarAsset('hair', id),
                  ),
                  _CategorySection(
                    label: 'Eyes',
                    options: _forCategory('eyes'),
                    selectedId: onboarding.eyeAssetId,
                    allowNone: false,
                    onSelect: (id) => onboarding.setAvatarAsset('eyes', id),
                  ),
                  _CategorySection(
                    label: 'Outfit',
                    options: _forCategory('outfit'),
                    selectedId: onboarding.outfitAssetId,
                    allowNone: false,
                    onSelect: (id) => onboarding.setAvatarAsset('outfit', id),
                  ),
                  _CategorySection(
                    label: 'Accessory',
                    options: _forCategory('accessory'),
                    selectedId: onboarding.accessoryAssetId,
                    allowNone: true,
                    onSelect: (id) => onboarding.setAvatarAsset('accessory', id),
                  ),
                ],
              ),
            ),
      footer: PrimaryButton(
        label: 'Continue',
        enabled: assets != null,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WallpaperScreen()),
        ),
      ),
    );
  }
}

class _LivePreview extends StatelessWidget {
  final OnboardingController onboarding;
  final List<AvatarCatalogItem> assets;

  const _LivePreview({required this.onboarding, required this.assets});

  String? _pathFor(String? id) {
    if (id == null) return null;
    final matches = assets.where((a) => a.id == id);
    return matches.isEmpty ? null : matches.first.assetPath;
  }

  @override
  Widget build(BuildContext context) {
    final layers = [
      _pathFor(onboarding.skinAssetId),
      _pathFor(onboarding.outfitAssetId),
      _pathFor(onboarding.eyeAssetId),
      _pathFor(onboarding.hairAssetId),
      _pathFor(onboarding.accessoryAssetId),
    ].whereType<String>().toList();

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.glow(AppColors.accent, opacity: 0.28),
          ),
        ),
        Container(
          width: 208,
          height: 208,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.accentGradient,
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [for (final path in layers) SvgPicture.asset(path, fit: BoxFit.contain)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String label;
  final List<AvatarCatalogItem> options;
  final String? selectedId;
  final bool allowNone;
  final bool swatchStyle;
  final void Function(String? id) onSelect;

  const _CategorySection({
    required this.label,
    required this.options,
    required this.selectedId,
    required this.allowNone,
    required this.onSelect,
    this.swatchStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.microcopy),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: swatchStyle ? 48 : 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (allowNone)
                  _OptionCard(
                    isSelected: selectedId == null,
                    isPremium: false,
                    swatchStyle: swatchStyle,
                    child: const Icon(Icons.block, color: AppColors.textMuted, size: 20),
                    onTap: () => onSelect(null),
                  ),
                for (final option in options)
                  _OptionCard(
                    isSelected: selectedId == option.id,
                    isPremium: option.isPremium,
                    swatchStyle: swatchStyle,
                    child: swatchStyle
                        ? ClipOval(child: SvgPicture.asset(option.assetPath, fit: BoxFit.cover))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SvgPicture.asset(option.assetPath, fit: BoxFit.contain),
                          ),
                    onTap: () {
                      if (option.isPremium) {
                        showPremiumLockSheet(context, featureName: '${option.name} $label');
                      } else {
                        onSelect(option.id);
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final bool isSelected;
  final bool isPremium;
  final bool swatchStyle;
  final Widget child;
  final VoidCallback onTap;

  const _OptionCard({
    required this.isSelected,
    required this.isPremium,
    required this.swatchStyle,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = swatchStyle ? 40.0 : 84.0;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(swatchStyle ? size / 2 : 16),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: swatchStyle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: swatchStyle ? null : BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(padding: const EdgeInsets.all(6), child: child),
              if (isPremium)
                const Positioned(
                  right: 2,
                  top: 2,
                  child: Icon(Icons.lock, size: 11, color: AppColors.textMuted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
