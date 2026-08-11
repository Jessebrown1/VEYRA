import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../state/theme_controller.dart';
import '../../data/personality_catalog.dart';
import '../../data/relationship_catalog.dart';
import '../../data/term_of_address_catalog.dart';
import '../../models/avatar_catalog_item.dart';
import '../../models/wallpaper_catalog_item.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen> {
  List<AvatarCatalogItem>? _avatarAssets;
  List<WallpaperCatalogItem>? _wallpapers;
  bool _locationEnabled = false;
  bool _notificationsEnabled = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final appState = context.read<AppState>();
    try {
      final results = await Future.wait([
        appState.avatarApi.listAssets(),
        appState.wallpaperApi.list(),
        appState.settingsApi.getLocationSettings(),
        appState.settingsApi.getNotificationSettings(),
      ]);
      if (!mounted) return;
      setState(() {
        _avatarAssets = results[0] as List<AvatarCatalogItem>;
        _wallpapers = results[1] as List<WallpaperCatalogItem>;
        _locationEnabled = (results[2] as Map<String, dynamic>)['enabled'] as bool? ?? false;
        _notificationsEnabled = (results[3] as Map<String, dynamic>)['enabled'] as bool? ?? false;
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  String? _assetPathFor(String? id) {
    if (id == null || _avatarAssets == null) return null;
    for (final asset in _avatarAssets!) {
      if (asset.id == id) return asset.assetPath;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final companion = context.watch<AppState>().companion!;
    final personality = PersonalityCatalog.byId(companion.personalityId);
    final relationship = RelationshipCatalog.byId(companion.relationshipId);
    final term = TermOfAddressCatalog.forRelationship(companion.relationshipId)
        .firstWhere((t) => t.id == companion.preferredTermId, orElse: () => TermOfAddressCatalog.yourName);
    final wallpaperMatches = _wallpapers?.where((w) => w.id == companion.wallpaperId) ?? const [];
    final wallpaperName = wallpaperMatches.isEmpty ? null : wallpaperMatches.first.name;

    final avatarConfig = companion.avatarConfig;
    final layers = [
      avatarConfig.skinAssetId,
      avatarConfig.outfitAssetId,
      avatarConfig.eyeAssetId,
      avatarConfig.hairAssetId,
      avatarConfig.accessoryAssetId,
    ].map(_assetPathFor).whereType<String>().toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: !_loaded
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 260,
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      if (companion.wallpaperId != null)
                        SvgPicture.asset('assets/wallpapers/${companion.wallpaperId}', fit: BoxFit.cover)
                      else
                        Container(color: AppColors.surface),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, AppColors.background],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -44,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 116,
                            height: 116,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.accentGradient,
                              boxShadow: AppShadows.soft,
                            ),
                            child: ClipOval(
                              child: layers.isEmpty
                                  ? Container(
                                      color: AppColors.elevated,
                                      alignment: Alignment.center,
                                      child: Text(
                                        companion.name.isNotEmpty ? companion.name[0].toUpperCase() : '?',
                                        style: AppTextStyles.display,
                                      ),
                                    )
                                  : Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(color: AppColors.elevated),
                                        for (final path in layers) SvgPicture.asset(path, fit: BoxFit.cover),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl + AppSpacing.xs),
                Center(
                  child: Column(
                    children: [
                      Text(companion.name, style: AppTextStyles.headline),
                      const SizedBox(height: 2),
                      Text('${relationship.label} · ${personality.label}', style: AppTextStyles.body),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  child: Column(
                    children: [
                      _InfoTile(icon: Icons.favorite_outline, label: 'Relationship', value: relationship.label),
                      _InfoTile(icon: Icons.auto_awesome_outlined, label: 'Personality', value: personality.label),
                      _InfoTile(icon: Icons.chat_bubble_outline, label: 'Calls you', value: term.label),
                      _InfoTile(icon: Icons.image_outlined, label: 'Wallpaper', value: wallpaperName ?? 'Default'),
                      _InfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: _locationEnabled ? 'Enabled' : 'Not enabled',
                        valueColor: _locationEnabled ? AppColors.success : AppColors.textMuted,
                      ),
                      _InfoTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        value: _notificationsEnabled ? 'Enabled' : 'Not enabled',
                        valueColor: _notificationsEnabled ? AppColors.success : AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.dividerFaint),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.smd),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.bodyEmphasis.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}
