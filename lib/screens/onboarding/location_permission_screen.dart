import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/location_service.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import 'notification_permission_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  final _locationService = LocationService();
  bool _requesting = false;

  Future<void> _continueTo({required bool granted}) async {
    context.read<OnboardingController>().setLocationEnabled(granted);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationPermissionScreen()),
    );
  }

  Future<void> _allow() async {
    setState(() => _requesting = true);
    final result = await _locationService.requestPermission();
    if (!mounted) return;
    setState(() => _requesting = false);
    await _continueTo(granted: result == LocationPermissionResult.granted);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 7,
      totalSteps: 8,
      title: 'Let me know where you are.',
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
              child: const Icon(Icons.location_on_outlined, size: 28, color: AppColors.background),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'With your permission, I can use your location to make conversations '
              'and suggestions more relevant.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'This is always optional and you can change it later in Settings.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
      footer: Column(
        children: [
          PrimaryButton(
            label: _requesting ? 'Requesting…' : 'Allow Location',
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
