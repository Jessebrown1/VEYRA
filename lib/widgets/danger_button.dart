import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_text_styles.dart';

/// A bordered, danger-colored button for destructive actions (delete
/// account, forget all memories) — visually distinct from PrimaryButton's
/// accent gradient, which reads as a positive/exciting action.
class DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  const DangerButton({super.key, required this.label, required this.onPressed, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final active = enabled && onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: active ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.danger.withValues(alpha: active ? 0.6 : 0.25)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyEmphasis.copyWith(
            color: AppColors.danger.withValues(alpha: active ? 1 : 0.4),
          ),
        ),
      ),
    );
  }
}
