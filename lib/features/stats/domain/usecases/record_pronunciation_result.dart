import '../repositories/stats_repository.dart';

/// Use case: record one pronunciation attempt's score (0–100).
class RecordPronunciationResult {
  /// Creates the use case with its [StatsRepository] dependency.
  const RecordPronunciationResult(this._repository);

  final StatsRepository _repository;

  /// Records [score] for [userId].
  Future<void> call({required String userId, required int score}) =>
      _repository.addPronunciationResult(userId, score);
}
