import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

Future<void> showPremiumLockSheet(
  BuildContext context, {
  required String featureName,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.elevated,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.champagne, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: AppShadows.accentGlow,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.background, size: 24),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('VEYRA+', style: AppTextStyles.eyebrow),
            const SizedBox(height: AppSpacing.xs),
            Text('Make them truly yours.', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$featureName is part of VEYRA+.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.md),
            const _FeatureLine('Advanced personality'),
            const _FeatureLine('Custom appearance'),
            const _FeatureLine('Deeper memory'),
            const _FeatureLine('Advanced relationships'),
            const _FeatureLine('More personalization'),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Unlock VEYRA+',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: SecondaryButton(
                label: 'Maybe later',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _FeatureLine extends StatelessWidget {
  final String text;
  const _FeatureLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: AppColors.champagne),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
