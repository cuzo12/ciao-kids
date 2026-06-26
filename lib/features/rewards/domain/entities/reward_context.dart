import 'package:equatable/equatable.dart';

/// A snapshot of the learner's progress used to evaluate which rewards are
/// unlocked. Assembled by the rewards screen from the learning controller and
/// practice stats, then passed to each [Achievement]'s predicate.
class RewardContext extends Equatable {
  /// Creates a [RewardContext].
  const RewardContext({
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.totalStars,
    required this.bestSingleStars,
    required this.streakDays,
    required this.conversationsCompleted,
    required this.storiesCompleted,
    required this.pronunciationAverage,
  });

  /// Distinct lessons completed at least once.
  final int lessonsCompleted;

  /// Total lessons in the catalog.
  final int totalLessons;

  /// Total stars earned across all lessons.
  final int totalStars;

  /// Highest star count earned on any single lesson.
  final int bestSingleStars;

  /// Current daily-practice streak.
  final int streakDays;

  /// Conversations finished.
  final int conversationsCompleted;

  /// Stories finished.
  final int storiesCompleted;

  /// Average pronunciation score (0–100).
  final int pronunciationAverage;

  @override
  List<Object?> get props => <Object?>[
        lessonsCompleted,
        totalLessons,
        totalStars,
        bestSingleStars,
        streakDays,
        conversationsCompleted,
        storiesCompleted,
        pronunciationAverage,
      ];
}
