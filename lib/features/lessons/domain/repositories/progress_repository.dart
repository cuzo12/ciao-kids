import '../entities/lesson_progress.dart';
import '../entities/streak_info.dart';

/// Contract for persisting per-user learning progress and streaks.
///
/// All methods are scoped by [userId] so multiple learner profiles (and guests)
/// keep separate progress on the same device. The local implementation stores
/// to `shared_preferences`; a cloud implementation can sync to Firestore later.
abstract interface class ProgressRepository {
  /// Returns every stored lesson-progress record for [userId].
  Future<List<LessonProgress>> getAll(String userId);

  /// Inserts or updates a single lesson-progress record for [userId].
  Future<void> save(String userId, LessonProgress progress);

  /// Returns the current streak for [userId].
  Future<StreakInfo> getStreak(String userId);

  /// Advances the streak for "practiced today" and returns the new value.
  ///
  /// Continues the streak if the last practice was yesterday, leaves it
  /// unchanged if already practiced today, and resets to 1 otherwise.
  Future<StreakInfo> registerPracticeToday(String userId);
}
