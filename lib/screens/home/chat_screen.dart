import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
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

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessageEntry> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMessages());
  }

  Future<void> _loadMessages() async {
    final appState = context.read<AppState>();
    final conversationId = appState.conversationId;
    if (conversationId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final messages = await appState.conversationApi.listMessages(conversationId);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
        _loading = false;
      });
      _scrollToEnd();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final appState = context.read<AppState>();
    final conversationId = appState.conversationId;
    final text = _inputController.text.trim();
    if (text.isEmpty || conversationId == null || _sending) return;

    setState(() {
      _messages.add(ChatMessageEntry(
        id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
        sender: 'user',
        content: text,
        createdAt: DateTime.now(),
      ));
      _inputController.clear();
      _sending = true;
    });
    _scrollToEnd();

    try {
      final reply = await appState.conversationApi.postMessage(conversationId, text);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _voiceComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice conversations are coming soon.')),
    );
  }

  void _cameraComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing photos is coming soon.')),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final companion = appState.companion!;
    final wallpaperId = companion.wallpaperId;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: wallpaperId != null,
      appBar: AppBar(
        backgroundColor: wallpaperId != null ? Colors.transparent : AppColors.background,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.accentGradient),
              child: CircleAvatar(
                backgroundColor: AppColors.surface,
                child: Text(
                  companion.name.isNotEmpty ? companion.name[0].toUpperCase() : '?',
                  style: AppTextStyles.bodyEmphasis,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(companion.name, style: AppTextStyles.title),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (wallpaperId != null) ...[
            SvgPicture.asset('assets/wallpapers/$wallpaperId', fit: BoxFit.cover),
            Container(color: AppColors.background.withValues(alpha: 0.4)),
          ],
          SafeArea(
            child: Column(
              children: [
                if (wallpaperId != null) SizedBox(height: kToolbarHeight),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPadding,
                            vertical: AppSpacing.md,
                          ),
                          itemCount: _messages.length + (_sending ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              return _TypingBubble(companionName: companion.name);
                            }
                            final message = _messages[index];
                            return _MessageBubble(message: message);
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: AppColors.dividerFaint),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _cameraComingSoon,
                          icon: const Icon(Icons.camera_alt_outlined, color: AppColors.textSecondary),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            textCapitalization: TextCapitalization.sentences,
                            style: AppTextStyles.bodyEmphasis,
                            decoration: InputDecoration(
                              hintText: 'Message ${companion.name}',
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        IconButton(
                          onPressed: _voiceComingSoon,
                          icon: const Icon(Icons.mic_off_outlined, color: AppColors.textMuted),
                          tooltip: 'Voice — coming soon',
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _sending ? null : AppColors.accentGradient,
                            color: _sending ? AppColors.divider : null,
                          ),
                          child: IconButton(
                            onPressed: _sending ? null : _send,
                            icon: Icon(
                              Icons.arrow_upward_rounded,
                              color: _sending ? AppColors.textMuted : AppColors.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntry message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final fromCompanion = message.isFromCompanion;
    return Align(
      alignment: fromCompanion ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: fromCompanion ? AppColors.cardGradient : AppColors.accentGradient,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadii.md),
            topRight: const Radius.circular(AppRadii.md),
            bottomLeft: Radius.circular(fromCompanion ? 4 : AppRadii.md),
            bottomRight: Radius.circular(fromCompanion ? AppRadii.md : 4),
          ),
          border: fromCompanion ? Border.all(color: AppColors.dividerFaint) : null,
        ),
        child: Text(
          message.content,
          style: fromCompanion
              ? AppTextStyles.bodyEmphasis
              : AppTextStyles.bodyEmphasis.copyWith(color: AppColors.background),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final String companionName;

  const _TypingBubble({required this.companionName});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          border: Border.all(color: AppColors.dividerFaint),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadii.md),
            topRight: Radius.circular(AppRadii.md),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(AppRadii.md),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('$companionName is typing…', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
