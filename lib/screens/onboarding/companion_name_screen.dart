import 'dart:math' as math;

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
  State<CompanionNameScreen> createState() =>
      _CompanionNameScreenState();
}

class _CompanionNameScreenState
    extends State<CompanionNameScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller =
      TextEditingController();

  final FocusNode _focusNode = FocusNode();

  late final AnimationController _animationController;

  late final Animation<double> _entrance;
  late final Animation<double> _orbScale;
  late final Animation<double> _orbGlow;

  bool _focused = false;

  @override
  void initState() {
    super.initState();

    _controller.text =
        context.read<OnboardingController>().companionName;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _entrance = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _orbScale = Tween<double>(
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

    _orbGlow = CurvedAnimation(
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

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final name = _controller.text.trim();

    return OnboardingScaffold(
      step: 3,
      totalSteps: 7,

      title: 'What should my name be?',

      subtitle:
          "Give your companion a name. You'll see it throughout VEYRA.",

      // ================================================================
      // SCROLLABLE CONTENT
      // ================================================================

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

        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,

              padding: const EdgeInsets.only(
                bottom: 20,
              ),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(
                    0,
                    constraints.maxHeight - 20,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const SizedBox(height: 8),

                    // ==================================================
                    // COMPANION INITIALS
                    // ==================================================

                    Center(
                      child: AnimatedBuilder(
                        animation:
                            _animationController,
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _orbScale.value,
                            child: _CompanionOrb(
                              glow: _orbGlow.value,
                              focused: _focused,
                              hasName:
                                  name.isNotEmpty,
                              name: name,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // SECTION LABEL
                    // ==================================================

                    Row(
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
                                  0.45,
                                ),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 9),

                        Text(
                          'COMPANION NAME',
                          style: AppTextStyles
                              .bodyEmphasis
                              .copyWith(
                            fontSize: 10,
                            letterSpacing: 1.7,
                            color: AppColors
                                .textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ==================================================
                    // NAME FIELD
                    // ==================================================

                    _NameField(
                      controller: _controller,
                      focusNode: _focusNode,
                      focused: _focused,
                      hasName: name.isNotEmpty,
                      onChanged: () {
                        setState(() {});
                      },
                      onSubmitted: () {
                        if (name.isNotEmpty) {
                          _continue();
                        }
                      },
                    ),

                    // ==================================================
                    // NAME RESPONSE
                    // ==================================================

                    AnimatedSwitcher(
                      duration:
                          const Duration(
                        milliseconds: 300,
                      ),

                      switchInCurve:
                          Curves.easeOutCubic,

                      switchOutCurve:
                          Curves.easeInCubic,

                      transitionBuilder:
                          (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child:
                              SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1,
                            child: child,
                          ),
                        );
                      },

                      child: name.isNotEmpty
                          ? Padding(
                              key: ValueKey(name),
                              padding:
                                  const EdgeInsets
                                      .only(
                                top: 12,
                              ),
                              child:
                                  _NameResponse(
                                name: name,
                              ),
                            )
                          : const SizedBox(
                              key: ValueKey(
                                'empty',
                              ),
                            ),
                    ),

                    const SizedBox(height: 10),

                    // ==================================================
                    // HELPER TEXT
                    // ==================================================

                    AnimatedOpacity(
                      duration:
                          const Duration(
                        milliseconds: 250,
                      ),

                      opacity:
                          name.isEmpty ? 1 : 0.55,

                      child: Text(
                        'Choose something that feels natural to you.',
                        style: AppTextStyles.body
                            .copyWith(
                          fontSize: 11,
                          color: AppColors
                              .textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // CHARACTER COUNT
                    // ==================================================

                    Align(
                      alignment:
                          Alignment.centerRight,
                      child: AnimatedOpacity(
                        duration:
                            const Duration(
                          milliseconds: 200,
                        ),

                        opacity:
                            name.isEmpty ? 0.30 : 0.55,

                        child: Text(
                          '${name.length}/24',
                          style: AppTextStyles
                              .microcopy
                              .copyWith(
                            color: AppColors
                                .textMuted,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // ================================================================
      // CONTINUE
      // ================================================================

      footer: AnimatedOpacity(
        duration:
            const Duration(milliseconds: 250),

        opacity:
            name.isEmpty ? 0.5 : 1.0,

        child: PrimaryButton(
          label: 'Continue',

          enabled: name.isNotEmpty,

          onPressed:
              name.isNotEmpty ? _continue : null,
        ),
      ),
    );
  }

  void _continue() {
    final name = _controller.text.trim();

    if (name.isEmpty) return;

    context
        .read<OnboardingController>()
        .setCompanionName(name);

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 450),

        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const UserNameScreen();
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
                begin: const Offset(
                  0.04,
                  0,
                ),
                end: Offset.zero,
              ).animate(curved),

              child: child,
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// NAME FIELD
// ═══════════════════════════════════════════════════════════════════════

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final bool hasName;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _NameField({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.hasName,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 250),

      curve: Curves.easeOutCubic,

      width: double.infinity,

      padding: const EdgeInsets.only(
        left: 17,
        right: 8,
        top: 2,
        bottom: 2,
      ),

      decoration: BoxDecoration(
        color: focused
            ? AppColors.accent.withOpacity(
                0.045,
              )
            : AppColors.textPrimary.withOpacity(
                0.018,
              ),

        borderRadius:
            BorderRadius.circular(17),

        border: Border.all(
          color: focused
              ? AppColors.accent.withOpacity(
                  0.62,
                )
              : AppColors.divider,

          width: focused ? 1.3 : 1,
        ),

        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.accent
                      .withOpacity(0.10),

                  blurRadius: 22,

                  spreadRadius: -6,
                ),
              ]
            : null,
      ),

      // IMPORTANT:
      // TextField has NO border of its own.
      // This prevents the "double textbox" effect.
      child: TextField(
        controller: controller,
        focusNode: focusNode,

        textCapitalization:
            TextCapitalization.words,

        textInputAction:
            TextInputAction.done,

        maxLength: 24,

        style: AppTextStyles.hero.copyWith(
          fontSize: 26,
          height: 1.15,
          letterSpacing: -0.4,
        ),

        cursorColor:
            AppColors.accent,

        cursorWidth: 1.5,

        decoration: InputDecoration(
          counterText: '',

          hintText: 'Luna',

          hintStyle:
              AppTextStyles.hero.copyWith(
            fontSize: 26,
            height: 1.15,
            color:
                AppColors.textMuted,
          ),

          border: InputBorder.none,

          enabledBorder:
              InputBorder.none,

          focusedBorder:
              InputBorder.none,

          disabledBorder:
              InputBorder.none,

          errorBorder:
              InputBorder.none,

          focusedErrorBorder:
              InputBorder.none,

          filled: false,

          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 13,
          ),

          suffixIcon:
              AnimatedSwitcher(
            duration:
                const Duration(
              milliseconds: 200,
            ),

            transitionBuilder:
                (child, animation) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve:
                      Curves.easeOutBack,
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },

            child: hasName
                ? Container(
                    key: const ValueKey(
                      'check',
                    ),

                    margin:
                        const EdgeInsets.all(
                      9,
                    ),

                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,

                      color: AppColors
                          .accent
                          .withOpacity(
                        0.12,
                      ),
                    ),

                    child: Icon(
                      Icons.check_rounded,
                      color:
                          AppColors.accent,
                      size: 18,
                    ),
                  )
                : const SizedBox(
                    key: ValueKey(
                      'empty',
                    ),
                  ),
          ),
        ),

        onChanged: (_) {
          onChanged();
        },

        onSubmitted: (_) {
          onSubmitted();
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// NAME RESPONSE
// ═══════════════════════════════════════════════════════════════════════

class _NameResponse extends StatelessWidget {
  final String name;

  const _NameResponse({
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: AppColors.accent
            .withOpacity(0.045),

        borderRadius:
            BorderRadius.circular(13),

        border: Border.all(
          color: AppColors.accent
              .withOpacity(0.10),
        ),
      ),

      child: Row(
        children: [
          _InitialAvatar(
            name: name,
            size: 30,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              '$name. That feels right.',
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,

              style: AppTextStyles
                  .bodyEmphasis
                  .copyWith(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// COMPANION ORB
// ═══════════════════════════════════════════════════════════════════════

class _CompanionOrb extends StatelessWidget {
  final double glow;
  final bool focused;
  final bool hasName;
  final String name;

  const _CompanionOrb({
    required this.glow,
    required this.focused,
    required this.hasName,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final intensity =
        focused ? 1.0 : 0.72;

    final initials =
        _getInitials(name);

    return SizedBox(
      width: 112,
      height: 112,

      child: Stack(
        alignment: Alignment.center,
        children: [
          // ============================================================
          // GLOW
          // ============================================================

          Container(
            width: 112,
            height: 112,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient:
                  RadialGradient(
                colors: [
                  AppColors.accent
                      .withOpacity(
                    0.15 *
                        glow *
                        intensity,
                  ),

                  AppColors.accent
                      .withOpacity(
                    0.045 *
                        glow *
                        intensity,
                  ),

                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ============================================================
          // OUTER RING
          // ============================================================

          AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 350,
            ),

            curve:
                Curves.easeOutCubic,

            width:
                focused ? 92 : 86,

            height:
                focused ? 92 : 86,

            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,

              border:
                  Border.all(
                color: AppColors
                    .accent
                    .withOpacity(
                  focused
                      ? 0.34
                      : 0.16,
                ),

                width: 1,
              ),
            ),
          ),

          // ============================================================
          // INNER INITIALS CIRCLE
          // ============================================================

          AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 350,
            ),

            curve:
                Curves.easeOutCubic,

            width:
                focused ? 68 : 62,

            height:
                focused ? 68 : 62,

            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,

              gradient:
                  RadialGradient(
                colors: [
                  AppColors.accent
                      .withOpacity(
                    hasName
                        ? 0.34
                        : 0.22,
                  ),

                  AppColors.accent
                      .withOpacity(
                    0.09,
                  ),

                  Colors.transparent,
                ],
              ),

              boxShadow: [
                BoxShadow(
                  color: AppColors
                      .accent
                      .withOpacity(
                    focused
                        ? 0.20
                        : 0.10,
                  ),

                  blurRadius:
                      focused
                          ? 26
                          : 18,

                  spreadRadius:
                      focused ? 2 : 0,
                ),
              ],
            ),

            child: Center(
              child:
                  AnimatedSwitcher(
                duration:
                    const Duration(
                  milliseconds: 250,
                ),

                transitionBuilder:
                    (
                  child,
                  animation,
                ) {
                  return ScaleTransition(
                    scale:
                        CurvedAnimation(
                      parent:
                          animation,
                      curve:
                          Curves.easeOutBack,
                    ),
                    child:
                        FadeTransition(
                      opacity:
                          animation,
                      child: child,
                    ),
                  );
                },

                child: Text(
                  initials,

                  key: ValueKey(
                    initials,
                  ),

                  style: TextStyle(
                    color: AppColors
                        .textPrimary,

                    fontSize:
                        initials.length > 1
                            ? 20
                            : 24,

                    fontWeight:
                        FontWeight.w600,

                    letterSpacing:
                        initials.length > 1
                            ? 1.2
                            : 0,

                    height: 1,
                  ),
                ),
              ),
            ),
          ),

          // ============================================================
          // ORBIT DOT
          // ============================================================

          Positioned(
            top: 14,
            right: 22,

            child:
                AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 300,
              ),

              width:
                  focused ? 6 : 5,

              height:
                  focused ? 6 : 5,

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
                      0.55,
                    ),

                    blurRadius:
                        focused ? 10 : 7,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String value) {
    final clean =
        value.trim();

    if (clean.isEmpty) {
      return 'V';
    }

    final parts = clean
        .split(RegExp(r'\s+'))
        .where(
          (part) =>
              part.isNotEmpty,
        )
        .toList();

    if (parts.length >= 2) {
      return (
        parts.first[0] +
        parts.last[0]
      ).toUpperCase();
    }

    return parts.first[0]
        .toUpperCase();
  }
}

// ═══════════════════════════════════════════════════════════════════════
// INITIAL AVATAR
// ═══════════════════════════════════════════════════════════════════════

class _InitialAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _InitialAvatar({
    required this.name,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final initials =
        _getInitials(name);

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 250),

      width: size,
      height: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        gradient:
            AppColors.accentGradient,

        boxShadow: [
          BoxShadow(
            color: AppColors.accent
                .withOpacity(0.18),

            blurRadius: 12,
          ),
        ],
      ),

      child: Container(
        margin:
            const EdgeInsets.all(1.5),

        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              AppColors.background,
        ),

        child: Center(
          child: Text(
            initials,

            style: TextStyle(
              color:
                  AppColors.accent,

              fontSize:
                  initials.length > 1
                      ? size * 0.27
                      : size * 0.34,

              fontWeight:
                  FontWeight.w600,

              letterSpacing:
                  initials.length > 1
                      ? 0.6
                      : 0,

              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String value) {
    final clean =
        value.trim();

    if (clean.isEmpty) {
      return 'V';
    }

    final parts = clean
        .split(RegExp(r'\s+'))
        .where(
          (part) =>
              part.isNotEmpty,
        )
        .toList();

    if (parts.length >= 2) {
      return (
        parts.first[0] +
        parts.last[0]
      ).toUpperCase();
    }

    return parts.first[0]
        .toUpperCase();
  }
}