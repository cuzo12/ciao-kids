import '../../domain/entities/practice_stats.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_local_datasource.dart';
import '../models/practice_stats_model.dart';

/// [StatsRepository] backed by a [StatsLocalDataSource].
///
/// Each mutation is a read-modify-write of the stored model. Stats are
/// non-critical, so failures degrade to no-ops / empty rather than surfacing.
class StatsRepositoryImpl implements StatsRepository {
  /// Creates the repository over [_dataSource].
  const StatsRepositoryImpl(this._dataSource);

  final StatsLocalDataSource _dataSource;

  @override
  Future<PracticeStats> get(String userId) async {
    try {
      return await _dataSource.get(userId);
    } catch (_) {
      return PracticeStats.empty;
    }
  }

  @override
  Future<void> addPronunciationResult(String userId, int score) async {
    final PracticeStatsModel current = await _safeGet(userId);
    await _dataSource.save(
      userId,
      PracticeStatsModel(
        pronunciationAttempts: current.pronunciationAttempts + 1,
        pronunciationScoreSum: current.pronunciationScoreSum + score.clamp(0, 100),
        totalPracticeSeconds: current.totalPracticeSeconds,
        conversationsCompleted: current.conversationsCompleted,
        storiesCompleted: current.storiesCompleted,
      ),
    );
  }

  @override
  Future<void> addPracticeSeconds(String userId, int seconds) async {
    if (seconds <= 0) return;
    final PracticeStatsModel current = await _safeGet(userId);
    await _dataSource.save(
      userId,
      PracticeStatsModel(
        pronunciationAttempts: current.pronunciationAttempts,
        pronunciationScoreSum: current.pronunciationScoreSum,
        totalPracticeSeconds: current.totalPracticeSeconds + seconds,
        conversationsCompleted: current.conversationsCompleted,
        storiesCompleted: current.storiesCompleted,
      ),
    );
  }

  @override
  Future<void> incrementConversations(String userId) async {
    final PracticeStatsModel current = await _safeGet(userId);
    await _dataSource.save(
      userId,
      PracticeStatsModel(
        pronunciationAttempts: current.pronunciationAttempts,
        pronunciationScoreSum: current.pronunciationScoreSum,
        totalPracticeSeconds: current.totalPracticeSeconds,
        conversationsCompleted: current.conversationsCompleted + 1,
        storiesCompleted: current.storiesCompleted,
      ),
    );
  }

  @override
  Future<void> incrementStories(String userId) async {
    final PracticeStatsModel current = await _safeGet(userId);
    await _dataSource.save(
      userId,
      PracticeStatsModel(
        pronunciationAttempts: current.pronunciationAttempts,
        pronunciationScoreSum: current.pronunciationScoreSum,
        totalPracticeSeconds: current.totalPracticeSeconds,
        conversationsCompleted: current.conversationsCompleted,
        storiesCompleted: current.storiesCompleted + 1,
      ),
    );
  }

  Future<PracticeStatsModel> _safeGet(String userId) async {
    try {
      return await _dataSource.get(userId);
    } catch (_) {
      return const PracticeStatsModel();
    }
  }
}
