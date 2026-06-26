import '../domain/entities/achievement.dart';
import '../domain/entities/passport_city.dart';
import '../domain/entities/reward_context.dart';

/// The bundled catalog of achievements (badges) and passport cities.
abstract final class RewardsCatalog {
  /// All badges, with their unlock rules.
  static final List<Achievement> achievements = <Achievement>[
    Achievement(
      id: 'first_lesson',
      title: 'Prime Parole',
      description: 'Finish your first lesson',
      emoji: '🌱',
      isUnlocked: (RewardContext c) => c.lessonsCompleted >= 1,
    ),
    Achievement(
      id: 'three_lessons',
      title: 'On a Roll',
      description: 'Finish three lessons',
      emoji: '🔥',
      isUnlocked: (RewardContext c) => c.lessonsCompleted >= 3,
    ),
    Achievement(
      id: 'all_lessons',
      title: 'Maestro',
      description: 'Finish every lesson',
      emoji: '🏆',
      isUnlocked: (RewardContext c) =>
          c.totalLessons > 0 && c.lessonsCompleted >= c.totalLessons,
    ),
    Achievement(
      id: 'perfect',
      title: 'Perfetto!',
      description: 'Earn 3 stars in a lesson',
      emoji: '⭐',
      isUnlocked: (RewardContext c) => c.bestSingleStars >= 3,
    ),
    Achievement(
      id: 'ten_stars',
      title: 'Star Collector',
      description: 'Collect 10 stars',
      emoji: '🌟',
      isUnlocked: (RewardContext c) => c.totalStars >= 10,
    ),
    Achievement(
      id: 'streak_3',
      title: 'Streak Star',
      description: 'Practice 3 days in a row',
      emoji: '📅',
      isUnlocked: (RewardContext c) => c.streakDays >= 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Practice 7 days in a row',
      emoji: '🗓️',
      isUnlocked: (RewardContext c) => c.streakDays >= 7,
    ),
    Achievement(
      id: 'chatterbox',
      title: 'Chiacchierone',
      description: 'Finish a conversation',
      emoji: '💬',
      isUnlocked: (RewardContext c) => c.conversationsCompleted >= 1,
    ),
    Achievement(
      id: 'storyteller',
      title: 'Narratore',
      description: 'Finish a story',
      emoji: '📖',
      isUnlocked: (RewardContext c) => c.storiesCompleted >= 1,
    ),
    Achievement(
      id: 'bella_voce',
      title: 'Bella Voce',
      description: 'Average 80% in pronunciation',
      emoji: '🎤',
      isUnlocked: (RewardContext c) => c.pronunciationAverage >= 80,
    ),
  ];

  /// Italian cities for the passport, in unlock order.
  static const List<PassportCity> cities = <PassportCity>[
    PassportCity(
        name: 'Roma', emoji: '🏛️', landmark: 'Colosseo', unlockAtLessons: 0),
    PassportCity(
        name: 'Venezia', emoji: '🛶', landmark: 'Canal Grande', unlockAtLessons: 1),
    PassportCity(
        name: 'Firenze', emoji: '🎨', landmark: 'Duomo', unlockAtLessons: 2),
    PassportCity(
        name: 'Napoli', emoji: '🍕', landmark: 'Vesuvio', unlockAtLessons: 3),
    PassportCity(
        name: 'Milano', emoji: '👗', landmark: 'Galleria', unlockAtLessons: 4),
    PassportCity(
        name: 'Pisa', emoji: '🗼', landmark: 'Torre', unlockAtLessons: 5),
    PassportCity(
        name: 'Bologna', emoji: '🍝', landmark: 'Le Due Torri', unlockAtLessons: 6),
    PassportCity(
        name: 'Sicilia', emoji: '🌋', landmark: 'Etna', unlockAtLessons: 8),
  ];
}
