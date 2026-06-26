import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/lesson_stage.dart';
import '../../../domain/entities/quiz_question.dart';
import '../../controllers/lesson_player_controller.dart';

/// Renders a [QuizStage]: a scrollable list of multiple-choice questions.
///
/// Selections are recorded in the [LessonPlayerController] (the source of truth
/// for scoring). Once a question is answered it locks and reveals the correct
/// answer with gentle, encouraging feedback — never a blunt "wrong".
class QuizStageView extends StatelessWidget {
  /// Creates a [QuizStageView].
  const QuizStageView({required this.stage, super.key});

  /// The quiz data to display.
  final QuizStage stage;

  @override
  Widget build(BuildContext context) {
    final LessonPlayerController player =
        context.watch<LessonPlayerController>();

    return ListView.separated(
      itemCount: stage.questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        return _QuestionCard(
          number: index + 1,
          question: stage.questions[index],
          selected: player.answerFor(index),
          onSelect: (int option) => player.answerQuestion(index, option),
        );
      },
    );
  }
}

/// A single quiz question with its answer options.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.selected,
    required this.onSelect,
  });

  final int number;
  final QuizQuestion question;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool answered = selected != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Question $number', style: text.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(question.prompt, style: text.titleLarge),
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < question.options.length; i++)
            _OptionTile(
              label: question.options[i],
              state: _stateFor(i, answered),
              onTap: answered ? null : () => onSelect(i),
            ),
          if (answered && question.explanation != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('💡 ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(question.explanation!, style: text.bodyMedium),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  _OptionState _stateFor(int index, bool answered) {
    if (!answered) return _OptionState.idle;
    if (question.isCorrect(index)) return _OptionState.correct;
    if (index == selected) return _OptionState.wrong;
    return _OptionState.dimmed;
  }
}

/// Visual state of a single answer option after (or before) answering.
enum _OptionState { idle, correct, wrong, dimmed }

/// A single tappable answer option.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final (Color bg, Color border, IconData? icon, Color iconColor) =
        switch (state) {
      _OptionState.idle => (
          scheme.surfaceContainerHighest,
          Colors.transparent,
          null,
          Colors.transparent,
        ),
      _OptionState.correct => (
          AppColors.success.withValues(alpha: 0.18),
          AppColors.success,
          Icons.check_circle,
          AppColors.success,
        ),
      _OptionState.wrong => (
          AppColors.error.withValues(alpha: 0.15),
          AppColors.error,
          Icons.cancel,
          AppColors.error,
        ),
      _OptionState.dimmed => (
          scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          Colors.transparent,
          null,
          Colors.transparent,
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: border, width: 2),
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(label, style: text.titleMedium)),
                if (icon != null) Icon(icon, color: iconColor, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
