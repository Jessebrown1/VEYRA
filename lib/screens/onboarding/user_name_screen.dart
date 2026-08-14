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

class _UserNameScreenState extends State<UserNameScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final AnimationController _animationController;

  late final Animation<double> _entrance;
  late final Animation<double> _avatarScale;
  late final Animation<double> _glow;

  bool _focused = false;

  @override
  void initState() {
    super.initState();

    final onboarding = context.read<OnboardingController>();

    _controller.text = onboarding.userPreferredName;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _entrance = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _avatarScale = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.0,
          0.7,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _glow = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.15,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    _focusNode.addListener(_handleFocus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _handleFocus() {
    if (!mounted) return;

    setState(() {
      _focused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final cleaned = name.trim();

    if (cleaned.isEmpty) {
      return '?';
    }

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  void _continue() {
    final name = _controller.text.trim();

    if (name.isEmpty) return;

    final onboarding = context.read<OnboardingController>();

    onboarding.setUserPreferredName(name);
    onboarding.setTermOfAddress('first_name');

    if (onboarding.skinAssetId == null) {
      final defaultLook = avatarLookPresets.firstWhere(
        (p) => !p.isPremium,
      );

      onboarding.applyAvatarLook(
        skinId: defaultLook.skinId,
        hairId: defaultLook.hairId,
        eyeId: defaultLook.eyeId,
        outfitId: defaultLook.outfitId,
        accessoryId: defaultLook.accessoryId,
      );
    }

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const WallpaperScreen();
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
                begin: const Offset(0.04, 0),
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

    final onboarding = context.watch<OnboardingController>();

    final companionName = onboarding.companionName.trim();

    final name = _controller.text.trim();

    final initials = _getInitials(companionName);

    return OnboardingScaffold(
      step: 4,
      totalSteps: 7,

      title: companionName.isEmpty
          ? 'What should they call you?'
          : 'What should $companionName call you?',

      subtitle:
          'Choose the name you want your companion to use when talking to you.',

      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _entrance.value,
            child: Transform.translate(
              offset: Offset(
                0,
                16 * (1 - _entrance.value),
              ),
              child: child,
            ),
          );
        },

        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 24,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════
              // COMPANION AVATAR
              // ═══════════════════════════════════════

              Center(
                child: Transform.scale(
                  scale: _avatarScale.value,
                  child: _CompanionGreeting(
                    initials: initials,
                    glow: _glow.value,
                    hasName: name.isNotEmpty,
                    focused: _focused,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ═══════════════════════════════════════
              // SECTION LABEL
              // ═══════════════════════════════════════

              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.45),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'YOUR NAME',
                    style: AppTextStyles.bodyEmphasis.copyWith(
                      fontSize: 10,
                      letterSpacing: 1.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ═══════════════════════════════════════
              // NAME INPUT
              // ═══════════════════════════════════════

              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,

                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),

                decoration: BoxDecoration(
                  color: _focused
                      ? AppColors.accent.withOpacity(0.035)
                      : AppColors.textPrimary.withOpacity(0.018),

                  borderRadius: BorderRadius.circular(16),

                  // IMPORTANT:
                  // Keep the border width constant so the
                  // textbox does not appear to "double"
                  // when focused.
                  border: Border.all(
                    color: _focused
                        ? AppColors.accent.withOpacity(0.58)
                        : AppColors.divider,
                    width: 1,
                  ),

                  boxShadow: _focused
                      ? [
                          BoxShadow(
                            color:
                                AppColors.accent.withOpacity(0.08),
                            blurRadius: 18,
                            spreadRadius: -5,
                          ),
                        ]
                      : null,
                ),

                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,

                  textCapitalization: TextCapitalization.words,

                  textInputAction: TextInputAction.done,

                  style: AppTextStyles.bodyEmphasis.copyWith(
                    fontSize: 22,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),

                  cursorColor: AppColors.accent,

                  decoration: InputDecoration(
                    hintText: 'Your name',

                    hintStyle: AppTextStyles.bodyEmphasis.copyWith(
                      fontSize: 22,
                      height: 1.2,
                      color: AppColors.textMuted,
                    ),

                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,

                    isDense: true,

                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),

                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),

                    suffixIcon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (
                        child,
                        animation,
                      ) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: name.isNotEmpty
                          ? Icon(
                              Icons.check_circle_rounded,
                              key: const ValueKey('check'),
                              color: AppColors.accent,
                              size: 20,
                            )
                          : const SizedBox(
                              key: ValueKey('empty'),
                            ),
                    ),
                  ),

                  onChanged: (_) {
                    setState(() {});
                  },

                  onSubmitted: (_) {
                    if (name.isNotEmpty) {
                      _continue();
                    }
                  },
                ),
              ),

              // ═══════════════════════════════════════
              // LIVE PREVIEW
              // ═══════════════════════════════════════

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),

                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,

                transitionBuilder: (
                  child,
                  animation,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      child: child,
                    ),
                  );
                },

                child: name.isNotEmpty
                    ? Padding(
                        key: ValueKey(name),
                        padding: const EdgeInsets.only(
                          top: 12,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.accent.withOpacity(0.045),
                            borderRadius:
                                BorderRadius.circular(13),
                            border: Border.all(
                              color:
                                  AppColors.accent.withOpacity(0.10),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Companion initials instead
                              // of AI icon.
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient:
                                      AppColors.accentGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent
                                          .withOpacity(0.18),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: AppTextStyles
                                        .bodyEmphasis
                                        .copyWith(
                                      fontSize: 10,
                                      color:
                                          AppColors.background,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  '$companionName will use "$name" when talking to you.',
                                  style: AppTextStyles
                                      .bodyEmphasis
                                      .copyWith(
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('empty'),
                      ),
              ),

              const SizedBox(height: 10),

              // ═══════════════════════════════════════
              // HELPER
              // ═══════════════════════════════════════

              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: name.isEmpty ? 1 : 0.6,
                child: Text(
                  'This is how your companion will address you.',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      // ═══════════════════════════════════════════
      // CONTINUE
      // ═══════════════════════════════════════════

      footer: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: name.isEmpty ? 0.55 : 1.0,
        child: PrimaryButton(
          label: 'Continue',
          enabled: name.isNotEmpty,
          onPressed: name.isNotEmpty ? _continue : null,
        ),
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════
// COMPANION GREETING
// ═══════════════════════════════════════════════════════

class _CompanionGreeting extends StatelessWidget {
  final String initials;
  final double glow;
  final bool hasName;
  final bool focused;

  const _CompanionGreeting({
    required this.initials,
    required this.glow,
    required this.hasName,
    required this.focused,
  });

  @override
  Widget build(BuildContext context) {
    final intensity = focused ? 1.0 : 0.72;

    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ═════════════════════════════════════
          // ATMOSPHERIC GLOW
          // ═════════════════════════════════════

          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withOpacity(
                    0.16 * glow * intensity,
                  ),
                  AppColors.accent.withOpacity(
                    0.04 * glow * intensity,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ═════════════════════════════════════
          // OUTER RING
          // ═════════════════════════════════════

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: focused ? 100 : 94,
            height: focused ? 100 : 94,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withOpacity(
                  focused ? 0.34 : 0.16,
                ),
                width: 1,
              ),
            ),
          ),

          // ═════════════════════════════════════
          // AVATAR
          // ═════════════════════════════════════

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: focused ? 70 : 64,
            height: focused ? 70 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withOpacity(
                    hasName ? 0.38 : 0.25,
                  ),
                  AppColors.accent.withOpacity(0.10),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(
                    focused ? 0.22 : 0.10,
                  ),
                  blurRadius: focused ? 26 : 18,
                  spreadRadius: focused ? 2 : 0,
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (
                  child,
                  animation,
                ) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  initials,
                  key: ValueKey(initials),
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    fontSize: initials.length > 1 ? 17 : 21,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          // ═════════════════════════════════════
          // ORBIT DOT
          // ═════════════════════════════════════

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: focused ? 14 : 18,
            right: focused ? 22 : 25,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.55),
                    blurRadius: 9,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}