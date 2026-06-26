import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_progress.dart';
import 'star_rating.dart';

/// A dashboard tile for a single [Lesson].
///
/// Shows the lesson's emoji, title, and subtitle, with a footer that reflects
/// state: a lock when not yet [unlocked], an earned [StarRating] when completed,
/// or a "play" affordance when unlocked but not finished.
class LessonCard extends StatelessWidget {
  /// Creates a [LessonCard].
  const LessonCard({
    required this.lesson,
    required this.unlocked,
    required this.progress,
    required this.color,
    required this.onTap,
    super.key,
  });

  /// The lesson to display.
  final Lesson lesson;

  /// Whether the lesson is currently playable.
  final bool unlocked;

  /// The child's stored progress, or `null` if untouched.
  final LessonProgress? progress;

  /// Accent color for the tile.
  final Color color;

  /// Tap handler (locked taps are handled by the caller, e.g. a hint snackbar).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool completed = progress?.completed ?? false;

    return Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: Material(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(lesson.emoji, style: const TextStyle(fontSize: 34)),
                    _StatusBadge(
                      unlocked: unlocked,
                      completed: completed,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  lesson.title,
                  style: text.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  lesson.subtitle,
                  style: text.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (completed)
                  StarRating(stars: progress?.bestStars ?? 0, size: 20)
                else
                  Text(
                    unlocked ? 'Tap to start' : 'Locked',
                    style: text.labelMedium?.copyWith(color: color),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The small circular status icon in the card's top-right corner.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.unlocked,
    required this.completed,
    required this.color,
  });

  final bool unlocked;
  final bool completed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final IconData icon = !unlocked
        ? Icons.lock_outline
        : completed
            ? Icons.check_circle
            : Icons.play_circle_fill;
    return Icon(icon, color: color, size: 26);
  }
}
