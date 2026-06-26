import 'package:ciao_kids/features/rewards/data/rewards_catalog.dart';
import 'package:ciao_kids/features/rewards/domain/entities/achievement.dart';
import 'package:ciao_kids/features/rewards/domain/entities/reward_context.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the achievement unlock rules and passport catalog.
void main() {
  Achievement byId(String id) =>
      RewardsCatalog.achievements.firstWhere((Achievement a) => a.id == id);

  test('a new learner has only the entry achievements locked/unlocked right', () {
    const RewardContext fresh = RewardContext(
      lessonsCompleted: 1,
      totalLessons: 6,
      totalStars: 2,
      bestSingleStars: 2,
      streakDays: 1,
      conversationsCompleted: 0,
      storiesCompleted: 0,
      pronunciationAverage: 0,
    );

    expect(byId('first_lesson').isUnlocked(fresh), isTrue);
    expect(byId('three_lessons').isUnlocked(fresh), isFalse);
    expect(byId('perfect').isUnlocked(fresh), isFalse);
    expect(byId('chatterbox').isUnlocked(fresh), isFalse);
  });

  test('a fully accomplished learner unlocks every badge', () {
    const RewardContext maxed = RewardContext(
      lessonsCompleted: 6,
      totalLessons: 6,
      totalStars: 18,
      bestSingleStars: 3,
      streakDays: 7,
      conversationsCompleted: 2,
      storiesCompleted: 1,
      pronunciationAverage: 92,
    );

    final int unlocked = RewardsCatalog.achievements
        .where((Achievement a) => a.isUnlocked(maxed))
        .length;
    expect(unlocked, RewardsCatalog.achievements.length);
  });

  test('the passport starts in Rome', () {
    expect(RewardsCatalog.cities, isNotEmpty);
    expect(RewardsCatalog.cities.first.name, 'Roma');
    expect(RewardsCatalog.cities.first.unlockAtLessons, 0);
  });
}
