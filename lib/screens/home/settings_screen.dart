import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../auth/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _placeholderItems = [
    (Icons.person_outline, 'Account'),
    (Icons.notifications_outlined, 'Notifications'),
    (Icons.location_on_outlined, 'Location'),
    (Icons.auto_awesome_outlined, 'Memory'),
    (Icons.shield_outlined, 'Privacy'),
    (Icons.download_outlined, 'Data controls'),
  ];

  bool _togglingPlus = false;

  Future<void> _togglePlus(bool value) async {
    setState(() => _togglingPlus = true);
    final appState = context.read<AppState>();
    try {
      await appState.entitlementsApi.mockSetSubscription(value ? 'active' : 'inactive');
      await appState.refreshEntitlements();
    } finally {
      if (mounted) setState(() => _togglingPlus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.user!;
    final isPlus = appState.entitlements.isPlus;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        children: [
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.elevated,
                child: Text(
                  user.email.isNotEmpty ? user.email[0].toUpperCase() : '?',
                  style: AppTextStyles.bodyEmphasis,
                ),
              ),
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.preferredName.isNotEmpty ? user.preferredName : user.email,
                        style: AppTextStyles.bodyEmphasis),
                    Text(user.email, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: isPlus
                  ? const LinearGradient(colors: [AppColors.champagne, AppColors.accent])
                  : AppColors.cardGradient,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.dividerFaint),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: isPlus ? AppColors.background : AppColors.champagne, size: 20),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VEYRA+',
                        style: AppTextStyles.bodyEmphasis.copyWith(
                          color: isPlus ? AppColors.background : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Dev mock — no real store integration yet.',
                        style: AppTextStyles.caption.copyWith(
                          color: isPlus ? AppColors.background.withValues(alpha: 0.7) : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  activeThumbColor: AppColors.background,
                  activeTrackColor: AppColors.background.withValues(alpha: 0.3),
                  value: isPlus,
                  onChanged: _togglingPlus ? null : _togglePlus,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final (icon, label) in _placeholderItems) _SettingsRow(icon: icon, label: label),
          const SizedBox(height: AppSpacing.lg),
          _SettingsRow(
            icon: Icons.logout,
            label: 'Sign out',
            danger: true,
            onTap: () async {
              await context.read<AppState>().signOut();
              if (!context.mounted) return;
              context.read<OnboardingController>().reset();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback? onTap;

  const _SettingsRow({required this.icon, required this.label, this.danger = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: onTap ??
          () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label settings are coming soon.')),
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.smd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.dividerFaint),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: danger ? AppColors.danger : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyEmphasis.copyWith(color: danger ? AppColors.danger : AppColors.textPrimary),
              ),
            ),
            if (!danger) const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
