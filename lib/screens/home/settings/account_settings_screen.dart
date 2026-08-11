import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/api_client.dart';
import '../../../state/app_state.dart';
import '../../../state/theme_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_effects.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/veyra_text_field.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late final TextEditingController _nameController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _savingName = false;
  bool _changingPassword = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: context.read<AppState>().user?.preferredName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _savingName = true);
    final appState = context.read<AppState>();
    try {
      final updated = await appState.authApi.updateProfile(preferredName: name);
      appState.updateUser(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ApiClient.toApiException(e).message)));
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text;
    final next = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (next.length < 8) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('New password must be at least 8 characters.')));
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords don't match.")));
      return;
    }

    setState(() => _changingPassword = true);
    try {
      await context.read<AppState>().authApi.changePassword(currentPassword: current, newPassword: next);
      if (!mounted) return;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ApiClient.toApiException(e).message)));
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final user = context.watch<AppState>().user;
    final nameChanged = _nameController.text.trim() != (user?.preferredName ?? '');
    final canChangePassword = _currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        !_changingPassword;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('EMAIL', style: AppTextStyles.microcopy),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.smd),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.dividerFaint),
            ),
            child: Text(user?.email ?? '', style: AppTextStyles.bodyEmphasis),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('PREFERRED NAME', style: AppTextStyles.microcopy),
          const SizedBox(height: AppSpacing.xs),
          VeyraTextField(
            controller: _nameController,
            hint: 'Your name',
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: _savingName ? 'Saving…' : 'Save name',
            enabled: nameChanged && !_savingName,
            onPressed: _saveName,
          ),
          const SizedBox(height: AppSpacing.xl),
          Divider(color: AppColors.divider),
          const SizedBox(height: AppSpacing.lg),
          Text('CHANGE PASSWORD', style: AppTextStyles.microcopy),
          const SizedBox(height: AppSpacing.sm),
          VeyraTextField(
            controller: _currentPasswordController,
            hint: 'Current password',
            obscureText: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          VeyraTextField(
            controller: _newPasswordController,
            hint: 'New password (min. 8 characters)',
            obscureText: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          VeyraTextField(
            controller: _confirmPasswordController,
            hint: 'Confirm new password',
            obscureText: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: _changingPassword ? 'Changing…' : 'Change password',
            enabled: canChangePassword,
            onPressed: _changePassword,
          ),
        ],
      ),
    );
  }
}
