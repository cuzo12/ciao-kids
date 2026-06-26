import 'package:flutter/material.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/services/speech/tts_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/lesson_stage.dart';
import '../../../domain/entities/vocabulary_item.dart';

/// Renders a [PronunciationStage]: a "listen and repeat" list where each word
/// shows its phonetic respelling for the child to say aloud.
///
/// Real spoken audio (text-to-speech) and pronunciation scoring arrive in the
/// speech milestone; the phonetic hint is the spoken-form guide until then.
class PronunciationStageView extends StatelessWidget {
  /// Creates a [PronunciationStageView].
  const PronunciationStageView({required this.stage, super.key});

  /// The words to practice saying.
  final PronunciationStage stage;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Say each word out loud — copy the sounds! 🗣️',
          style: text.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.separated(
            itemCount: stage.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (BuildContext context, int index) =>
                _SayItRow(item: stage.items[index]),
          ),
        ),
      ],
    );
  }
}

/// One word row in the pronunciation list.
class _SayItRow extends StatelessWidget {
  const _SayItRow({required this.item});

  final VocabularyItem item;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Text(item.emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.italian, style: text.titleLarge),
                Text(
                  item.pronunciation,
                  style: text.bodyMedium?.copyWith(color: AppColors.tertiary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: AppColors.tertiary),
            tooltip: 'Hear it',
            onPressed: () => sl<TtsService>().speak(item.italian),
          ),
        ],
      ),
    );
  }
}
