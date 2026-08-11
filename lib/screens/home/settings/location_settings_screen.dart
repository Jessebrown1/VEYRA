import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/api_client.dart';
import '../../../services/location_service.dart';
import '../../../state/app_state.dart';
import '../../../state/theme_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_effects.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  final _locationService = LocationService();
  Map<String, dynamic>? _settings;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final settings = await context.read<AppState>().settingsApi.getLocationSettings();
    if (!mounted) return;
    setState(() => _settings = settings);
  }

  Future<void> _toggleEnabled(bool value) async {
    setState(() => _busy = true);
    try {
      if (value) {
        final result = await _locationService.requestPermission();
        if (result != LocationPermissionResult.granted) {
          if (!mounted) return;
          final message = result == LocationPermissionResult.deniedForever
              ? "Location access is blocked — enable it from your device's system settings."
              : 'Location permission was not granted.';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          setState(() => _busy = false);
          return;
        }
      }
      final updated = await context.read<AppState>().settingsApi.updateLocationSettings(
            enabled: value,
            permissionType: value ? 'approximate' : 'none',
          );
      if (!mounted) return;
      setState(() => _settings = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ApiClient.toApiException(e).message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final settings = _settings;
    final enabled = settings?['enabled'] as bool? ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Location')),
      body: settings == null
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: AppColors.dividerFaint),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Use my location', style: AppTextStyles.bodyEmphasis),
                            const SizedBox(height: 2),
                            Text(
                              'Only an approximate area is ever stored — never exact coordinates.',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Switch(value: enabled, onChanged: _busy ? null : _toggleEnabled),
                    ],
                  ),
                ),
                if (enabled) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Permission: ${settings['permissionType'] ?? 'approximate'}',
                    style: AppTextStyles.caption,
                  ),
                  if ((settings['lastArea'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text('Last known area: ${settings['lastArea']}', style: AppTextStyles.caption),
                  ],
                ],
              ],
            ),
    );
  }
}
