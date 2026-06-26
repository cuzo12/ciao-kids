import 'package:equatable/equatable.dart';

/// The child's daily-practice streak.
///
/// [days] is the current consecutive-day count; [lastPracticedUtc] is the day
/// (UTC) the streak was last advanced, used to decide whether the next practice
/// continues, resets, or is the same day.
class StreakInfo extends Equatable {
  /// Creates a [StreakInfo].
  const StreakInfo({required this.days, this.lastPracticedUtc});

  /// Current consecutive-day streak length.
  final int days;

  /// The UTC date the streak was last updated, or `null` if never.
  final DateTime? lastPracticedUtc;

  /// A zero/never-practiced streak.
  static const StreakInfo empty = StreakInfo(days: 0);

  @override
  List<Object?> get props => <Object?>[days, lastPracticedUtc];
}
