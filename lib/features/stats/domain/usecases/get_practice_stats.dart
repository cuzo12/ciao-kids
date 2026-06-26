import '../entities/practice_stats.dart';
import '../repositories/stats_repository.dart';

/// Use case: read a learner's practice stats.
class GetPracticeStats {
  /// Creates the use case with its [StatsRepository] dependency.
  const GetPracticeStats(this._repository);

  final StatsRepository _repository;

  /// Returns the stats for [userId].
  Future<PracticeStats> call(String userId) => _repository.get(userId);
}
