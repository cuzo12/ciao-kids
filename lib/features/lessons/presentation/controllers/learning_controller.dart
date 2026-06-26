import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../domain/entities/progress_summary.dart';
import '../../domain/entities/streak_info.dart';
import '../../domain/usecases/get_learning_state.dart';
import '../../domain/usecases/get_lessons.dart';
import '../../domain/usecases/submit_lesson_result.dart';

/// Holds the learner's view of the lesson catalog: the lessons themselves,
/// per-lesson progress, the derived [summary] (XP / coins / stars / streak),
/// and the unlock rules.
///
/// This is the single source of truth the home dashboard binds to. It is
/// loaded per user (so guests and profiles stay separate) and refreshed
/// whenever a lesson result is submitted.
class LearningController extends ChangeNotifier {
  /// Creates the controller with its injected use cases.
  LearningController({
    required GetLessons getLessons,
    required GetLearningState getLearningState,
    required SubmitLessonResult submitLessonResult,
  })  : _getLessons = getLessons,
        _getLearningState = getLearningState,
        _submitLessonResult = submitLessonResult;

  final GetLessons _getLessons;
  final GetLearningState _getLearningState;
  final SubmitLessonResult _submitLessonResult;

  String? _userId;
  bool _loading = true;
  List<Lesson> _lessons = const <Lesson>[];
  Map<String, LessonProgress> _progressById = const <String, LessonProgress>{};
  StreakInfo _streak = StreakInfo.empty;

  /// Whether the initial load is still in progress.
  bool get loading => _loading;

  /// All lessons, in unlock order.
  List<Lesson> get lessons => _lessons;

  /// Returns the loaded lesson with [id], or `null` if not present.
  Lesson? lessonById(String id) {
    for (final Lesson lesson in _lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  /// Aggregated stats for the dashboard header.
  ProgressSummary get summary {
    int xp = 0;
    int coins = 0;
    int stars = 0;
    int completed = 0;
    for (final LessonProgress p in _progressById.values) {
      if (!p.completed) continue;
      completed++;
      stars += p.bestStars;
      xp += AppConstants.xpPerLesson + p.bestStars * AppConstants.xpPerStar;
      coins +=
          AppConstants.coinsPerLesson + p.bestStars * AppConstants.coinsPerStar;
    }
    return ProgressSummary(
      totalXp: xp,
      totalCoins: coins,
      totalStars: stars,
      lessonsCompleted: completed,
      streakDays: _streak.days,
    );
  }

  /// Returns the stored progress for [lessonId], or `null` if untouched.
  LessonProgress? progressFor(String lessonId) => _progressById[lessonId];

  /// Whether [lesson] is playable: the first lesson is always open; later ones
  /// unlock once the previous lesson (by order) is completed.
  bool isUnlocked(Lesson lesson) {
    final int index = _lessons.indexWhere((Lesson l) => l.id == lesson.id);
    if (index <= 0) return true;
    final Lesson previous = _lessons[index - 1];
    return _progressById[previous.id]?.completed ?? false;
  }

  /// The next lesson to suggest: the first unlocked, not-yet-completed lesson,
  /// falling back to the first lesson. Returns `null` only if the catalog is
  /// empty.
  Lesson? get nextLesson {
    for (final Lesson lesson in _lessons) {
      final bool done = _progressById[lesson.id]?.completed ?? false;
      if (isUnlocked(lesson) && !done) return lesson;
    }
    return _lessons.isEmpty ? null : _lessons.first;
  }

  /// Loads (or reloads) the catalog and progress for [userId].
  Future<void> load(String userId) async {
    _userId = userId;
    _loading = true;
    notifyListeners();

    _lessons = await _getLessons();
    final LearningState state = await _getLearningState(userId);
    _progressById = <String, LessonProgress>{
      for (final LessonProgress p in state.progress) p.lessonId: p,
    };
    _streak = state.streak;

    _loading = false;
    notifyListeners();
  }

  /// Persists a finished lesson's [stars]/[scorePercent] (keeping bests),
  /// updates the streak, and refreshes local state so the UI reflects unlocks
  /// and new totals immediately.
  Future<void> submitResult({
    required String lessonId,
    required int stars,
    required int scorePercent,
  }) async {
    final String? userId = _userId;
    if (userId == null) return;

    final LessonProgress existing =
        _progressById[lessonId] ?? LessonProgress(lessonId: lessonId);
    final LessonProgress merged =
        existing.mergeBest(stars: stars, scorePercent: scorePercent);

    final StreakInfo streak = await _submitLessonResult(
      userId: userId,
      progress: merged,
    );

    _progressById = <String, LessonProgress>{
      ..._progressById,
      lessonId: merged,
    };
    _streak = streak;
    notifyListeners();
  }
}
