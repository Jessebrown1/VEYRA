import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../state/theme_controller.dart';
import '../../models/chat_message_entry.dart';
import '../../services/api_client.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final List<ChatMessageEntry> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  bool _sending = false;

  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  Future<void> _loadMessages() async {
    final appState = context.read<AppState>();
    final conversationId = appState.conversationId;

    if (conversationId == null) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    try {
      final messages =
          await appState.conversationApi.listMessages(conversationId);

      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
        _loading = false;
      });

      _scrollToEnd();
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _send() async {
    final appState = context.read<AppState>();
    final conversationId = appState.conversationId;
    final text = _inputController.text.trim();

    if (text.isEmpty || conversationId == null || _sending) {
      return;
    }

    setState(() {
      _messages.add(
        ChatMessageEntry(
          id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
          sender: 'user',
          content: text,
          createdAt: DateTime.now(),
        ),
      );

      _inputController.clear();
      _sending = true;
    });

    _scrollToEnd();

    try {
      final reply =
          await appState.conversationApi.postMessage(conversationId, text);

      if (!mounted) return;

      setState(() {
        _messages.add(reply);
        _sending = false;
      });

      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;

      final message = ApiClient.toApiException(e).message;

      setState(() => _sending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _voiceComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice conversations are coming soon.'),
      ),
    );
  }

  void _cameraComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing photos is coming soon.'),
      ),
    );
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final appState = context.watch<AppState>();
    final companion = appState.companion!;
    final wallpaperId = companion.wallpaperId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---------------------------------------------------------------
          // WALLPAPER
          // ---------------------------------------------------------------

          if (wallpaperId != null) ...[
            SvgPicture.asset(
              'assets/wallpapers/$wallpaperId',
              fit: BoxFit.cover,
            ),
            Container(
              color: AppColors.background.withValues(alpha: 0.62),
            ),
          ],

          // ---------------------------------------------------------------
          // FUTURISTIC AMBIENT LIGHT
          // ---------------------------------------------------------------

          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, child) {
              final value = _ambientController.value;

              return IgnorePointer(
                child: Stack(
                  children: [
                    Positioned(
                      top: 30 + (value * 25),
                      right: -120,
                      child: const _AmbientOrb(
                        size: 220,
                        opacity: 0.08,
                      ),
                    ),
                    Positioned(
                      top: 260 - (value * 20),
                      left: -150,
                      child: const _AmbientOrb(
                        size: 240,
                        opacity: 0.055,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ---------------------------------------------------------------
          // MAIN CONTENT
          // ---------------------------------------------------------------

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Small header only.
                _ChatHeader(
                  companionName: companion.name,
                ),

                // Chat gets the majority of the screen.
                Expanded(
                  child: _loading
                      ? const _AiLoadingState()
                      : _messages.isEmpty
                          ? _EmptyConversation(
                              companionName: companion.name,
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.screenPadding,
                                AppSpacing.sm,
                                AppSpacing.screenPadding,
                                AppSpacing.md,
                              ),
                              itemCount:
                                  _messages.length + (_sending ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _messages.length) {
                                  return _TypingBubble(
                                    companionName: companion.name,
                                  );
                                }

                                return _MessageBubble(
                                  message: _messages[index],
                                  companionName: companion.name,
                                );
                              },
                            ),
                ),

                // Composer.
                _Composer(
                  controller: _inputController,
                  companionName: companion.name,
                  sending: _sending,
                  onCamera: _cameraComingSoon,
                  onVoice: _voiceComingSoon,
                  onSend: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// CHAT HEADER
// ==========================================================================

class _ChatHeader extends StatelessWidget {
  final String companionName;

  const _ChatHeader({
    required this.companionName,
  });

  String _initials(String name) {
    final cleaned = name.trim();

    if (cleaned.isEmpty) {
      return 'V';
    }

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }

    return parts.first.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.70),
        border: Border(
          bottom: BorderSide(
            color: AppColors.dividerFaint.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: Row(
        children: [
          // Companion initials.
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.20),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: const EdgeInsets.all(1.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials(companionName),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Name.
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companionName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.45),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Connected',
                      style: AppTextStyles.microcopy.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subtle futuristic control.
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withValues(alpha: 0.65),
              border: Border.all(
                color: AppColors.dividerFaint,
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 17,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// AMBIENT ORB
// ==========================================================================

class _AmbientOrb extends StatelessWidget {
  final double size;
  final double opacity;

  const _AmbientOrb({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.glow(
          AppColors.accent,
          opacity: opacity,
        ),
      ),
    );
  }
}

// ==========================================================================
// LOADING
// ==========================================================================

class _AiLoadingState extends StatelessWidget {
  const _AiLoadingState();

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: AppShadows.accentGlowSoft,
            ),
            padding: const EdgeInsets.all(1.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Opening your space',
            style: AppTextStyles.bodyEmphasis.copyWith(
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Connecting securely…',
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// EMPTY CONVERSATION
// ==========================================================================

class _EmptyConversation extends StatelessWidget {
  final String companionName;

  const _EmptyConversation({
    required this.companionName,
  });

  String _initials(String name) {
    final cleaned = name.trim();

    if (cleaned.isEmpty) {
      return 'V';
    }

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }

    return parts.first.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Initials instead of AI icon.
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.accentGradient,
                boxShadow: AppShadows.accentGlowSoft,
              ),
              padding: const EdgeInsets.all(1.5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(companionName),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              'Your space is ready',
              textAlign: TextAlign.center,
              style: AppTextStyles.headline.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '$companionName is here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 12,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Private conversation',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                      fontSize: 9.5,
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

// ==========================================================================
// MESSAGE
// ==========================================================================

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntry message;
  final String companionName;

  const _MessageBubble({
    required this.message,
    required this.companionName,
  });

  String _initials(String name) {
    final cleaned = name.trim();

    if (cleaned.isEmpty) {
      return 'V';
    }

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }

    return parts.first.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    final fromCompanion = message.isFromCompanion;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            fromCompanion ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (fromCompanion) ...[
            _MiniCompanionAvatar(
              initials: _initials(companionName),
            ),
            const SizedBox(width: 7),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: fromCompanion
                    ? AppColors.cardGradient
                    : AppColors.accentGradient,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(17),
                  topRight: const Radius.circular(17),
                  bottomLeft: Radius.circular(
                    fromCompanion ? 4 : 17,
                  ),
                  bottomRight: Radius.circular(
                    fromCompanion ? 17 : 4,
                  ),
                ),
                border: fromCompanion
                    ? Border.all(
                        color: AppColors.dividerFaint,
                      )
                    : null,
                boxShadow: fromCompanion
                    ? AppShadows.soft
                    : AppShadows.accentGlowSoft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyEmphasis.copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: fromCompanion
                          ? AppColors.textPrimary
                          : AppColors.background,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _formatTime(message.createdAt),
                      style: AppTextStyles.microcopy.copyWith(
                        fontSize: 8,
                        color: fromCompanion
                            ? AppColors.textMuted
                            : AppColors.background.withValues(
                                alpha: 0.60,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';

    return '${hour == 0 ? 12 : hour}:$minute $suffix';
  }
}

// ==========================================================================
// COMPANION AVATAR
// ==========================================================================

class _MiniCompanionAvatar extends StatelessWidget {
  final String initials;

  const _MiniCompanionAvatar({
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.accentGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.16),
            blurRadius: 9,
          ),
        ],
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.background,
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// TYPING
// ==========================================================================

class _TypingBubble extends StatefulWidget {
  final String companionName;

  const _TypingBubble({
    required this.companionName,
  });

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _MiniCompanionAvatar(
            initials: 'V',
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
                bottomRight: Radius.circular(17),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: AppColors.dividerFaint,
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (index) {
                      final offset =
                          ((_controller.value + index * 0.2) % 1.0);

                      final opacity = 0.35 +
                          ((1 - (offset - 0.5).abs() * 2)
                                  .clamp(0.0, 1.0) *
                              0.65);

                      return Container(
                        margin: EdgeInsets.only(
                          right: index == 2 ? 0 : 4,
                        ),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withValues(
                            alpha: opacity,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// COMPOSER
// ==========================================================================

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final String companionName;
  final bool sending;
  final VoidCallback onCamera;
  final VoidCallback onVoice;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.companionName,
    required this.sending,
    required this.onCamera,
    required this.onVoice,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        10,
        7,
        10,
        7,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.94),
        border: Border(
          top: BorderSide(
            color: AppColors.dividerFaint.withValues(alpha: 0.75),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 50,
            maxHeight: 120,
          ),
          padding: const EdgeInsets.only(
            left: 3,
            right: 4,
            top: 3,
            bottom: 3,
          ),
          decoration: BoxDecoration(
            color: AppColors.elevated.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: AppColors.dividerFaint,
            ),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ComposerIcon(
                icon: Icons.add_rounded,
                onTap: onCamera,
              ),

              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    fontSize: 13,
                    height: 1.3,
                  ),
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    hintText: 'Message $companionName…',
                    hintStyle: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),

              _ComposerIcon(
                icon: Icons.graphic_eq_rounded,
                onTap: onVoice,
              ),

              const SizedBox(width: 2),

              _SendButton(
                sending: sending,
                onTap: onSend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// COMPOSER ICON
// ==========================================================================

class _ComposerIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ComposerIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      splashRadius: 19,
      constraints: const BoxConstraints(
        minWidth: 38,
        minHeight: 38,
      ),
      icon: Icon(
        icon,
        size: 20,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// ==========================================================================
// SEND BUTTON
// ==========================================================================

class _SendButton extends StatelessWidget {
  final bool sending;
  final VoidCallback onTap;

  const _SendButton({
    required this.sending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: sending ? null : AppColors.accentGradient,
        color: sending ? AppColors.divider : null,
        boxShadow: sending
            ? null
            : [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.24),
                  blurRadius: 13,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: IconButton(
        onPressed: sending ? null : onTap,
        splashRadius: 20,
        padding: EdgeInsets.zero,
        icon: sending
            ? SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: AppColors.textMuted,
                ),
              )
            : Icon(
                Icons.arrow_upward_rounded,
                size: 19,
                color: AppColors.background,
              ),
      ),
    );
  }
}