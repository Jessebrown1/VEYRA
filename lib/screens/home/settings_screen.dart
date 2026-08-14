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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _togglePlus(bool value) async {
    setState(() => _togglingPlus = true);

    final appState = context.read<AppState>();

    try {
      await appState.entitlementsApi.mockSetSubscription(
        value ? 'active' : 'inactive',
      );

      await appState.refreshEntitlements();
    } finally {
      if (mounted) {
        setState(() => _togglingPlus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final appState = context.watch<AppState>();
    final user = appState.user!;
    final isPlus = appState.entitlements.isPlus;

    final displayName = user.preferredName.isNotEmpty
        ? user.preferredName
        : user.email;

    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: AppSpacing.screenPadding,
        title: Text(
          'Settings',
          style: AppTextStyles.title.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.glow(
                    AppColors.accent,
                    opacity: 0.10,
                  ),
                ),
              ),
            ),
          ),

          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              40,
            ),
            children: [
              _ProfileHeader(
                initial: initial,
                displayName: displayName,
                email: user.email,
              ),

              const SizedBox(height: AppSpacing.xl),

              _SectionLabel(
                label: 'MEMBERSHIP',
              ),

              const SizedBox(height: AppSpacing.sm),

              _PlusCard(
                isPlus: isPlus,
                loading: _togglingPlus,
                onChanged: _togglePlus,
              ),

              const SizedBox(height: AppSpacing.xl),

              _SectionLabel(
                label: 'PREFERENCES',
              ),

              const SizedBox(height: AppSpacing.sm),

              const _AppearanceSection(),

              const SizedBox(height: AppSpacing.sm),

              const _BiometricSection(),

              const SizedBox(height: AppSpacing.xl),

              _SectionLabel(
                label: 'ACCOUNT',
              ),

              const SizedBox(height: AppSpacing.sm),

              _SettingsRow(
                icon: Icons.person_outline_rounded,
                label: 'Account',
                description: 'Profile and account details',
                onTap: () => _open(
                  const AccountSettingsScreen(),
                ),
              ),

              _SettingsRow(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                description: 'Reminders and check-ins',
                onTap: () => _open(
                  const NotificationsSettingsScreen(),
                ),
              ),

              _SettingsRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                description: 'Location permissions',
                onTap: () => _open(
                  const LocationSettingsScreen(),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              _SectionLabel(
                label: 'COMPANION',
              ),

              const SizedBox(height: AppSpacing.sm),

              _SettingsRow(
                icon: Icons.auto_awesome_rounded,
                label: 'Memory',
                description: 'What VEYRA remembers about you',
              ),

              _SettingsRow(
                icon: Icons.shield_outlined,
                label: 'Privacy',
                description: 'Privacy and personalization',
                onTap: () => _open(
                  const PrivacySettingsScreen(),
                ),
              ),

              _SettingsRow(
                icon: Icons.download_outlined,
                label: 'Data controls',
                description: 'Export and manage your data',
                onTap: () => _open(
                  const DataControlsScreen(),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              _SectionLabel(
                label: 'SESSION',
              ),

              const SizedBox(height: AppSpacing.sm),

              _SettingsRow(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                description: 'Sign out of this VEYRA account',
                danger: true,
                onTap: () async {
                  await context.read<AppState>().signOut();

                  if (!context.mounted) return;

                  context.read<OnboardingController>().reset();

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const WelcomeScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              Center(
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return AppColors.accentGradient.createShader(
                          bounds,
                        );
                      },
                      child: Text(
                        'VEYRA',
                        style: AppTextStyles.wordmark.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your companion, your world.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROFILE HEADER
// ─────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String initial;
  final String displayName;
  final String email;

  const _ProfileHeader({
    required this.initial,
    required this.displayName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

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
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: AppShadows.accentGlowSoft,
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
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
                  style: AppTextStyles.title.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppRadii.pill,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 12,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'VEYRA account',
                        style: AppTextStyles.microcopy.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
      ),
      child: Text(
        label,
        style: AppTextStyles.microcopy.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VEYRA+ CARD
// ─────────────────────────────────────────────

class _PlusCard extends StatelessWidget {
  final bool isPlus;
  final bool loading;
  final ValueChanged<bool> onChanged;

  const _PlusCard({
    required this.isPlus,
    required this.loading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: isPlus
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.champagne,
                  AppColors.accent,
                ],
              )
            : AppColors.cardGradient,
        borderRadius: BorderRadius.circular(
          AppRadii.xl,
        ),
        border: Border.all(
          color: isPlus
              ? AppColors.champagne.withValues(
                  alpha: 0.7,
                )
              : AppColors.dividerFaint,
        ),
        boxShadow: isPlus
            ? AppShadows.accentGlowSoft
            : AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPlus
                      ? AppColors.background.withValues(
                          alpha: 0.15,
                        )
                      : AppColors.champagne.withValues(
                          alpha: 0.10,
                        ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: isPlus
                      ? AppColors.background
                      : AppColors.champagne,
                  size: 21,
                ),
              ),

              const SizedBox(width: AppSpacing.smd),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VEYRA+',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isPlus
                            ? AppColors.background
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPlus
                          ? 'Premium companion enabled'
                          : 'Unlock the full experience',
                      style: AppTextStyles.caption.copyWith(
                        color: isPlus
                            ? AppColors.background.withValues(
                                alpha: 0.72,
                              )
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              if (loading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isPlus
                        ? AppColors.background
                        : AppColors.accent,
                  ),
                )
              else
                Switch(
                  value: isPlus,
                  activeThumbColor: AppColors.background,
                  activeTrackColor:
                      AppColors.background.withValues(
                    alpha: 0.28,
                  ),
                  onChanged: onChanged,
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            height: 1,
            color: isPlus
                ? AppColors.background.withValues(
                    alpha: 0.15,
                  )
                : AppColors.dividerFaint,
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              _PlusFeature(
                icon: Icons.psychology_outlined,
                text: 'Advanced memory',
                active: isPlus,
              ),
              const SizedBox(width: AppSpacing.md),
              _PlusFeature(
                icon: Icons.palette_outlined,
                text: 'Premium worlds',
                active: isPlus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlusFeature extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool active;

  const _PlusFeature({
    required this.icon,
    required this.text,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: active
                ? AppColors.background.withValues(
                    alpha: 0.8,
                  )
                : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.microcopy.copyWith(
                color: active
                    ? AppColors.background.withValues(
                        alpha: 0.8,
                      )
                    : AppColors.textMuted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// APPEARANCE
// ─────────────────────────────────────────────

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  static const _options = [
    (
      ThemeMode.system,
      Icons.brightness_auto_rounded,
      'System',
    ),
    (
      ThemeMode.light,
      Icons.light_mode_outlined,
      'Light',
    ),
    (
      ThemeMode.dark,
      Icons.dark_mode_outlined,
      'Dark',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadii.xl,
        ),
        border: Border.all(
          color: AppColors.dividerFaint,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.smd,
              AppSpacing.sm,
              AppSpacing.smd,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Appearance',
                  style: AppTextStyles.bodyEmphasis,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Row(
            children: [
              for (final (
                mode,
                icon,
                label
              ) in _options)
                Expanded(
                  child: _AppearanceOption(
                    mode: mode,
                    icon: icon,
                    label: label,
                    selected: controller.mode == mode,
                    onTap: () => controller.setMode(mode),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  final ThemeMode mode;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AppearanceOption({
    required this.mode,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          AppRadii.lg,
        ),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? AppColors.accentGradient
                : null,
            color: selected
                ? null
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              AppRadii.lg,
            ),
            boxShadow: selected
                ? AppShadows.accentGlowSoft
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 19,
                color: selected
                    ? AppColors.background
                    : AppColors.textMuted,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: AppTextStyles.microcopy.copyWith(
                  color: selected
                      ? AppColors.background
                      : AppColors.textMuted,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BIOMETRIC
// ─────────────────────────────────────────────

class _BiometricSection extends StatefulWidget {
  const _BiometricSection();

  @override
  State<_BiometricSection> createState() =>
      _BiometricSectionState();
}

class _BiometricSectionState
    extends State<_BiometricSection> {
  bool? _available;
  bool _enabled = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _load(),
    );
  }

  Future<void> _load() async {
    final biometrics =
        context.read<AppState>().biometrics;

    final available =
        await biometrics.isAvailable;

    final enabled =
        await biometrics.isEnabled;

    if (!mounted) return;

    setState(() {
      _available = available;
      _enabled = enabled;
    });
  }

  Future<void> _toggle(bool value) async {
    final biometrics =
        context.read<AppState>().biometrics;

    setState(() => _busy = true);

    if (value) {
      final confirmed =
          await biometrics.authenticate(
        reason:
            'Enable biometric unlock for VEYRA',
      );

      if (confirmed) {
        await biometrics.setEnabled(true);

        if (mounted) {
          setState(() => _enabled = true);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't verify — biometric unlock wasn't enabled.",
            ),
          ),
        );
      }
    } else {
      await biometrics.setEnabled(false);

      if (mounted) {
        setState(() => _enabled = false);
      }
    }

    if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final available = _available;

    if (available == false) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadii.xl,
        ),
        border: Border.all(
          color: _enabled
              ? AppColors.accent.withValues(
                  alpha: 0.35,
                )
              : AppColors.dividerFaint,
        ),
        boxShadow: _enabled
            ? AppShadows.accentGlowSoft
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _enabled
                  ? AppColors.accent.withValues(
                      alpha: 0.12,
                    )
                  : AppColors.elevated,
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              size: 21,
              color: _enabled
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
          ),

          const SizedBox(width: AppSpacing.smd),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometric unlock',
                  style: AppTextStyles.bodyEmphasis,
                ),
                const SizedBox(height: 3),
                Text(
                  _enabled
                      ? 'Your companion is protected'
                      : 'Use Face ID or fingerprint',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          if (_busy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          else
            Switch(
              value: _enabled,
              onChanged:
                  available == null ? null : _toggle,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SETTINGS ROW
// ─────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final bool danger;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.description,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final iconColor = danger
        ? AppColors.danger
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadii.xl,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(
            AppRadii.xl,
          ),
          onTap: onTap ??
              () => ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content: Text(
                    '$label settings are coming soon.',
                  ),
                ),
              ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.smd,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppRadii.xl,
              ),
              border: Border.all(
                color: danger
                    ? AppColors.danger.withValues(
                        alpha: 0.15,
                      )
                    : AppColors.dividerFaint,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: danger
                        ? AppColors.danger.withValues(
                            alpha: 0.08,
                          )
                        : AppColors.elevated,
                    borderRadius:
                        BorderRadius.circular(
                      AppRadii.md,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: iconColor,
                  ),
                ),

                const SizedBox(width: AppSpacing.smd),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.bodyEmphasis
                            .copyWith(
                          color: danger
                              ? AppColors.danger
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          description!,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ),

                if (!danger)
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}