import 'package:flutter/foundation.dart';

import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_stage.dart';

/// Drives a single play-through of one [Lesson].
///
/// Owns the transient session state: which stage is showing and which quiz
/// answers have been chosen. It computes the score and star rating from those
/// answers but does **not** persist anything — saving is the
/// [LearningController]'s job, called by the player screen on finish. A fresh
/// instance is created per lesson session.
class LessonPlayerController extends ChangeNotifier {
  /// Creates a player for [lesson].
  LessonPlayerController({required this.lesson});

  /// The lesson being played.
  final Lesson lesson;

  final DateTime _startedAt = DateTime.now();
  int _index = 0;
  final Map<int, int> _answers = <int, int>{};

  /// Seconds elapsed since the lesson session started (for practice-time stats).
  int get elapsedSeconds => DateTime.now().difference(_startedAt).inSeconds;

  /// Index of the current stage.
  int get index => _index;

  /// Total number of stages.
  int get stageCount => lesson.stages.length;

  /// The current stage.
  LessonStage get currentStage => lesson.stages[_index];

  /// Whether the current stage is the first.
  bool get isFirst => _index == 0;

  /// Whether the current stage is the last (the review).
  bool get isLast => _index == lesson.stages.length - 1;

  /// Completion fraction (0–1) used by the progress bar.
  double get progress => (_index + 1) / lesson.stages.length;

  /// Advances to the next stage, if any.
  void next() {
    if (!isLast) {
      _index++;
      notifyListeners();
    }
  }

  /// Returns to the previous stage, if any.
  void back() {
    if (!isFirst) {
      _index--;
      notifyListeners();
    }
  }

  // --- Quiz ----------------------------------------------------------------

  QuizStage? get _quizStage {
    for (final LessonStage stage in lesson.stages) {
      if (stage is QuizStage) return stage;
    }
    return null;
  }

  /// The selected option index for question [questionIndex], or `null`.
  int? answerFor(int questionIndex) => _answers[questionIndex];

  /// Records the child's [option] choice for question [questionIndex].
  void answerQuestion(int questionIndex, int option) {
    _answers[questionIndex] = option;
    notifyListeners();
  }

  /// Total number of quiz questions in this lesson.
  int get totalQuestions => _quizStage?.questions.length ?? 0;

  /// Whether every quiz question has been answered.
  bool get allAnswered => _answers.length >= totalQuestions;

  /// Number of quiz questions answered correctly.
  int get correctCount {
    final QuizStage? quiz = _quizStage;
    if (quiz == null) return 0;
    int correct = 0;
    _answers.forEach((int q, int option) {
      if (q < quiz.questions.length && quiz.questions[q].isCorrect(option)) {
        correct++;
      }
    });
    return correct;
  }

  /// Score as a percentage (0–100); 100 when a lesson has no quiz.
  int get scorePercent {
    if (totalQuestions == 0) return 100;
    return ((correctCount / totalQuestions) * 100).round();
  }

  /// Star rating derived from [scorePercent]: 3 (≥90%), 2 (≥60%), else 1.
  int get stars {
    final int pct = scorePercent;
    if (pct >= 90) return 3;
    if (pct >= 60) return 2;
    return 1;
  }
}
