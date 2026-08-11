import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../services/api_client.dart';
import '../../../state/app_state.dart';
import '../../../state/onboarding_controller.dart';
import '../../../state/theme_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/danger_button.dart';
import '../../../widgets/primary_button.dart';
import '../../auth/welcome_screen.dart';

class DataControlsScreen extends StatefulWidget {
  const DataControlsScreen({super.key});

  @override
  State<DataControlsScreen> createState() => _DataControlsScreenState();
}

class _DataControlsScreenState extends State<DataControlsScreen> {
  bool _exporting = false;
  bool _deleting = false;

  Future<void> _exportData() async {
    setState(() => _exporting = true);
    try {
      final data = await context.read<AppState>().authApi.exportData();
      final pretty = const JsonEncoder.withIndent('  ').convert(data);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => _ExportDialog(json: pretty),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ApiClient.toApiException(e).message)));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmText = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final canConfirm = confirmText.text.trim().toUpperCase() == 'DELETE';
          return AlertDialog(
            backgroundColor: AppColors.elevated,
            title: Text('Delete your account?', style: AppTextStyles.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This permanently deletes your account, your companion, every conversation, and every '
                  'memory. This cannot be undone.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Type DELETE to confirm.', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: confirmText,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(hintText: 'DELETE'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              TextButton(
                onPressed: canConfirm ? () => Navigator.of(context).pop(true) : null,
                child: Text(
                  'Delete forever',
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    color: AppColors.danger.withValues(alpha: canConfirm ? 1 : 0.4),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      await context.read<AppState>().authApi.deleteAccount();
      if (!mounted) return;
      context.read<OnboardingController>().reset();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ApiClient.toApiException(e).message)));
      setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Data controls')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('EXPORT', style: AppTextStyles.microcopy),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Get a copy of everything tied to your account — your profile, companion, conversations, '
            'and memories — as JSON.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: _exporting ? 'Preparing…' : 'Export my data',
            enabled: !_exporting,
            onPressed: _exportData,
          ),
          const SizedBox(height: AppSpacing.xl),
          Divider(color: AppColors.divider),
          const SizedBox(height: AppSpacing.lg),
          Text('DELETE ACCOUNT', style: AppTextStyles.microcopy),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Permanently deletes your account and everything in it. There is no way to undo this.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          DangerButton(
            label: _deleting ? 'Deleting…' : 'Delete my account',
            enabled: !_deleting,
            onPressed: _confirmDeleteAccount,
          ),
        ],
      ),
    );
  }
}

class _ExportDialog extends StatelessWidget {
  final String json;

  const _ExportDialog({required this.json});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.elevated,
      title: Text('Your data', style: AppTextStyles.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: SingleChildScrollView(
          child: SelectableText(json, style: AppTextStyles.caption.copyWith(fontFamily: 'monospace')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: json));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard.')));
          },
          child: const Text('Copy'),
        ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
