import 'package:equatable/equatable.dart';

/// Aggregated learning stats shown on the home dashboard.
///
/// A derived value object computed from all [LessonProgress] records plus the
/// current streak. Computing it on demand (rather than storing it) keeps the
/// totals consistent with the underlying per-lesson data.
class ProgressSummary extends Equatable {
  /// Creates a [ProgressSummary].
  const ProgressSummary({
    required this.totalXp,
    required this.totalCoins,
    required this.totalStars,
    required this.lessonsCompleted,
    required this.streakDays,
  });

  /// Total experience points earned.
  final int totalXp;

  /// Total coin balance earned.
  final int totalCoins;

  /// Total stars collected across all lessons.
  final int totalStars;

  /// Number of distinct lessons completed at least once.
  final int lessonsCompleted;

  /// Current daily-practice streak length.
  final int streakDays;

  /// An empty summary (new learner).
  static const ProgressSummary empty = ProgressSummary(
    totalXp: 0,
    totalCoins: 0,
    totalStars: 0,
    lessonsCompleted: 0,
    streakDays: 0,
  );

  @override
  List<Object?> get props =>
      <Object?>[totalXp, totalCoins, totalStars, lessonsCompleted, streakDays];
}
