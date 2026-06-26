import 'reward_context.dart';

/// A collectible badge/achievement.
///
/// [isUnlocked] is a pure predicate over a [RewardContext], so unlock status is
/// always derived from current progress — there is no separate achievement
/// state to persist or keep in sync.
class Achievement {
  /// Creates an [Achievement].
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.isUnlocked,
  });

  /// Stable id.
  final String id;

  /// Short display name.
  final String title;

  /// One-line "how to earn it" description.
  final String description;

  /// Badge emoji.
  final String emoji;

  /// Predicate deciding whether the badge is earned for a given context.
  final bool Function(RewardContext context) isUnlocked;
}
