import '../repositories/stats_repository.dart';

/// Use case: add elapsed practice time (in seconds) for a learner.
class AddPracticeTime {
  /// Creates the use case with its [StatsRepository] dependency.
  const AddPracticeTime(this._repository);

  final StatsRepository _repository;

  /// Adds [seconds] of practice time for [userId].
  Future<void> call({required String userId, required int seconds}) =>
      _repository.addPracticeSeconds(userId, seconds);
}
