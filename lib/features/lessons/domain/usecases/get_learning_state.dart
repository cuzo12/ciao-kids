import '../entities/lesson_progress.dart';
import '../entities/streak_info.dart';
import '../repositories/progress_repository.dart';

/// The combined progress + streak snapshot for a user, returned as a record.
typedef LearningState = ({List<LessonProgress> progress, StreakInfo streak});

/// Use case: load all of a user's progress and their streak in one call.
class GetLearningState {
  /// Creates the use case with its [ProgressRepository] dependency.
  const GetLearningState(this._repository);

  final ProgressRepository _repository;

  /// Loads progress and streak for [userId].
  Future<LearningState> call(String userId) async {
    final List<LessonProgress> progress = await _repository.getAll(userId);
    final StreakInfo streak = await _repository.getStreak(userId);
    return (progress: progress, streak: streak);
  }
}
