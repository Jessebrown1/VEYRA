import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/api_client.dart';
import '../../../state/app_state.dart';
import '../../../state/theme_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_effects.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  Map<String, dynamic>? _settings;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final settings = await context.read<AppState>().settingsApi.getNotificationSettings();
    if (!mounted) return;
    setState(() => _settings = settings);
  }

  Future<void> _patch(Map<String, dynamic> changes) async {
    final previous = _settings;
    setState(() {
      _settings = {...?_settings, ...changes};
      _saving = true;
    });
    try {
      final updated = await context.read<AppState>().settingsApi.updateNotificationSettings(
            enabled: changes['enabled'] as bool?,
            companionCheckins: changes['companionCheckins'] as bool?,
            sleepReminders: changes['sleepReminders'] as bool?,
            quietHoursEnabled: changes['quietHoursEnabled'] as bool?,
            quietStart: changes['quietStart'] as String?,
            quietEnd: changes['quietEnd'] as String?,
            frequency: changes['frequency'] as String?,
          );
      if (!mounted) return;
      setState(() => _settings = updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _settings = previous);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ApiClient.toApiException(e).message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime(String field, String current) async {
    final parts = current.split(':');
    final initial = TimeOfDay(hour: int.tryParse(parts[0]) ?? 22, minute: int.tryParse(parts[1]) ?? 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await _patch({field: formatted});
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final settings = _settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifications')),
      body: settings == null
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                _ToggleRow(
                  label: 'Notifications',
                  subtitle: 'Master switch for everything below.',
                  value: settings['enabled'] as bool? ?? true,
                  onChanged: _saving ? null : (v) => _patch({'enabled': v}),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ToggleRow(
                  label: 'Check-ins',
                  subtitle: 'Occasional messages when you\'ve been away a while.',
                  value: settings['companionCheckins'] as bool? ?? true,
                  onChanged: _saving ? null : (v) => _patch({'companionCheckins': v}),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ToggleRow(
                  label: 'Sleep reminders',
                  subtitle: 'A gentle nudge if it\'s late and you\'re still chatting.',
                  value: settings['sleepReminders'] as bool? ?? true,
                  onChanged: _saving ? null : (v) => _patch({'sleepReminders': v}),
                ),
                const SizedBox(height: AppSpacing.lg),
                Divider(color: AppColors.divider),
                const SizedBox(height: AppSpacing.lg),
                _ToggleRow(
                  label: 'Quiet hours',
                  subtitle: 'Mute notifications during a set time range.',
                  value: settings['quietHoursEnabled'] as bool? ?? false,
                  onChanged: _saving ? null : (v) => _patch({'quietHoursEnabled': v}),
                ),
                if (settings['quietHoursEnabled'] == true) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeField(
                          label: 'From',
                          value: settings['quietStart'] as String? ?? '22:00',
                          onTap: () => _pickTime('quietStart', settings['quietStart'] as String? ?? '22:00'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _TimeField(
                          label: 'Until',
                          value: settings['quietEnd'] as String? ?? '08:00',
                          onTap: () => _pickTime('quietEnd', settings['quietEnd'] as String? ?? '08:00'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Divider(color: AppColors.divider),
                const SizedBox(height: AppSpacing.lg),
                Text('FREQUENCY', style: AppTextStyles.microcopy),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    for (final option in const ['low', 'normal', 'high'])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: _FrequencyChip(
                            label: option,
                            selected: (settings['frequency'] as String? ?? 'normal') == option,
                            onTap: _saving ? null : () => _patch({'frequency': option}),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _ToggleRow({required this.label, required this.subtitle, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(label, style: AppTextStyles.bodyEmphasis),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.smd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.dividerFaint),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(value, style: AppTextStyles.bodyEmphasis),
          ],
        ),
      ),
    );
  }
}

class _FrequencyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _FrequencyChip({required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withValues(alpha: 0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: selected ? AppColors.accent : AppColors.dividerFaint),
        ),
        child: Text(
          label[0].toUpperCase() + label.substring(1),
          style: AppTextStyles.bodyEmphasis.copyWith(color: selected ? AppColors.accent : AppColors.textSecondary),
        ),
      ),
    );
  }
}
