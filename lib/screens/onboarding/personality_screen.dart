import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/personality_catalog.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/premium_lock_sheet.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/selection_card.dart';
import 'relationship_screen.dart';

const _personalityIcons = {
  'caring': Icons.favorite_rounded,
  'calm': Icons.spa_rounded,
  'supportive': Icons.handshake_rounded,
  'curious': Icons.travel_explore_rounded,
  'confident': Icons.bolt_rounded,
  'romantic': Icons.local_fire_department_rounded,
  'intelligent': Icons.psychology_rounded,
  'playful': Icons.celebration_rounded,
  'custom': Icons.tune_rounded,
};

class PersonalityScreen extends StatefulWidget {
  const PersonalityScreen({super.key});

  @override
  State<PersonalityScreen> createState() => _PersonalityScreenState();
}

class _PersonalityScreenState extends State<PersonalityScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectPersonality(
    BuildContext context,
    dynamic option,
  ) {
    if (option.isPremium) {
      showPremiumLockSheet(
        context,
        featureName: '${option.label} personality',
      );
      return;
    }

    context.read<OnboardingController>().setPersonality(option.id);
  }

  void _continue() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const RelationshipScreen();
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
                begin: const Offset(0.035, 0),
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
    final controller = context.watch<OnboardingController>();
    final selectedId = controller.personalityId;

    final selectedOption = selectedId == null
        ? null
        : PersonalityCatalog.all
            .where((option) => option.id == selectedId)
            .firstOrNull;

    return OnboardingScaffold(
      step: 1,
      totalSteps: 7,
      title: 'How should they be?',
      subtitle:
          'Choose the personality that feels right for your companion.',

      // ================================================================
      // SCROLLABLE CONTENT
      // ================================================================

      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 24,
            ),
            child: child,
          );
        },

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),

            // ==========================================================
            // PERSONALITY PREVIEW
            // ==========================================================

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: selectedOption != null
                  ? _SelectedPersonalityPreview(
                      key: ValueKey(selectedOption.id),
                      option: selectedOption,
                      icon: _personalityIcons[selectedOption.id],
                    )
                  : const _PersonalityIntro(
                      key: ValueKey('intro'),
                    ),
            ),

            const SizedBox(height: 18),

            // ==========================================================
            // SECTION LABEL
            // ==========================================================

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
                  'PERSONALITY',
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ==========================================================
            // PERSONALITY OPTIONS
            // ==========================================================

            ...List.generate(
              PersonalityCatalog.all.length,
              (index) {
                final option = PersonalityCatalog.all[index];

                final start = (index * 0.065).clamp(0.0, 0.55);
                final end = (start + 0.42).clamp(0.0, 1.0);

                final animation = CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    start,
                    end,
                    curve: Curves.easeOutCubic,
                  ),
                );

                return AnimatedBuilder(
                  animation: animation,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: index ==
                              PersonalityCatalog.all.length - 1
                          ? 0
                          : AppSpacing.xs,
                    ),
                    child: _AnimatedSelectionCard(
                      option: option,
                      icon: _personalityIcons[option.id],
                      isSelected: selectedId == option.id,
                      onTap: () => _selectPersonality(
                        context,
                        option,
                      ),
                    ),
                  ),
                  builder: (context, child) {
                    final value = animation.value;

                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          14 * (1 - value),
                        ),
                        child: child,
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 14),

            // ==========================================================
            // HINT
            // ==========================================================

            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: selectedOption == null ? 0.85 : 0.55,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 12,
                      color: AppColors.textSecondary.withOpacity(0.65),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'You can shape them further later.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 11,
                        color:
                            AppColors.textSecondary.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ================================================================
      // FIXED FOOTER
      // ================================================================

      footer: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final enabled = controller.personalityId != null;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: enabled ? 1.0 : 0.55,
            child: child,
          );
        },
        child: PrimaryButton(
          label: 'Continue',
          enabled: controller.personalityId != null,
          onPressed: controller.personalityId != null
              ? _continue
              : null,
        ),
      ),
    );
  }
}

// ==========================================================================
// INTRO
// ==========================================================================

class _PersonalityIntro extends StatelessWidget {
  const _PersonalityIntro({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withOpacity(0.018),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withOpacity(0.08),
            ),
            child: Icon(
              Icons.psychology_alt_rounded,
              size: 19,
              color: AppColors.accent.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'Their personality will shape how they talk, react, and connect with you.',
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// SELECTED PERSONALITY
// ==========================================================================

class _SelectedPersonalityPreview extends StatelessWidget {
  final dynamic option;
  final IconData? icon;

  const _SelectedPersonalityPreview({
    super.key,
    required this.option,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withOpacity(0.12),
            AppColors.accent.withOpacity(0.025),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.06),
            blurRadius: 24,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withOpacity(0.32),
                  AppColors.accent.withOpacity(0.08),
                ],
              ),
            ),
            child: Icon(
              icon ?? Icons.auto_awesome_rounded,
              color: AppColors.accent,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your companion will be',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option.label,
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.accent,
            size: 19,
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// SELECTION CARD
// ==========================================================================

class _AnimatedSelectionCard extends StatelessWidget {
  final dynamic option;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedSelectionCard({
    required this.option,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.10),
                  blurRadius: 22,
                  spreadRadius: -6,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          SelectionCard(
            title: option.label,
            description: option.description,
            isSelected: isSelected,
            isPremium: option.isPremium,
            icon: icon,
            onTap: onTap,
          ),

          // Selection indicator.
          if (isSelected)
            Positioned(
              left: 0,
              top: 10,
              bottom: 10,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 3,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

          // Premium label.
          if (option.isPremium)
            Positioned(
              top: 8,
              right: 11,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.13),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 9,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'PREMIUM',
                        style: AppTextStyles.bodyEmphasis.copyWith(
                          fontSize: 7,
                          letterSpacing: 1,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}