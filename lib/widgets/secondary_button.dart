import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SecondaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
      child: Text(label, style: AppTextStyles.bodyEmphasis.copyWith(color: AppColors.textSecondary)),
    );
  }
}
