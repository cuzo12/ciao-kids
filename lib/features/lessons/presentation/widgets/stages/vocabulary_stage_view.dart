import 'package:flutter/material.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/services/speech/tts_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/lesson_stage.dart';
import '../../../domain/entities/vocabulary_item.dart';

/// Renders a [VocabularyStage] as a swipeable deck of flashcards, one word per
/// page, with page dots and a swipe hint.
class VocabularyStageView extends StatefulWidget {
  /// Creates a [VocabularyStageView].
  const VocabularyStageView({required this.stage, super.key});

  /// The vocabulary data to display.
  final VocabularyStage stage;

  @override
  State<VocabularyStageView> createState() => _VocabularyStageViewState();
}

class _VocabularyStageViewState extends State<VocabularyStageView> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<VocabularyItem> items = widget.stage.items;
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        Text('New words — swipe to explore 👉', style: text.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (int p) => setState(() => _page = p),
            itemBuilder: (BuildContext context, int index) =>
                _Flashcard(item: items[index]),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 8,
                width: i == _page ? 22 : 8,
                decoration: BoxDecoration(
                  color: i == _page
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A single vocabulary flashcard.
class _Flashcard extends StatelessWidget {
  const _Flashcard({required this.item});

  final VocabularyItem item;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(item.emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: AppSpacing.md),
            Text(item.italian, style: text.displayMedium),
            const SizedBox(height: AppSpacing.sm),
            // Tap to hear the word spoken in Italian (on-device TTS).
            GestureDetector(
              onTap: () => sl<TtsService>().speak(item.italian),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  '🔊  ${item.pronunciation}',
                  style: text.titleMedium?.copyWith(color: AppColors.tertiary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(item.english, style: text.bodyLarge),
          ],
        ),
      ),
    );
  }
}
