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

    _nameController = TextEditingController(
      text: context.read<AppState>().user?.preferredName ?? '',
    );
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
      final updated = await appState.authApi.updateProfile(
        preferredName: name,
      );

      appState.updateUser(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name updated.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ApiClient.toApiException(e).message,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _savingName = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text;
    final next = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (next.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'New password must be at least 8 characters.',
          ),
        ),
      );
      return;
    }

    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords don't match."),
        ),
      );
      return;
    }

    setState(() => _changingPassword = true);

    try {
      await context.read<AppState>().authApi.changePassword(
            currentPassword: current,
            newPassword: next,
          );

      if (!mounted) return;

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ApiClient.toApiException(e).message,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _changingPassword = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final user = context.watch<AppState>().user;

    final nameChanged =
        _nameController.text.trim() != (user?.preferredName ?? '');

    final canChangePassword =
        _currentPasswordController.text.isNotEmpty &&
            _newPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty &&
            !_changingPassword;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: AppSpacing.screenPadding,
        title: const Text('Account'),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.sm,
            AppSpacing.screenPadding,
            AppSpacing.xxl,
          ),
          children: [
            // Header
            _AccountHeader(
              name: user?.preferredName ?? '',
              email: user?.email ?? '',
            ),

            const SizedBox(height: AppSpacing.xl),

            // Profile section
            _SectionHeader(
              icon: Icons.person_outline_rounded,
              title: 'Profile',
              subtitle: 'Manage how VEYRA identifies you.',
            ),

            const SizedBox(height: AppSpacing.sm),

            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(
                    icon: Icons.email_outlined,
                    label: 'Email address',
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  _EmailCard(
                    email: user?.email ?? '',
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _FieldLabel(
                    icon: Icons.badge_outlined,
                    label: 'Preferred name',
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  VeyraTextField(
                    controller: _nameController,
                    hint: 'Your name',
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    height: nameChanged || _savingName ? 52 : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: nameChanged || _savingName ? 1 : 0,
                      child: PrimaryButton(
                        label: _savingName ? 'Saving…' : 'Save changes',
                        enabled: nameChanged && !_savingName,
                        onPressed: _saveName,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Security
            _SectionHeader(
              icon: Icons.lock_outline_rounded,
              title: 'Security',
              subtitle: 'Keep your VEYRA account protected.',
            ),

            const SizedBox(height: AppSpacing.sm),

            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SecurityIntro(),

                  const SizedBox(height: AppSpacing.lg),

                  VeyraTextField(
                    controller: _currentPasswordController,
                    hint: 'Current password',
                    obscureText: true,
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  VeyraTextField(
                    controller: _newPasswordController,
                    hint: 'New password',
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

                  const SizedBox(height: AppSpacing.md),

                  _PasswordRequirements(
                    password: _newPasswordController.text,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          child: child,
                        ),
                      );
                    },
                    child: canChangePassword
                        ? PrimaryButton(
                            key: const ValueKey('active'),
                            label: _changingPassword
                                ? 'Changing…'
                                : 'Update password',
                            enabled: !_changingPassword,
                            onPressed: _changePassword,
                          )
                        : Container(
                            key: const ValueKey('inactive'),
                            height: 0,
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Security footer
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: AppColors.dividerFaint,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withValues(alpha: 0.10),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 17,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Your account security settings are only visible to you.',
                      style: AppTextStyles.caption.copyWith(
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────

class _AccountHeader extends StatelessWidget {
  final String name;
  final String email;

  const _AccountHeader({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        name.isNotEmpty ? name : 'Your account';

    final initial = email.isNotEmpty
        ? email[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.elevated,
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: AppColors.dividerFaint,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: AppShadows.accentGlowSoft,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.20),
              ),
            ),
            child: Icon(
              Icons.verified_outlined,
              size: 16,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.16),
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color: AppColors.accent,
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyEmphasis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────
// GLASS CARD
// ─────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: AppColors.dividerFaint,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }
}


// ─────────────────────────────────────────────────────────────
// FIELD LABEL
// ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FieldLabel({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.microcopy,
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────
// EMAIL CARD
// ─────────────────────────────────────────────────────────────

class _EmailCard extends StatelessWidget {
  final String email;

  const _EmailCard({
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.dividerFaint,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyEmphasis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.lock_outline_rounded,
            size: 15,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// SECURITY INTRO
// ─────────────────────────────────────────────────────────────

class _SecurityIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security_rounded,
            size: 20,
            color: AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update your password',
                  style: AppTextStyles.bodyEmphasis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Use a strong password that you do not reuse elsewhere.',
                  style: AppTextStyles.caption.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// PASSWORD REQUIREMENTS
// ─────────────────────────────────────────────────────────────

class _PasswordRequirements extends StatelessWidget {
  final String password;

  const _PasswordRequirements({
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final lengthValid = password.length >= 8;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lengthValid
                  ? AppColors.success
                  : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'At least 8 characters',
            style: AppTextStyles.caption.copyWith(
              color: lengthValid
                  ? AppColors.success
                  : AppColors.textMuted,
            ),
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: lengthValid
                ? Icon(
                    Icons.check_circle_rounded,
                    key: const ValueKey('valid'),
                    size: 17,
                    color: AppColors.success,
                  )
                : const SizedBox(
                    key: ValueKey('invalid'),
                    width: 17,
                    height: 17,
                  ),
          ),
        ],
      ),
    );
  }
}