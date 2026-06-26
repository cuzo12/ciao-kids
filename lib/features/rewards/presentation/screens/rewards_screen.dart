import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../lessons/domain/entities/lesson.dart';
import '../../../lessons/presentation/controllers/learning_controller.dart';
import '../../../stats/domain/entities/practice_stats.dart';
import '../../../stats/domain/usecases/get_practice_stats.dart';
import '../../data/rewards_catalog.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/passport_city.dart';
import '../../domain/entities/reward_context.dart';

/// The rewards hub: earned badges and the virtual passport of Italian cities.
class RewardsScreen extends StatefulWidget {
  /// Creates the [RewardsScreen].
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  PracticeStats _stats = PracticeStats.empty;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final String userId = context.read<AuthController>().user?.id ?? 'guest';
    final PracticeStats stats = await sl<GetPracticeStats>()(userId);
    if (mounted) setState(() => _stats = stats);
  }

  RewardContext _buildContext(LearningController learning) {
    int bestSingle = 0;
    for (final Lesson lesson in learning.lessons) {
      final int stars = learning.progressFor(lesson.id)?.bestStars ?? 0;
      if (stars > bestSingle) bestSingle = stars;
    }
    final summary = learning.summary;
    return RewardContext(
      lessonsCompleted: summary.lessonsCompleted,
      totalLessons: learning.lessons.length,
      totalStars: summary.totalStars,
      bestSingleStars: bestSingle,
      streakDays: summary.streakDays,
      conversationsCompleted: _stats.conversationsCompleted,
      storiesCompleted: _stats.storiesCompleted,
      pronunciationAverage: _stats.averagePronunciation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final LearningController learning = context.watch<LearningController>();
    final RewardContext ctx = _buildContext(learning);
    final TextTheme text = Theme.of(context).textTheme;

    final int unlockedBadges = RewardsCatalog.achievements
        .where((Achievement a) => a.isUnlocked(ctx))
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Text(
              'Badges  ·  $unlockedBadges/${RewardsCatalog.achievements.length}',
              style: text.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                for (final Achievement a in RewardsCatalog.achievements)
                  _BadgeTile(achievement: a, unlocked: a.isUnlocked(ctx)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Virtual Passport', style: text.headlineSmall),
            Text('Unlock cities as you learn', style: text.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                for (final PassportCity city in RewardsCatalog.cities)
                  _CityTile(
                    city: city,
                    unlocked: ctx.lessonsCompleted >= city.unlockAtLessons,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.achievement, required this.unlocked});

  final Achievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Tooltip(
      message: achievement.description,
      child: Opacity(
        opacity: unlocked ? 1 : 0.45,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: (unlocked ? AppColors.accent : AppColors.tertiary)
                .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            children: <Widget>[
              Text(unlocked ? achievement.emoji : '🔒',
                  style: const TextStyle(fontSize: 36)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                achievement.title,
                style: text.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({required this.city, required this.unlocked});

  final PassportCity city;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Opacity(
      opacity: unlocked ? 1 : 0.4,
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: unlocked
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          children: <Widget>[
            Text(unlocked ? city.emoji : '🔒',
                style: const TextStyle(fontSize: 34)),
            const SizedBox(height: AppSpacing.xs),
            Text(city.name, style: text.titleMedium),
            Text(city.landmark,
                style: text.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
