import 'package:equatable/equatable.dart';

/// The child's best recorded result for a single lesson.
///
/// Stars and score are stored as *bests*: replaying a lesson can only improve
/// them, never regress. Aggregate XP/coins are derived from these values in the
/// learning controller, so totals are always recomputable and never
/// double-counted.
class LessonProgress extends Equatable {
  /// Creates a [LessonProgress].
  const LessonProgress({
    required this.lessonId,
    this.completed = false,
    this.bestStars = 0,
    this.bestScorePercent = 0,
  });

  /// The lesson this record refers to.
  final String lessonId;

  /// Whether the lesson has ever been finished.
  final bool completed;

  /// Best star rating earned (0–3).
  final int bestStars;

  /// Best quiz score as a percentage (0–100).
  final int bestScorePercent;

  /// Returns a completed copy, keeping the better of the old/new star & score.
  LessonProgress mergeBest({required int stars, required int scorePercent}) {
    return LessonProgress(
      lessonId: lessonId,
      completed: true,
      bestStars: stars > bestStars ? stars : bestStars,
      bestScorePercent:
          scorePercent > bestScorePercent ? scorePercent : bestScorePercent,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[lessonId, completed, bestStars, bestScorePercent];
}
