import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/streak_info.dart';
import '../models/lesson_progress_model.dart';

/// Local persistence for learning progress and streaks, scoped per user.
///
/// Progress is stored as a JSON object keyed by lesson id (so saves are simple
/// upserts), and the streak as a small `{days, lastPracticed}` record. A cloud
/// (Firestore) datasource can implement the same interface later.
abstract interface class ProgressLocalDataSource {
  /// Returns all progress records for [userId].
  Future<List<LessonProgressModel>> getAll(String userId);

  /// Upserts a single progress record for [userId].
  Future<void> save(String userId, LessonProgressModel progress);

  /// Reads the stored streak for [userId].
  Future<StreakInfo> getStreak(String userId);

  /// Advances and stores the streak for "practiced today".
  Future<StreakInfo> registerPracticeToday(String userId);
}

/// [SharedPreferences]-backed [ProgressLocalDataSource].
class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  /// Creates the datasource with an injected [SharedPreferences].
  const ProgressLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  String _progressKey(String userId) =>
      '${AppConstants.kProgressKeyPrefix}$userId';

  String _streakKey(String userId) =>
      '${AppConstants.kStreakKeyPrefix}$userId';

  @override
  Future<List<LessonProgressModel>> getAll(String userId) async {
    final String? raw = _prefs.getString(_progressKey(userId));
    if (raw == null) return <LessonProgressModel>[];
    final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
    return map.values
        .map((dynamic v) =>
            LessonProgressModel.fromJson(v as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> save(String userId, LessonProgressModel progress) async {
    final String? raw = _prefs.getString(_progressKey(userId));
    final Map<String, dynamic> map =
        raw == null ? <String, dynamic>{} : jsonDecode(raw) as Map<String, dynamic>;
    map[progress.lessonId] = progress.toJson();
    await _prefs.setString(_progressKey(userId), jsonEncode(map));
  }

  @override
  Future<StreakInfo> getStreak(String userId) async {
    final String? raw = _prefs.getString(_streakKey(userId));
    if (raw == null) return StreakInfo.empty;
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    final String? last = json['lastPracticed'] as String?;
    return StreakInfo(
      days: (json['days'] as num?)?.toInt() ?? 0,
      lastPracticedUtc: last == null ? null : DateTime.parse(last),
    );
  }

  @override
  Future<StreakInfo> registerPracticeToday(String userId) async {
    final DateTime now = DateTime.now().toUtc();
    final DateTime today = DateTime.utc(now.year, now.month, now.day);
    final StreakInfo current = await getStreak(userId);
    final DateTime? last = current.lastPracticedUtc;

    final int days;
    if (last == null) {
      days = 1;
    } else {
      final DateTime lastDay = DateTime.utc(last.year, last.month, last.day);
      final int dayGap = today.difference(lastDay).inDays;
      if (dayGap <= 0) {
        // Already practiced today — keep the count (at least 1).
        days = current.days < 1 ? 1 : current.days;
      } else if (dayGap == 1) {
        days = current.days + 1; // consecutive day
      } else {
        days = 1; // streak broken; start over
      }
    }

    final StreakInfo updated = StreakInfo(days: days, lastPracticedUtc: today);
    await _prefs.setString(
      _streakKey(userId),
      jsonEncode(<String, dynamic>{
        'days': updated.days,
        'lastPracticed': updated.lastPracticedUtc?.toIso8601String(),
      }),
    );
    return updated;
  }
}
