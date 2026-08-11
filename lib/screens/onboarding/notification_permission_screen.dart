import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/theme_controller.dart';
import '../../services/notification_permission_service.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import 'companion_creation_screen.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> {
  final _notificationService = NotificationPermissionService();
  bool _requesting = false;

  Future<void> _continueTo({required bool granted}) async {
    final controller = context.read<OnboardingController>();
    controller.setNotificationsEnabled(granted);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CompanionCreationScreen()),
    );
  }

  Future<void> _allow() async {
    setState(() => _requesting = true);
    final granted = await _notificationService.requestPermission();
    if (!mounted) return;
    setState(() => _requesting = false);
    await _continueTo(granted: granted);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final companionName = context.watch<OnboardingController>().companionName;

    return OnboardingScaffold(
      step: 8,
      totalSteps: 8,
      title: "Let $companionName check in on you.",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.accentGradient,
                boxShadow: AppShadows.accentGlowSoft,
              ),
              child: Icon(Icons.notifications_none, size: 28, color: AppColors.background),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "With notifications on, $companionName can reach out after a while, "
              'or gently remind you when it\'s getting late.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'You can adjust quiet hours and frequency any time in Settings.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
      footer: Column(
        children: [
          PrimaryButton(
            label: _requesting ? 'Requesting…' : 'Allow Notifications',
            enabled: !_requesting,
            onPressed: _allow,
          ),
          const SizedBox(height: AppSpacing.xs),
          SecondaryButton(
            label: 'Not Now',
            onPressed: _requesting ? null : () => _continueTo(granted: false),
          ),
        ],
      ),
    );
  }
}
