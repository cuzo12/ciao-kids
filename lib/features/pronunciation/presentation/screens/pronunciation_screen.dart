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
import '../../../stats/domain/usecases/record_pronunciation_result.dart';
import '../../data/pronunciation_word_bank.dart';
import '../controllers/pronunciation_controller.dart';

/// The Pronunciation Coach: hear a word, say it, and get an encouraging score.
class PronunciationScreen extends StatelessWidget {
  /// Creates the [PronunciationScreen].
  const PronunciationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = context.read<AuthController>().user?.id ?? 'guest';
    return ChangeNotifierProvider<PronunciationController>(
      create: (_) => PronunciationController(
        words: PronunciationWordBank.words,
        userId: userId,
        tts: sl<TtsService>(),
        speech: sl<SpeechRecognitionService>(),
        recordResult: sl<RecordPronunciationResult>(),
        addPracticeTime: sl<AddPracticeTime>(),
      )..init(),
      child: const _PronView(),
    );
  }
}

class _PronView extends StatefulWidget {
  const _PronView();

  @override
  State<_PronView> createState() => _PronViewState();
}

class _PronViewState extends State<_PronView> {
  late final PronunciationController _controller;
  final TextEditingController _typed = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = context.read<PronunciationController>();
  }

  @override
  void dispose() {
    // Persist time spent before the controller is torn down (fire-and-forget).
    _controller.saveSession();
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PronunciationController c = context.watch<PronunciationController>();
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pronunciation Coach')),
      body: SafeArea(
        child: c.finished
            ? _Done(onDone: () => context.pop())
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                      child: LinearProgressIndicator(
                        value: c.progress,
                        minHeight: 10,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Word ${c.position} of ${c.total}',
                        style: text.labelMedium),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(child: _WordCard(controller: c)),
                    _Feedback(controller: c),
                    const SizedBox(height: AppSpacing.md),
                    _Controls(controller: c, typed: _typed),
                  ],
                ),
              ),
      ),
    );
  }
}

/// The word being practiced, with syllable chips and listen buttons.
class _WordCard extends StatelessWidget {
  const _WordCard({required this.controller});

  final PronunciationController controller;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<String> syllables = controller.current.pronunciation.split('-');
    // Emphasize syllables after a missed attempt to guide the next try.
    final bool emphasize = controller.status == PronStatus.scored &&
        !controller.passed;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(controller.current.emoji,
                style: const TextStyle(fontSize: 72)),
            const SizedBox(height: AppSpacing.sm),
            Text(controller.current.italian, style: text.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(controller.current.english, style: text.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: <Widget>[
                for (final String syllable in syllables)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: (emphasize ? AppColors.accent : AppColors.tertiary)
                          .withValues(alpha: emphasize ? 0.3 : 0.15),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(syllable,
                        style: text.titleMedium?.copyWith(
                          color: emphasize
                              ? AppColors.secondaryDark
                              : AppColors.tertiary,
                        )),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: controller.hear,
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('Hear it'),
                ),
                const SizedBox(width: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: controller.hearSlow,
                  icon: const Icon(Icons.slow_motion_video_rounded),
                  label: const Text('Slowly'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Encouraging score feedback after an attempt.
class _Feedback extends StatelessWidget {
  const _Feedback({required this.controller});

  final PronunciationController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.status != PronStatus.scored) {
      return const SizedBox.shrink();
    }
    final TextTheme text = Theme.of(context).textTheme;
    final bool passed = controller.passed;
    final Color color = passed ? AppColors.success : AppColors.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: <Widget>[
          Text(
            passed ? 'Bravo! ${controller.lastScore}%' : 'Almost! ${controller.lastScore}%',
            style: text.titleLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            passed
                ? 'Great pronunciation! 🎉'
                : "Let's try that together — listen and repeat.",
            style: text.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text('I heard: "${controller.lastTranscript}"',
              style: text.labelMedium),
        ],
      ),
    );
  }
}

/// Mic / typed input plus the Next button.
class _Controls extends StatelessWidget {
  const _Controls({required this.controller, required this.typed});

  final PronunciationController controller;
  final TextEditingController typed;

  @override
  Widget build(BuildContext context) {
    final bool scored = controller.status == PronStatus.scored;

    return Column(
      children: <Widget>[
        if (controller.speechAvailable)
          MicButton(
            listening: controller.status == PronStatus.listening,
            enabled: true,
            onTap: () => controller.status == PronStatus.listening
                ? controller.stopListening()
                : controller.listen(),
          )
        else
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: typed,
                  decoration:
                      const InputDecoration(hintText: 'Type the word…'),
                  onSubmitted: (String v) {
                    controller.submitTyped(v);
                    typed.clear();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: () {
                  controller.submitTyped(typed.text);
                  typed.clear();
                },
                icon: const Icon(Icons.check_rounded),
              ),
            ],
          ),
        if (scored && !controller.passed) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: controller.acceptManually,
            icon: const Icon(Icons.thumb_up_alt_outlined),
            label: const Text('I said it right ✓'),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: scored
              ? (controller.position == controller.total ? 'Finish' : 'Next word')
              : 'Skip',
          onPressed: controller.next,
        ),
      ],
    );
  }
}

/// Drill-complete view.
class _Done extends StatelessWidget {
  const _Done({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('🗣️', style: TextStyle(fontSize: 72)),
          const SizedBox(height: AppSpacing.md),
          Text('Great practice!', style: text.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text('Your pronunciation is getting stronger.',
              style: text.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton(onPressed: onDone, child: const Text('Done')),
          ),
        ],
      ),
    );
  }
}
