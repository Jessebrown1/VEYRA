import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_text_styles.dart';

/// The app's signature action button — gradient fill, soft accent glow, and
/// a gentle press-scale so it feels tactile rather than flat.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _active => widget.enabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    return GestureDetector(
      onTapDown: _active ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: _active ? () => setState(() => _pressed = false) : null,
      onTapUp: _active ? (_) => setState(() => _pressed = false) : null,
      onTap: _active ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _active ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: double.infinity,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(AppRadii.md),
              boxShadow: _active ? AppShadows.accentGlow : null,
            ),
            child: Text(
              widget.label,
              style: AppTextStyles.bodyEmphasis.copyWith(
                color: AppColors.background,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
