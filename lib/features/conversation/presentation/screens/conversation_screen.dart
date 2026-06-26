import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/services/speech/speech_recognition_service.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/mic_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../stats/domain/usecases/add_practice_time.dart';
import '../../../stats/domain/usecases/record_activity_completed.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation_script.dart';
import '../../domain/services/ai_tutor_engine.dart';
import '../controllers/conversation_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/suggestion_chips.dart';

/// The chat screen for one conversation [script].
///
/// Creates a [ConversationController] (wired to the tutor engine + speech
/// services from the locator) and kicks off the opening turn.
class ConversationScreen extends StatelessWidget {
  /// Creates a [ConversationScreen] for [script].
  const ConversationScreen({required this.script, super.key});

  /// The conversation to play.
  final ConversationScript script;

  @override
  Widget build(BuildContext context) {
    final String userId = context.read<AuthController>().user?.id ?? 'guest';
    return ChangeNotifierProvider<ConversationController>(
      create: (_) => ConversationController(
        script: script,
        userId: userId,
        engine: sl<AiTutorEngine>(),
        tts: sl<TtsService>(),
        speech: sl<SpeechRecognitionService>(),
        recordConversation: sl<RecordConversationCompleted>(),
        addPracticeTime: sl<AddPracticeTime>(),
      )..start(),
      child: _ConversationView(script: script),
    );
  }
}

class _ConversationView extends StatefulWidget {
  const _ConversationView({required this.script});

  final ConversationScript script;

  @override
  State<_ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<_ConversationView> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendTyped(ConversationController controller) {
    final String text = _input.text;
    _input.clear();
    controller.submit(text);
  }

  @override
  Widget build(BuildContext context) {
    final ConversationController controller =
        context.watch<ConversationController>();
    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(widget.script.characterEmoji,
                style: const TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.sm),
            Text(widget.script.characterName),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: controller.messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final ChatMessage message = controller.messages[index];
                  return ChatBubble(
                    message: message,
                    characterEmoji: widget.script.characterEmoji,
                    onReplay: () => controller.replay(message),
                  );
                },
              ),
            ),
            if (controller.finished)
              _FinishedBar(onDone: () => context.pop())
            else
              _InputArea(
                controller: controller,
                input: _input,
                onSend: () => _sendTyped(controller),
              ),
          ],
        ),
      ),
    );
  }
}

/// The reply controls: live transcript, suggestion chips, text field, and mic.
class _InputArea extends StatelessWidget {
  const _InputArea({
    required this.controller,
    required this.input,
    required this.onSend,
  });

  final ConversationController controller;
  final TextEditingController input;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool enabled = !controller.busy;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (controller.listening)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                controller.partialTranscript.isEmpty
                    ? '🎤 Listening…'
                    : '🎤 ${controller.partialTranscript}',
                style: text.bodyMedium?.copyWith(color: AppColors.secondary),
              ),
            ),
          SuggestionChips(
            suggestions: controller.suggestions,
            enabled: enabled,
            onTap: controller.submit,
          ),
          if (controller.suggestions.isNotEmpty)
            const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: input,
                  enabled: enabled,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: const InputDecoration(
                    hintText: 'Type your answer…',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: enabled ? onSend : null,
                icon: const Icon(Icons.send_rounded),
              ),
              if (controller.speechAvailable) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                MicButton(
                  listening: controller.listening,
                  enabled: enabled,
                  onTap: controller.toggleListening,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Shown when the conversation has ended.
class _FinishedBar extends StatelessWidget {
  const _FinishedBar({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('🎉 Great conversation!', style: text.titleLarge),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: onDone,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
