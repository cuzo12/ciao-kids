import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/practice_stats_model.dart';

/// Local persistence for [PracticeStatsModel], scoped per user.
abstract interface class StatsLocalDataSource {
  /// Reads stats for [userId] (empty model if none).
  Future<PracticeStatsModel> get(String userId);

  /// Overwrites stored stats for [userId].
  Future<void> save(String userId, PracticeStatsModel stats);
}

/// [SharedPreferences]-backed [StatsLocalDataSource].
class StatsLocalDataSourceImpl implements StatsLocalDataSource {
  /// Creates the datasource with an injected [SharedPreferences].
  const StatsLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  String _key(String userId) => '${AppConstants.kStatsKeyPrefix}$userId';

  @override
  Future<PracticeStatsModel> get(String userId) async {
    final String? raw = _prefs.getString(_key(userId));
    if (raw == null) return const PracticeStatsModel();
    return PracticeStatsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(String userId, PracticeStatsModel stats) async {
    await _prefs.setString(_key(userId), jsonEncode(stats.toJson()));
  }
}
