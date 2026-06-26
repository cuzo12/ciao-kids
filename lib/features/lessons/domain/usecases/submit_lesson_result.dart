import '../entities/lesson_progress.dart';
import '../entities/streak_info.dart';
import '../repositories/progress_repository.dart';

/// Use case: persist the outcome of a finished lesson.
///
/// Saves the (already best-merged) [progress] record and advances the daily
/// streak, returning the updated [StreakInfo] so the caller can refresh the UI.
class SubmitLessonResult {
  /// Creates the use case with its [ProgressRepository] dependency.
  const SubmitLessonResult(this._repository);

  final ProgressRepository _repository;

  /// Saves [progress] for [userId] and registers today's practice.
  Future<StreakInfo> call({
    required String userId,
    required LessonProgress progress,
  }) async {
    await _repository.save(userId, progress);
    return _repository.registerPracticeToday(userId);
  }
}
