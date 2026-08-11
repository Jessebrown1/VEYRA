import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/theme_controller.dart';
import '../../state/app_state.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../auth/welcome_screen.dart';
import 'settings/account_settings_screen.dart';
import 'settings/data_controls_screen.dart';
import 'settings/location_settings_screen.dart';
import 'settings/notifications_settings_screen.dart';
import 'settings/privacy_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _togglingPlus = false;

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

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
    context.watch<ThemeController>();
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
                  ? LinearGradient(colors: [AppColors.champagne, AppColors.accent])
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
          const _AppearanceSection(),
          const SizedBox(height: AppSpacing.lg),
          const _BiometricSection(),
          const SizedBox(height: AppSpacing.lg),
          _SettingsRow(
            icon: Icons.person_outline,
            label: 'Account',
            onTap: () => _open(const AccountSettingsScreen()),
          ),
          _SettingsRow(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => _open(const NotificationsSettingsScreen()),
          ),
          _SettingsRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            onTap: () => _open(const LocationSettingsScreen()),
          ),
          _SettingsRow(
            icon: Icons.auto_awesome_outlined,
            label: 'Memory',
          ),
          _SettingsRow(
            icon: Icons.shield_outlined,
            label: 'Privacy',
            onTap: () => _open(const PrivacySettingsScreen()),
          ),
          _SettingsRow(
            icon: Icons.download_outlined,
            label: 'Data controls',
            onTap: () => _open(const DataControlsScreen()),
          ),
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

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  static const _options = [
    (ThemeMode.system, Icons.brightness_auto, 'System'),
    (ThemeMode.light, Icons.light_mode_outlined, 'Light'),
    (ThemeMode.dark, Icons.dark_mode_outlined, 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.dividerFaint),
      ),
      child: Row(
        children: [
          for (final (mode, icon, label) in _options)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.md),
                onTap: () => controller.setMode(mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: controller.mode == mode ? AppColors.accent.withValues(alpha: 0.16) : null,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: controller.mode == mode ? AppColors.accent : AppColors.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: AppTextStyles.microcopy.copyWith(
                          color: controller.mode == mode ? AppColors.accent : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BiometricSection extends StatefulWidget {
  const _BiometricSection();

  @override
  State<_BiometricSection> createState() => _BiometricSectionState();
}

class _BiometricSectionState extends State<_BiometricSection> {
  bool? _available;
  bool _enabled = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final biometrics = context.read<AppState>().biometrics;
    final available = await biometrics.isAvailable;
    final enabled = await biometrics.isEnabled;
    if (!mounted) return;
    setState(() {
      _available = available;
      _enabled = enabled;
    });
  }

  Future<void> _toggle(bool value) async {
    final biometrics = context.read<AppState>().biometrics;
    setState(() => _busy = true);
    if (value) {
      final confirmed = await biometrics.authenticate(reason: 'Enable biometric unlock for VEYRA');
      if (confirmed) {
        await biometrics.setEnabled(true);
        if (mounted) setState(() => _enabled = true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't verify — biometric unlock wasn't enabled.")),
        );
      }
    } else {
      await biometrics.setEnabled(false);
      if (mounted) setState(() => _enabled = false);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final available = _available;
    if (available == false) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.smd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.dividerFaint),
      ),
      child: Row(
        children: [
          Icon(Icons.fingerprint, size: 19, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Text('Biometric unlock', style: AppTextStyles.bodyEmphasis),
          ),
          Switch(
            value: _enabled,
            onChanged: available == null || _busy ? null : _toggle,
          ),
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
    context.watch<ThemeController>();
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
            if (!danger) Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
