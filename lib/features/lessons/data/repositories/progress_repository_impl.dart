import '../../domain/entities/lesson_progress.dart';
import '../../domain/entities/streak_info.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';
import '../models/lesson_progress_model.dart';

/// [ProgressRepository] delegating to a [ProgressLocalDataSource].
///
/// Progress is non-critical state, so read failures degrade gracefully to
/// "no progress" / empty streak rather than surfacing errors that would block
/// a child mid-lesson.
class ProgressRepositoryImpl implements ProgressRepository {
  /// Creates the repository over the given [dataSource].
  const ProgressRepositoryImpl(this._dataSource);

  final ProgressLocalDataSource _dataSource;

  @override
  Future<List<LessonProgress>> getAll(String userId) async {
    try {
      return await _dataSource.getAll(userId);
    } catch (_) {
      return <LessonProgress>[];
    }
  }

  @override
  Future<void> save(String userId, LessonProgress progress) {
    return _dataSource.save(userId, LessonProgressModel.fromEntity(progress));
  }

  @override
  Future<StreakInfo> getStreak(String userId) async {
    try {
      return await _dataSource.getStreak(userId);
    } catch (_) {
      return StreakInfo.empty;
    }
  }

  @override
  Future<StreakInfo> registerPracticeToday(String userId) {
    return _dataSource.registerPracticeToday(userId);
  }
}
