import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/memory_entry.dart';
import '../../services/api_client.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

const _categoryIcons = {
  'identity': Icons.badge_outlined,
  'preferences': Icons.tune,
  'interests': Icons.star_outline,
  'relationships': Icons.people_outline,
  'goals': Icons.flag_outlined,
  'important_dates': Icons.event_outlined,
  'routines': Icons.repeat,
  'locations': Icons.place_outlined,
  'education': Icons.school_outlined,
  'work': Icons.work_outline,
  'personal_facts': Icons.info_outline,
  'conversation_context': Icons.chat_bubble_outline,
};

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  List<MemoryEntry>? _memories;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final appState = context.read<AppState>();
    try {
      final memories = await appState.memoryApi.listForCompanion(appState.companion!.id);
      if (mounted) setState(() => _memories = memories);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiClient.toApiException(e).message)),
      );
    }
  }

  Future<void> _forget(MemoryEntry memory) async {
    final appState = context.read<AppState>();
    setState(() => _memories = _memories!.where((m) => m.id != memory.id).toList());
    try {
      await appState.memoryApi.forget(memory.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiClient.toApiException(e).message)),
      );
      _load();
    }
  }

  Future<void> _edit(MemoryEntry memory) async {
    final controller = TextEditingController(text: memory.content);
    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.elevated,
        title: const Text('Edit memory'),
        content: TextField(controller: controller, maxLines: 3, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newContent == null || newContent.isEmpty || newContent == memory.content) return;

    final appState = context.read<AppState>();
    try {
      await appState.memoryApi.update(memory.id, newContent);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiClient.toApiException(e).message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final companion = context.watch<AppState>().companion!;
    final memories = _memories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Things ${companion.name} remembers')),
      body: memories == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : memories.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome_outlined, size: 40, color: AppColors.textMuted),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        "As you talk, ${companion.name} will start remembering the things "
                        'that matter to you.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.accent,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGradient,
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          border: Border.all(color: AppColors.dividerFaint),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: const BoxDecoration(
                                color: AppColors.elevatedHigh,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _categoryIcons[memory.category] ?? Icons.auto_awesome_outlined,
                                size: 16,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.smd),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _edit(memory),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memory.category.replaceAll('_', ' ').toUpperCase(),
                                      style: AppTextStyles.microcopy,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(memory.content, style: AppTextStyles.bodyEmphasis),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _forget(memory),
                              icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                              tooltip: 'Forget',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
