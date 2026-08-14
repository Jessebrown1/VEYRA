import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../state/theme_controller.dart';
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
  State<WallpaperScreen> createState() =>
      _WallpaperScreenState();
}

class _WallpaperScreenState
    extends State<WallpaperScreen>
    with TickerProviderStateMixin {
  List<WallpaperCatalogItem>? _wallpapers;

  late final AnimationController _entranceController;
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _load(),
    );
  }

  Future<void> _load() async {
    final appState = context.read<AppState>();

    final wallpapers =
        await appState.wallpaperApi.list();

    if (!mounted) return;

    setState(() {
      _wallpapers = wallpapers;
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  void _selectWallpaper(
    WallpaperCatalogItem option,
  ) {
    if (option.isPremium) {
      showPremiumLockSheet(
        context,
        featureName:
            '${option.name} wallpaper',
      );
      return;
    }

    context
        .read<OnboardingController>()
        .setWallpaper(option.id);
  }

  void _continue() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 550),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const LocationPermissionScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final controller =
        context.watch<OnboardingController>();

    final wallpapers = _wallpapers;

    return OnboardingScaffold(
      step: 5,
      totalSteps: 7,
      title: 'Choose their world.',
      subtitle:
          'Give your companion a place that feels like them.',

      child: wallpapers == null
          ? _WallpaperLoading()
          : AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return CustomScrollView(
                  physics:
                      const BouncingScrollPhysics(),
                  slivers: [
                    // ═══════════════════════════════
                    // SELECTED PREVIEW
                    // ═══════════════════════════════

                    SliverToBoxAdapter(
                      child: _SelectedPreview(
                        wallpapers: wallpapers,
                        selectedId:
                            controller.wallpaperId,
                        ambient:
                            _ambientController,
                        onTap: () {},
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 22),
                    ),

                    // ═══════════════════════════════
                    // SECTION HEADER
                    // ═══════════════════════════════

                    SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration:
                                BoxDecoration(
                              shape:
                                  BoxShape.circle,
                              color:
                                  AppColors.accent,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors
                                      .accent
                                      .withOpacity(
                                    0.5,
                                  ),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 9),
                          Text(
                            'WORLDS',
                            style: AppTextStyles
                                .bodyEmphasis
                                .copyWith(
                              fontSize: 10,
                              letterSpacing: 1.8,
                              color: AppColors
                                  .textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${wallpapers.length} available',
                            style: AppTextStyles
                                .body
                                .copyWith(
                              fontSize: 10,
                              color: AppColors
                                  .textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 12),
                    ),

                    // ═══════════════════════════════
                    // WALLPAPER GRID
                    // ═══════════════════════════════

                    SliverGrid(
                      delegate:
                          SliverChildBuilderDelegate(
                        (context, index) {
                          final option =
                              wallpapers[index];

                          final start =
                              (index * 0.08)
                                  .clamp(
                            0.0,
                            0.55,
                          );

                          final animation =
                              CurvedAnimation(
                            parent:
                                _entranceController,
                            curve: Interval(
                              start,
                              (start + 0.45)
                                  .clamp(
                                0.0,
                                1.0,
                              ),
                              curve: Curves
                                  .easeOutCubic,
                            ),
                          );

                          return AnimatedBuilder(
                            animation: animation,
                            builder:
                                (context, child) {
                              return Opacity(
                                opacity:
                                    animation.value,
                                child:
                                    Transform.translate(
                                  offset: Offset(
                                    0,
                                    25 *
                                        (1 -
                                            animation
                                                .value),
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            child:
                                _WallpaperCard(
                              option: option,
                              selected:
                                  controller
                                          .wallpaperId ==
                                      option.id,
                              onTap: () =>
                                  _selectWallpaper(
                                option,
                              ),
                            ),
                          );
                        },
                        childCount:
                            wallpapers.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing:
                            AppSpacing.sm,
                        crossAxisSpacing:
                            AppSpacing.sm,
                        childAspectRatio: 0.72,
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),

                    // ═══════════════════════════════
                    // FOOTER MESSAGE
                    // ═══════════════════════════════

                    SliverToBoxAdapter(
                      child: Center(
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons
                                  .auto_awesome_rounded,
                              size: 13,
                              color: AppColors
                                  .textSecondary
                                  .withOpacity(
                                0.6,
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              'You can change their world later.',
                              style: AppTextStyles
                                  .body
                                  .copyWith(
                                fontSize: 11,
                                color: AppColors
                                    .textSecondary
                                    .withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 8),
                    ),
                  ],
                );
              },
            ),

      footer: PrimaryButton(
        label: 'Continue',
        enabled: wallpapers != null,
        onPressed:
            wallpapers != null ? _continue : null,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SELECTED WALLPAPER PREVIEW
// ═══════════════════════════════════════════════════════

class _SelectedPreview extends StatelessWidget {
  final List<WallpaperCatalogItem> wallpapers;
  final String? selectedId;
  final Animation<double> ambient;
  final VoidCallback onTap;

  const _SelectedPreview({
    required this.wallpapers,
    required this.selectedId,
    required this.ambient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedId == null
        ? null
        : wallpapers
            .where(
              (item) =>
                  item.id == selectedId,
            )
            .firstOrNull;

    if (selected == null) {
      return _EmptyPreview();
    }

    return AnimatedSwitcher(
      duration:
          const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder:
          (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.97,
              end: 1.0,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _PreviewCard(
        key: ValueKey(selected.id),
        option: selected,
        ambient: ambient,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// EMPTY PREVIEW
// ═══════════════════════════════════════════════════════

class _EmptyPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(22),
        color: AppColors.textPrimary
            .withOpacity(0.018),
        border: Border.all(
          color: AppColors.divider
              .withOpacity(0.7),
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons
                .wallpaper_outlined,
            size: 28,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 9),
          Text(
            'Choose a world below',
            style:
                AppTextStyles.bodyEmphasis
                    .copyWith(
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Your companion will live here.',
            style:
                AppTextStyles.body.copyWith(
              fontSize: 11,
              color:
                  AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// PREVIEW CARD
// ═══════════════════════════════════════════════════════

class _PreviewCard extends StatelessWidget {
  final WallpaperCatalogItem option;
  final Animation<double> ambient;

  const _PreviewCard({
    super.key,
    required this.option,
    required this.ambient,
  });

  @override
  Widget build(BuildContext context) {
    final movement =
        math.sin(
              ambient.value *
                  math.pi *
                  2,
            ) *
            4;

    return Container(
      height: 175,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              AppColors.accent.withOpacity(
            0.25,
          ),
        ),
        boxShadow:
            AppShadows.accentGlowSoft,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: Offset(
              movement,
              0,
            ),
            child: Transform.scale(
              scale: 1.05,
              child: SvgPicture.asset(
                option.assetPath,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Cinematic overlay.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin:
                    Alignment.topCenter,
                end:
                    Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(
                    0.02,
                  ),
                  Colors.black.withOpacity(
                    0.12,
                  ),
                  Colors.black.withOpacity(
                    0.78,
                  ),
                ],
                stops: const [
                  0.0,
                  0.45,
                  1.0,
                ],
              ),
            ),
          ),

          // Top selected indicator.
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black
                    .withOpacity(0.28),
                border: Border.all(
                  color: AppColors.accent
                      .withOpacity(0.35),
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                color:
                    AppColors.accent,
                size: 17,
              ),
            ),
          ),

          // Bottom information.
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT WORLD',
                        style: AppTextStyles
                            .bodyEmphasis
                            .copyWith(
                          fontSize: 8,
                          letterSpacing: 1.7,
                          color: Colors.white
                              .withOpacity(
                            0.65,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        option.name,
                        style: AppTextStyles
                            .bodyEmphasis
                            .copyWith(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons
                      .auto_awesome_rounded,
                  color: Colors.white
                      .withOpacity(0.75),
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// WALLPAPER CARD
// ═══════════════════════════════════════════════════════

class _WallpaperCard extends StatefulWidget {
  final WallpaperCatalogItem option;
  final bool selected;
  final VoidCallback onTap;

  const _WallpaperCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_WallpaperCard> createState() =>
      _WallpaperCardState();
}

class _WallpaperCardState
    extends State<_WallpaperCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration:
            const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: widget.selected
                  ? AppColors.accent
                  : AppColors.dividerFaint,
              width:
                  widget.selected ? 2 : 1,
            ),
            boxShadow: widget.selected
                ? AppShadows.accentGlowSoft
                : [],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Wallpaper.
              SvgPicture.asset(
                widget.option.assetPath,
                fit: BoxFit.cover,
              ),

              // Cinematic gradient.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(
                        0.02,
                      ),
                      Colors.black.withOpacity(
                        0.72,
                      ),
                    ],
                    stops: const [
                      0.15,
                      0.48,
                      1.0,
                    ],
                  ),
                ),
              ),

              // Premium dim layer.
              if (widget.option.isPremium)
                Container(
                  color: Colors.black
                      .withOpacity(0.12),
                ),

              // Selected glow.
              if (widget.selected)
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    gradient:
                        LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        AppColors.accent
                            .withOpacity(
                          0.08,
                        ),
                        Colors.transparent,
                        AppColors.accent
                            .withOpacity(
                          0.05,
                        ),
                      ],
                    ),
                  ),
                ),

              // ═══════════════════════════════
              // PREMIUM BADGE
              // ═══════════════════════════════

              if (widget.option.isPremium)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 5,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.black
                          .withOpacity(
                        0.38,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                      border: Border.all(
                        color: Colors.white
                            .withOpacity(
                          0.12,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .lock_outline_rounded,
                          size: 10,
                          color:
                              Colors.white
                                  .withOpacity(
                            0.8,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          'PREMIUM',
                          style: AppTextStyles
                              .bodyEmphasis
                              .copyWith(
                            fontSize: 7,
                            letterSpacing:
                                1.0,
                            color:
                                Colors.white
                                    .withOpacity(
                              0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ═══════════════════════════════
              // SELECTED CHECK
              // ═══════════════════════════════

              Positioned(
                top: 10,
                right: 10,
                child: AnimatedScale(
                  scale:
                      widget.selected
                          ? 1
                          : 0.6,
                  duration:
                      const Duration(
                    milliseconds: 250,
                  ),
                  curve:
                      Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity:
                        widget.selected
                            ? 1
                            : 0,
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: AppColors
                            .accent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors
                                .accent
                                .withOpacity(
                              0.35,
                            ),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 17,
                        color:
                            Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // ═══════════════════════════════
              // BOTTOM INFO
              // ═══════════════════════════════

              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.option.name,
                        style: AppTextStyles
                            .bodyEmphasis
                            .copyWith(
                          fontSize: 13,
                          color:
                              Colors.white,
                        ),
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.option.isPremium)
                      const SizedBox(width: 6),
                    if (widget.option.isPremium)
                      Icon(
                        Icons
                            .lock_outline_rounded,
                        size: 13,
                        color: Colors.white
                            .withOpacity(
                          0.7,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// LOADING STATE
// ═══════════════════════════════════════════════════════

class _WallpaperLoading
    extends StatefulWidget {
  @override
  State<_WallpaperLoading> createState() =>
      _WallpaperLoadingState();
}

class _WallpaperLoadingState
    extends State<_WallpaperLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              height: 175,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment(
                    -1 +
                        (_controller.value *
                            2),
                    -0.2,
                  ),
                  end: Alignment(
                    1 +
                        (_controller.value *
                            2),
                    0.2,
                  ),
                  colors: [
                    AppColors.textPrimary
                        .withOpacity(0.025),
                    AppColors.textPrimary
                        .withOpacity(0.07),
                    AppColors.textPrimary
                        .withOpacity(0.025),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: _SkeletonCard(
                    animation:
                        _controller.value,
                  ),
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Expanded(
                  child: _SkeletonCard(
                    animation:
                        _controller.value,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _SkeletonCard(
                    animation:
                        _controller.value,
                  ),
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Expanded(
                  child: _SkeletonCard(
                    animation:
                        _controller.value,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SkeletonCard
    extends StatelessWidget {
  final double animation;

  const _SkeletonCard({
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment(
            -1 + animation * 2,
            0,
          ),
          end: Alignment(
            animation * 2,
            0,
          ),
          colors: [
            AppColors.textPrimary
                .withOpacity(0.02),
            AppColors.textPrimary
                .withOpacity(0.065),
            AppColors.textPrimary
                .withOpacity(0.02),
          ],
        ),
      ),
    );
  }
}