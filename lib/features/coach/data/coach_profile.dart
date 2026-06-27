import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// The learner's goals and context, persisted locally per user.
///
/// The AI coach reads this to personalize every session: a kid preparing for a
/// family trip to Rome gets different exercises than one learning for school.
class CoachProfile {
  const CoachProfile({
    this.goal = CoachGoal.travel,
    this.tripDate,
    this.level = 1,
    this.dailyMinutes = 20,
    this.interests = const <String>[],
    this.setupDone = false,
  });

  final CoachGoal goal;
  final String? tripDate; // ISO date, e.g. '2027-07-15'
  final int level; // 1 = beginner, 2 = intermediate, 3 = advanced
  final int dailyMinutes;
  final List<String> interests; // e.g. ['food', 'sports', 'animals']
  final bool setupDone;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'goal': goal.name,
    'tripDate': tripDate,
    'level': level,
    'dailyMinutes': dailyMinutes,
    'interests': interests,
    'setupDone': setupDone,
  };

  factory CoachProfile.fromJson(Map<String, dynamic> j) => CoachProfile(
    goal: CoachGoal.values.firstWhere(
      (CoachGoal g) => g.name == j['goal'],
      orElse: () => CoachGoal.travel,
    ),
    tripDate: j['tripDate'] as String?,
    level: (j['level'] as num?)?.toInt() ?? 1,
    dailyMinutes: (j['dailyMinutes'] as num?)?.toInt() ?? 20,
    interests: ((j['interests'] as List<dynamic>?) ?? <dynamic>[])
        .map((dynamic e) => e as String)
        .toList(),
    setupDone: (j['setupDone'] as bool?) ?? false,
  );

  CoachProfile copyWith({
    CoachGoal? goal,
    String? tripDate,
    int? level,
    int? dailyMinutes,
    List<String>? interests,
    bool? setupDone,
  }) =>
      CoachProfile(
        goal: goal ?? this.goal,
        tripDate: tripDate ?? this.tripDate,
        level: level ?? this.level,
        dailyMinutes: dailyMinutes ?? this.dailyMinutes,
        interests: interests ?? this.interests,
        setupDone: setupDone ?? this.setupDone,
      );

  String get goalLabel => switch (goal) {
    CoachGoal.travel => 'Trip to Italy',
    CoachGoal.school => 'School / Class',
    CoachGoal.fun => 'Just for fun',
    CoachGoal.family => 'Family heritage',
  };

  String? get daysUntilTrip {
    if (tripDate == null) return null;
    final int days = DateTime.parse(tripDate!).difference(DateTime.now()).inDays;
    if (days < 0) return null;
    return '$days days';
  }
}

enum CoachGoal { travel, school, fun, family }

class CoachProfileService {
  CoachProfileService(this._prefs);

  final SharedPreferences _prefs;

  String _key(String userId) => 'ciao_kids.coach.$userId';

  CoachProfile load(String userId) {
    final String? raw = _prefs.getString(_key(userId));
    if (raw == null) return const CoachProfile();
    try {
      return CoachProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const CoachProfile();
    }
  }

  Future<void> save(String userId, CoachProfile profile) async {
    await _prefs.setString(_key(userId), jsonEncode(profile.toJson()));
  }
}
