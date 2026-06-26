import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/services/speech/speech_recognition_service.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/mic_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../stats/domain/usecases/add_practice_time.dart';
import '../../../stats/domain/usecases/record_activity_completed.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_choice.dart';
import '../controllers/story_controller.dart';

/// Plays one interactive [Story], scene by scene.
class StoryScreen extends StatelessWidget {
  /// Creates a [StoryScreen] for [story].
  const StoryScreen({required this.story, super.key});

  /// The story to play.
  final Story story;

  @override
  Widget build(BuildContext context) {
    final String userId = context.read<AuthController>().user?.id ?? 'guest';
    return ChangeNotifierProvider<StoryController>(
      create: (_) => StoryController(
        story: story,
        userId: userId,
        tts: sl<TtsService>(),
        speech: sl<SpeechRecognitionService>(),
        recordStory: sl<RecordStoryCompleted>(),
        addPracticeTime: sl<AddPracticeTime>(),
      )..init(),
      child: _StoryView(title: story.title),
    );
  }
}

class _StoryView extends StatefulWidget {
  const _StoryView({required this.title});

  final String title;

  @override
  State<_StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<_StoryView> {
  late final StoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<StoryController>();
  }

  @override
  void dispose() {
    _controller.saveSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StoryController c = context.watch<StoryController>();
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Text(c.node.emoji, style: const TextStyle(fontSize: 88)),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(c.node.narrationItalian,
                                style: text.headlineSmall,
                                textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.sm),
                            Text(c.node.narrationEnglish,
                                style: text.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic),
                                textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton.icon(
                              onPressed: c.hear,
                              icon: const Icon(Icons.volume_up_rounded),
                              label: const Text('Hear it'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (c.isEnding)
                PrimaryButton(
                  label: 'The End — Done',
                  icon: Icons.check_rounded,
                  onPressed: () => context.pop(),
                )
              else
                _Choices(controller: c),
            ],
          ),
        ),
      ),
    );
  }
}

class _Choices extends StatelessWidget {
  const _Choices({required this.controller});

  final StoryController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (controller.listening)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              controller.partialTranscript.isEmpty
                  ? '🎤 Listening…'
                  : '🎤 ${controller.partialTranscript}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
          ),
        for (final StoryChoice choice in controller.node.choices)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OutlinedButton(
              onPressed: () => controller.choose(choice),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
              child: Text(choice.label),
            ),
          ),
        if (controller.speechAvailable)
          Center(
            child: MicButton(
              listening: controller.listening,
              enabled: true,
              onTap: controller.toggleListening,
            ),
          ),
      ],
    );
  }
}
