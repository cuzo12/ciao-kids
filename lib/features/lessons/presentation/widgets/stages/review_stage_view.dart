import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/lesson_stage.dart';
import '../star_rating.dart';

/// Renders a [ReviewStage]: the celebratory wrap-up showing the earned stars,
/// quiz score, the lesson's review message, and the rewards collected.
class ReviewStageView extends StatelessWidget {
  /// Creates a [ReviewStageView].
  const ReviewStageView({
    required this.stage,
    required this.stars,
    required this.scorePercent,
    required this.correctCount,
    required this.totalQuestions,
    super.key,
  });

  /// The review data (the wrap-up message).
  final ReviewStage stage;

  /// Stars earned this play-through.
  final int stars;

  /// Quiz score as a percentage.
  final int scorePercent;

  /// Number of correct answers.
  final int correctCount;

  /// Total number of questions.
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final int xp = AppConstants.xpPerLesson + stars * AppConstants.xpPerStar;
    final int coins =
        AppConstants.coinsPerLesson + stars * AppConstants.coinsPerStar;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('🎉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: AppSpacing.sm),
            Text('Lesson complete!', style: text.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            StarRating(stars: stars, size: 44),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You got $correctCount of $totalQuestions right ($scorePercent%).',
              style: text.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Text(
                stage.message,
                textAlign: TextAlign.center,
                style: text.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _RewardPill(
                  icon: Icons.star_rounded,
                  label: '+$xp XP',
                  color: AppColors.tertiary,
                ),
                const SizedBox(width: AppSpacing.md),
                _RewardPill(
                  icon: Icons.monetization_on,
                  label: '+$coins',
                  color: AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A reward chip shown on the review screen.
class _RewardPill extends StatelessWidget {
  const _RewardPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: text.titleMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}
