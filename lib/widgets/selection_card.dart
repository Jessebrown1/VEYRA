import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final bool isPremium;
  final IconData? icon;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.isPremium = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.cardGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.dividerFaint,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? AppShadows.accentGlowSoft : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.accentGradient : null,
                  color: isSelected ? null : AppColors.elevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: isSelected ? AppColors.background : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.smd),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title.toUpperCase(), style: AppTextStyles.bodyEmphasis.copyWith(letterSpacing: 0.3)),
                      if (isPremium) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.lock, size: 13, color: AppColors.champagne),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(description, style: AppTextStyles.body),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.accent, size: 22, key: ValueKey('sel'))
                  : const Icon(Icons.circle_outlined, color: AppColors.textMuted, size: 22, key: ValueKey('unsel')),
            ),
          ],
        ),
      ),
    );
  }
}
