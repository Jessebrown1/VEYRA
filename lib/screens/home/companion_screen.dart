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

class _CompanionScreenState extends State<CompanionScreen>
    with SingleTickerProviderStateMixin {
  List<AvatarCatalogItem>? _avatarAssets;
  List<WallpaperCatalogItem>? _wallpapers;

  bool _locationEnabled = false;
  bool _notificationsEnabled = false;
  bool _loaded = false;

  late final AnimationController _animationController;

  late final Animation<double> _headerAnimation;
  late final Animation<double> _avatarAnimation;
  late final Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.55,
        curve: Curves.easeOutCubic,
      ),
    );

    _avatarAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.15,
        0.7,
        curve: Curves.easeOutBack,
      ),
    );

    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.35,
        1.0,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

        _locationEnabled =
            (results[2] as Map<String, dynamic>)['enabled'] as bool? ?? false;

        _notificationsEnabled =
            (results[3] as Map<String, dynamic>)['enabled'] as bool? ?? false;

        _loaded = true;
      });

      _animationController.forward();
    } catch (_) {
      if (!mounted) return;

      setState(() => _loaded = true);
      _animationController.forward();
    }
  }

  String? _assetPathFor(String? id) {
    if (id == null || _avatarAssets == null) return null;

    for (final asset in _avatarAssets!) {
      if (asset.id == id) {
        return asset.assetPath;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final companion = context.watch<AppState>().companion!;

    final personality =
        PersonalityCatalog.byId(companion.personalityId);

    final relationship =
        RelationshipCatalog.byId(companion.relationshipId);

    final term = TermOfAddressCatalog
        .forRelationship(companion.relationshipId)
        .firstWhere(
          (t) => t.id == companion.preferredTermId,
          orElse: () => TermOfAddressCatalog.yourName,
        );

    final wallpaperMatches =
        _wallpapers?.where((w) => w.id == companion.wallpaperId) ?? const [];

    final wallpaperName =
        wallpaperMatches.isEmpty ? null : wallpaperMatches.first.name;

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: _GlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: !_loaded
          ? _LoadingState()
          : Stack(
              children: [
                ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHero(
                      companion: companion,
                      layers: layers,
                    ),
                    _buildProfileHeader(
                      companion: companion,
                      relationship: relationship,
                      personality: personality,
                    ),
                    _buildDetails(
                      relationship: relationship,
                      personality: personality,
                      term: term,
                      wallpaperName: wallpaperName,
                    ),
                    _buildStatusSection(),
                    const SizedBox(height: 36),
                  ],
                ),

                // Subtle top fade for the transparent app bar.
                IgnorePointer(
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHero({
    required dynamic companion,
    required List<String> layers,
  }) {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _headerAnimation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              18 * (1 - _headerAnimation.value),
            ),
            child: child,
          ),
        );
      },
      child: SizedBox(
        height: 390,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Hero(
                tag: 'companion-wallpaper',
                child: companion.wallpaperId != null
                    ? SvgPicture.asset(
                        'assets/wallpapers/${companion.wallpaperId}',
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGradient,
                        ),
                      ),
              ),
            ),

            // Dark cinematic overlay.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [
                      0.0,
                      0.35,
                      0.72,
                      1.0,
                    ],
                    colors: [
                      Colors.black.withValues(alpha: 0.20),
                      Colors.black.withValues(alpha: 0.08),
                      AppColors.background.withValues(alpha: 0.55),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),

            // Accent atmosphere.
            Positioned(
              top: 90,
              right: -80,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.glow(
                    AppColors.accent,
                    opacity: 0.13,
                  ),
                ),
              ),
            ),

            // Avatar.
            Positioned(
              bottom: -4,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _avatarAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.82 + (_avatarAnimation.value * 0.18),
                    child: Opacity(
                      opacity: _avatarAnimation.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow.
                      Container(
                        width: 154,
                        height: 154,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.glow(
                            AppColors.accent,
                            opacity: 0.20,
                          ),
                        ),
                      ),

                      // Avatar border.
                      Container(
                        width: 136,
                        height: 136,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.accentGradient,
                          boxShadow: [
                            ...AppShadows.soft,
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.18),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: layers.isEmpty
                              ? Container(
                                  color: AppColors.elevated,
                                  alignment: Alignment.center,
                                  child: Text(
                                    companion.name.isNotEmpty
                                        ? companion.name[0].toUpperCase()
                                        : '?',
                                    style: AppTextStyles.display,
                                  ),
                                )
                              : Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      color: AppColors.elevated,
                                    ),
                                    for (final path in layers)
                                      SvgPicture.asset(
                                        path,
                                        fit: BoxFit.cover,
                                      ),
                                  ],
                                ),
                        ),
                      ),

                      // Online indicator.
                      Positioned(
                        right: 11,
                        bottom: 12,
                        child: Container(
                          width: 23,
                          height: 23,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.background,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.success.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required dynamic companion,
    required dynamic relationship,
    required dynamic personality,
  }) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _contentAnimation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              20 * (1 - _contentAnimation.value),
            ),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          18,
          AppSpacing.screenPadding,
          0,
        ),
        child: Column(
          children: [
            Text(
              companion.name,
              textAlign: TextAlign.center,
              style: AppTextStyles.headline.copyWith(
                fontSize: 30,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ProfilePill(
                  icon: Icons.favorite_rounded,
                  label: relationship.label,
                ),
                const SizedBox(width: 8),
                _ProfilePill(
                  icon: Icons.auto_awesome_rounded,
                  label: personality.label,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Your companion, your way.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails({
    required dynamic relationship,
    required dynamic personality,
    required dynamic term,
    required String? wallpaperName,
  }) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _contentAnimation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              25 * (1 - _contentAnimation.value),
            ),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          26,
          AppSpacing.screenPadding,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: 'About them',
              subtitle: 'The little details that make them yours',
            ),
            const SizedBox(height: 13),
            _InfoTile(
              icon: Icons.favorite_outline_rounded,
              label: 'Relationship',
              value: relationship.label,
            ),
            _InfoTile(
              icon: Icons.auto_awesome_outlined,
              label: 'Personality',
              value: personality.label,
            ),
            _InfoTile(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Calls you',
              value: term.label,
            ),
            _InfoTile(
              icon: Icons.wallpaper_outlined,
              label: 'World',
              value: wallpaperName ?? 'Default',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _contentAnimation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              30 * (1 - _contentAnimation.value),
            ),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          18,
          AppSpacing.screenPadding,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              title: 'Connection',
              subtitle: 'How VEYRA stays connected with you',
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    enabled: _locationEnabled,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusCard(
                    icon: Icons.notifications_none_rounded,
                    title: 'Alerts',
                    enabled: _notificationsEnabled,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfilePill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: AppColors.dividerFaint,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: AppColors.accent,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.microcopy.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.title.copyWith(
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: AppColors.dividerFaint,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyEmphasis.copyWith(
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool enabled;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final statusColor =
        enabled ? AppColors.success : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: enabled
              ? AppColors.success.withValues(alpha: 0.22)
              : AppColors.dividerFaint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: statusColor,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                  boxShadow: enabled
                      ? [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.45),
                            blurRadius: 7,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: AppTextStyles.bodyEmphasis,
          ),
          const SizedBox(height: 3),
          Text(
            enabled ? 'Enabled' : 'Not enabled',
            style: AppTextStyles.caption.copyWith(
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.62),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 17,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: AppShadows.accentGlowSoft,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Preparing their world…',
            style: AppTextStyles.bodyEmphasis,
          ),
          const SizedBox(height: 6),
          Text(
            'Just a moment',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 90,
            child: LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: AppColors.dividerFaint,
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}