import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/personality_catalog.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/premium_lock_sheet.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/selection_card.dart';
import 'relationship_screen.dart';

const _personalityIcons = {
  'caring': Icons.favorite,
  'calm': Icons.spa,
  'supportive': Icons.handshake,
  'curious': Icons.travel_explore,
  'confident': Icons.bolt,
  'romantic': Icons.local_fire_department,
  'intelligent': Icons.psychology,
  'playful': Icons.celebration,
  'custom': Icons.tune,
};

class PersonalityScreen extends StatelessWidget {
  const PersonalityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();

    return OnboardingScaffold(
      step: 1,
      totalSteps: 8,
      title: 'How should they be?',
      child: ListView.separated(
        itemCount: PersonalityCatalog.all.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final option = PersonalityCatalog.all[index];
          return SelectionCard(
            title: option.label,
            description: option.description,
            isSelected: controller.personalityId == option.id,
            isPremium: option.isPremium,
            icon: _personalityIcons[option.id],
            onTap: () {
              if (option.isPremium) {
                showPremiumLockSheet(context, featureName: '${option.label} personality');
              } else {
                context.read<OnboardingController>().setPersonality(option.id);
              }
            },
          );
        },
      ),
      footer: PrimaryButton(
        label: 'Continue',
        enabled: controller.personalityId != null,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RelationshipScreen()),
        ),
      ),
    );
  }
}
