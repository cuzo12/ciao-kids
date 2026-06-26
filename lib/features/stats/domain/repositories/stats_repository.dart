import '../entities/practice_stats.dart';

/// Contract for reading and updating per-user [PracticeStats].
///
/// Writes are small increments invoked by the various practice features
/// (pronunciation, conversation, story, lessons); the parent dashboard reads
/// the aggregate. Local now; cloud-syncable later behind the same interface.
abstract interface class StatsRepository {
  /// Returns the stored stats for [userId] (empty if none yet).
  Future<PracticeStats> get(String userId);

  /// Records a single pronunciation [score] (0–100) for [userId].
  Future<void> addPronunciationResult(String userId, int score);

  /// Adds [seconds] of practice time for [userId].
  Future<void> addPracticeSeconds(String userId, int seconds);

  /// Increments the completed-conversations counter for [userId].
  Future<void> incrementConversations(String userId);

  /// Increments the completed-stories counter for [userId].
  Future<void> incrementStories(String userId);
}
