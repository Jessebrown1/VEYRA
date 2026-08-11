import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/personality_catalog.dart';
import '../../data/relationship_catalog.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/premium_lock_sheet.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/selection_card.dart';
import 'companion_name_screen.dart';

const _relationshipIcons = {
  'friend': Icons.emoji_people,
  'best_friend': Icons.diversity_1,
  'study_partner': Icons.menu_book,
  'motivator': Icons.trending_up,
  'girlfriend': Icons.favorite,
  'boyfriend': Icons.favorite,
  'confidant': Icons.lock_outline,
  'mentor': Icons.school,
  'coach': Icons.sports,
  'gaming_partner': Icons.sports_esports,
  'custom': Icons.tune,
};

class RelationshipScreen extends StatelessWidget {
  const RelationshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();
    final selected = controller.relationshipId != null
        ? RelationshipCatalog.byId(controller.relationshipId!)
        : null;
    final personalityLabel = controller.personalityId != null
        ? PersonalityCatalog.byId(controller.personalityId!).label
        : null;

    return OnboardingScaffold(
      step: 2,
      totalSteps: 8,
      title: 'What would you like your relationship to be?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selected != null) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote, size: 18, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      selected.previewBuilder(personalityLabel),
                      style: AppTextStyles.bodyEmphasis.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: ListView.separated(
              itemCount: RelationshipCatalog.all.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final option = RelationshipCatalog.all[index];
                return SelectionCard(
                  title: option.label,
                  description: option.description,
                  isSelected: controller.relationshipId == option.id,
                  isPremium: option.isPremium,
                  icon: _relationshipIcons[option.id],
                  onTap: () {
                    if (option.isPremium) {
                      showPremiumLockSheet(context, featureName: '${option.label} relationship');
                    } else {
                      context.read<OnboardingController>().setRelationship(option.id);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      footer: PrimaryButton(
        label: 'Continue',
        enabled: controller.relationshipId != null,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CompanionNameScreen()),
        ),
      ),
    );
  }
}
