import '../../domain/entities/practice_stats.dart';

/// Data-layer [PracticeStats] with JSON (de)serialization.
class PracticeStatsModel extends PracticeStats {
  /// Creates a [PracticeStatsModel].
  const PracticeStatsModel({
    super.pronunciationAttempts,
    super.pronunciationScoreSum,
    super.totalPracticeSeconds,
    super.conversationsCompleted,
    super.storiesCompleted,
  });

  /// Builds a model from a decoded JSON map.
  factory PracticeStatsModel.fromJson(Map<String, dynamic> json) {
    return PracticeStatsModel(
      pronunciationAttempts: (json['pronunciationAttempts'] as num?)?.toInt() ?? 0,
      pronunciationScoreSum: (json['pronunciationScoreSum'] as num?)?.toInt() ?? 0,
      totalPracticeSeconds: (json['totalPracticeSeconds'] as num?)?.toInt() ?? 0,
      conversationsCompleted:
          (json['conversationsCompleted'] as num?)?.toInt() ?? 0,
      storiesCompleted: (json['storiesCompleted'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'pronunciationAttempts': pronunciationAttempts,
        'pronunciationScoreSum': pronunciationScoreSum,
        'totalPracticeSeconds': totalPracticeSeconds,
        'conversationsCompleted': conversationsCompleted,
        'storiesCompleted': storiesCompleted,
      };
}
