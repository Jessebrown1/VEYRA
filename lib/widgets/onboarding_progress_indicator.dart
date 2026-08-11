import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  final int step;
  final int totalSteps;

  const OnboardingProgressIndicator({
    super.key,
    required this.step,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < step;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            height: 4,
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
            decoration: BoxDecoration(
              gradient: isActive ? AppColors.accentGradient : null,
              color: isActive ? null : AppColors.dividerFaint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
