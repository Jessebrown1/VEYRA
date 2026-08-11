import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/theme_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_text_styles.dart';
import 'chat_screen.dart';
import 'companion_screen.dart';
import 'memories_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    _Tab('Home', Icons.chat_bubble_outline, Icons.chat_bubble, ChatScreen()),
    _Tab('Memories', Icons.auto_awesome_outlined, Icons.auto_awesome, MemoriesScreen()),
    _Tab('Companion', Icons.favorite_outline, Icons.favorite, CompanionScreen()),
    _Tab('Settings', Icons.settings_outlined, Icons.settings, SettingsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: _tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: AppColors.dividerFaint),
              boxShadow: AppShadows.soft,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / _tabs.length;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      left: tabWidth * _index,
                      top: 10,
                      bottom: 10,
                      width: tabWidth,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(_tabs.length, (index) {
                        final tab = _tabs[index];
                        final isActive = index == _index;
                        return Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            onTap: () => setState(() => _index = index),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isActive ? tab.activeIcon : tab.icon,
                                  color: isActive ? AppColors.accent : AppColors.textMuted,
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tab.label,
                                  style: AppTextStyles.microcopy.copyWith(
                                    color: isActive ? AppColors.accent : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;

  const _Tab(this.label, this.icon, this.activeIcon, this.screen);
}
