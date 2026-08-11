import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/term_of_address_catalog.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_effects.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/premium_lock_sheet.dart';
import '../../widgets/primary_button.dart';
import 'appearance_screen.dart';

class UserNameScreen extends StatefulWidget {
  const UserNameScreen({super.key});

  @override
  State<UserNameScreen> createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<OnboardingController>().userPreferredName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();
    final companionName = controller.companionName;
    final terms = TermOfAddressCatalog.forRelationship(controller.relationshipId!);
    final name = _controller.text.trim();

    return OnboardingScaffold(
      step: 4,
      totalSteps: 8,
      title: 'What should $companionName call you?',
      subtitle: 'Or choose what feels natural.',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.words,
              style: AppTextStyles.display,
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                hintText: 'Your name',
                hintStyle: AppTextStyles.display.copyWith(color: AppColors.textMuted),
                filled: false,
                contentPadding: EdgeInsets.zero,
                border: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Or', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: terms.map((term) {
                final isSelected = controller.termOfAddressId == term.id;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(term.label),
                      if (term.isPremium) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.lock, size: 12, color: AppColors.champagne),
                      ],
                    ],
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  selected: isSelected,
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.accent.withValues(alpha: 0.18),
                  side: BorderSide(color: isSelected ? AppColors.accent : AppColors.dividerFaint),
                  labelStyle: AppTextStyles.bodyEmphasis,
                  onSelected: (_) {
                    if (term.isPremium) {
                      showPremiumLockSheet(context, featureName: '"${term.label}" as a custom term');
                    } else {
                      context.read<OnboardingController>().setTermOfAddress(term.id);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      footer: PrimaryButton(
        label: 'Continue',
        enabled: name.isNotEmpty && controller.termOfAddressId != null,
        onPressed: () {
          context.read<OnboardingController>().setUserPreferredName(name);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AppearanceScreen()),
          );
        },
      ),
    );
  }
}
