import 'package:equatable/equatable.dart';

/// Cross-feature practice metrics for one learner, used by the parent dashboard.
///
/// Aggregates signals that the lesson engine doesn't already cover: spoken
/// pronunciation accuracy, total time practiced, and counts of completed
/// conversations and stories. Stored per user.
class PracticeStats extends Equatable {
  /// Creates [PracticeStats].
  const PracticeStats({
    this.pronunciationAttempts = 0,
    this.pronunciationScoreSum = 0,
    this.totalPracticeSeconds = 0,
    this.conversationsCompleted = 0,
    this.storiesCompleted = 0,
  });

  /// Number of pronunciation attempts recorded.
  final int pronunciationAttempts;

  /// Sum of pronunciation scores (each 0–100); average is derived.
  final int pronunciationScoreSum;

  /// Total time spent practicing, in seconds.
  final int totalPracticeSeconds;

  /// Number of conversations finished.
  final int conversationsCompleted;

  /// Number of stories finished.
  final int storiesCompleted;

  /// Average pronunciation score (0–100), or 0 if no attempts yet.
  int get averagePronunciation => pronunciationAttempts == 0
      ? 0
      : (pronunciationScoreSum / pronunciationAttempts).round();

  /// Total practice time rounded to whole minutes.
  int get totalPracticeMinutes => (totalPracticeSeconds / 60).round();

  /// An empty stats record.
  static const PracticeStats empty = PracticeStats();

  @override
  List<Object?> get props => <Object?>[
        pronunciationAttempts,
        pronunciationScoreSum,
        totalPracticeSeconds,
        conversationsCompleted,
        storiesCompleted,
      ];
}
