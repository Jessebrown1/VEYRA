import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/api_client.dart';
import '../../../state/app_state.dart';
import '../../../state/theme_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_effects.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/danger_button.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _clearing = false;

  Future<void> _confirmClearMemories() async {
    final companion = context.read<AppState>().companion;
    if (companion == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.elevated,
        title: Text('Forget everything?', style: AppTextStyles.title),
        content: Text(
          '${companion.name} will forget every memory they\'ve formed about you. This can\'t be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Forget all', style: AppTextStyles.bodyEmphasis.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _clearing = true);
    try {
      await context.read<AppState>().settingsApi.clearAllMemories(companion.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${companion.name} has forgotten everything.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ApiClient.toApiException(e).message)));
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final companion = context.watch<AppState>().companion;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('WHAT WE STORE', style: AppTextStyles.microcopy),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.dividerFaint),
            ),
            child: Text(
              'Your conversations and the facts ${companion?.name ?? 'your companion'} remembers about '
              'you are stored so they can hold a consistent relationship with you over time. Nothing is '
              'shared with other users, and you can review or delete individual memories from the '
              'Memories tab at any time.',
              style: AppTextStyles.body,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Divider(color: AppColors.divider),
          const SizedBox(height: AppSpacing.lg),
          Text('MEMORY', style: AppTextStyles.microcopy),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Forgetting everything removes every memory ${companion?.name ?? 'your companion'} has '
            'formed about you. Your conversation history stays intact.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          DangerButton(
            label: _clearing ? 'Forgetting…' : 'Forget everything',
            enabled: companion != null && !_clearing,
            onPressed: _confirmClearMemories,
          ),
        ],
      ),
    );
  }
}
