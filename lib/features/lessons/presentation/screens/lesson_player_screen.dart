import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../player/presentation/controllers/player_controller.dart';
import '../../../stats/domain/usecases/add_practice_time.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_stage.dart';
import '../controllers/learning_controller.dart';
import '../controllers/lesson_player_controller.dart';
import '../widgets/lesson_progress_bar.dart';
import '../widgets/stages/intro_stage_view.dart';
import '../widgets/stages/match_stage_view.dart';
import '../widgets/stages/pronunciation_stage_view.dart';
import '../widgets/stages/quiz_stage_view.dart';
import '../widgets/stages/review_stage_view.dart';
import '../widgets/stages/vocabulary_stage_view.dart';

/// Plays a single [Lesson] through its ordered stages.
///
/// Creates a [LessonPlayerController] scoped to this screen, renders the current
/// stage, and provides the bottom navigation. On finishing the review stage it
/// hands the result to the app-wide [LearningController] (which persists it and
/// refreshes the dashboard) and pops back home.
class LessonPlayerScreen extends StatelessWidget {
  /// Creates a [LessonPlayerScreen] for [lesson].
  const LessonPlayerScreen({required this.lesson, super.key});

  /// The lesson to play.
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LessonPlayerController>(
      create: (_) => LessonPlayerController(lesson: lesson),
      child: const _PlayerScaffold(),
    );
  }
}

class _PlayerScaffold extends StatelessWidget {
  const _PlayerScaffold();

  Future<void> _confirmExit(BuildContext context) async {
    final bool? leave = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Leave the lesson?'),
        content: const Text("You haven't finished — your stars won't be saved yet."),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if ((leave ?? false) && context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final LessonPlayerController player =
        context.watch<LessonPlayerController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => _confirmExit(context),
        ),
        title: Text(player.lesson.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              LessonProgressBar(
                value: player.progress,
                label: 'Stage ${player.index + 1} of ${player.stageCount}',
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _StageView(player: player)),
              const SizedBox(height: AppSpacing.md),
              _BottomBar(player: player),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chooses the correct stage widget for the player's current stage.
class _StageView extends StatelessWidget {
  const _StageView({required this.player});

  final LessonPlayerController player;

  @override
  Widget build(BuildContext context) {
    final LessonStage stage = player.currentStage;
    return switch (stage) {
      IntroStage s => IntroStageView(stage: s),
      VocabularyStage s => VocabularyStageView(stage: s),
      PronunciationStage s => PronunciationStageView(stage: s),
      MatchStage s => MatchStageView(stage: s),
      QuizStage s => QuizStageView(stage: s),
      ReviewStage s => ReviewStageView(
          stage: s,
          stars: player.stars,
          scorePercent: player.scorePercent,
          correctCount: player.correctCount,
          totalQuestions: player.totalQuestions,
        ),
    };
  }
}

/// Bottom navigation: Back / Continue, or Finish on the review stage.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.player});

  final LessonPlayerController player;

  Future<void> _finish(BuildContext context) async {
    final LearningController learning = context.read<LearningController>();
    final String? userId = context.read<AuthController>().user?.id;
    await learning.submitResult(
      lessonId: player.lesson.id,
      stars: player.stars,
      scorePercent: player.scorePercent,
    );
    if (userId != null) {
      await sl<AddPracticeTime>()(
        userId: userId,
        seconds: player.elapsedSeconds,
      );
    }
    await sl<PlayerController>().record(xp: 20, coins: 5);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (player.isLast) {
      return PrimaryButton(
        label: 'Finish',
        icon: Icons.check_rounded,
        onPressed: () => _finish(context),
      );
    }

    final bool blockedByQuiz =
        player.currentStage is QuizStage && !player.allAnswered;

    return Row(
      children: <Widget>[
        if (!player.isFirst) ...<Widget>[
          OutlinedButton(
            onPressed: player.back,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(64, AppSpacing.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: PrimaryButton(
            label: blockedByQuiz ? 'Answer all to continue' : 'Continue',
            onPressed: blockedByQuiz ? null : player.next,
          ),
        ),
      ],
    );
  }
}
