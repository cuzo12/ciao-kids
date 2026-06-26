import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/speech/speech_recognition_service.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/mic_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../conversation/presentation/widgets/chat_bubble.dart';
import '../../../stats/domain/usecases/add_practice_time.dart';
import '../../../stats/domain/usecases/record_activity_completed.dart';
import '../../data/remote_tutor_service.dart';
import '../controllers/claude_chat_controller.dart';

/// Free-form chat with the live Claude tutor (when configured).
class ClaudeChatScreen extends StatelessWidget {
  /// Creates the screen for an optional [topic].
  const ClaudeChatScreen({this.topic = 'everyday Italian conversation', super.key});

  /// Loose topic used to steer the tutor.
  final String topic;

  @override
  Widget build(BuildContext context) {
    final AuthController auth = context.read<AuthController>();
    return ChangeNotifierProvider<ClaudeChatController>(
      create: (_) => ClaudeChatController(
        service: sl<RemoteTutorService>(),
        tts: sl<TtsService>(),
        speech: sl<SpeechRecognitionService>(),
        childAge: auth.user?.childAge ?? AppConstants.minChildAge,
        topic: topic,
        userId: auth.user?.id ?? 'guest',
        recordConversation: sl<RecordConversationCompleted>(),
        addPracticeTime: sl<AddPracticeTime>(),
      )..init(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  late final ClaudeChatController _controller;
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = context.read<ClaudeChatController>();
  }

  @override
  void dispose() {
    _controller.saveSession();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final String text = _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    _controller.send(text);
  }

  void _autoScroll(int count) {
    if (count == _lastCount) return;
    _lastCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ClaudeChatController c = context.watch<ClaudeChatController>();
    _autoScroll(c.messages.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat with Luca ✨')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: c.messages.length + (c.busy ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index >= c.messages.length) {
                    return const _TypingIndicator();
                  }
                  final message = c.messages[index];
                  return ChatBubble(
                    message: message,
                    characterEmoji: '👦',
                    onReplay: () => c.speak(message),
                  );
                },
              ),
            ),
            if (c.listening)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  c.partialTranscript.isEmpty
                      ? '🎤 Listening…'
                      : '🎤 ${c.partialTranscript}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.secondary),
                ),
              ),
            _InputBar(
              controller: c,
              input: _input,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.input,
    required this.onSend,
  });

  final ClaudeChatController controller;
  final TextEditingController input;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: input,
              enabled: !controller.busy,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(hintText: 'Say something…'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (controller.speechAvailable)
            MicButton(
              listening: controller.listening,
              enabled: !controller.busy,
              onTap: controller.toggleListening,
            )
          else
            IconButton.filled(
              onPressed: controller.busy ? null : onSend,
              icon: const Icon(Icons.send_rounded),
            ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          Text('👦', style: TextStyle(fontSize: 28)),
          SizedBox(width: AppSpacing.sm),
          Text('…', style: TextStyle(fontSize: 28)),
        ],
      ),
    );
  }
}
