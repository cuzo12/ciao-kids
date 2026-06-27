import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Lists available mini-games.
class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Games')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Text('Pick a game!', style: text.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            _GameTile(
              emoji: '🔤',
              title: 'Word Scramble',
              subtitle: 'Unscramble the Italian letters',
              color: AppColors.primary,
              onTap: () => context.pushNamed(Routes.wordScrambleName),
            ),
            const SizedBox(height: AppSpacing.md),
            _GameTile(
              emoji: '🃏',
              title: 'Flashcard Flip',
              subtitle: 'Match Italian words to English',
              color: AppColors.tertiary,
              onTap: () => context.pushNamed(Routes.flashcardName),
            ),
            const SizedBox(height: AppSpacing.md),
            _GameTile(
              emoji: '📝',
              title: 'Fill in the Blank',
              subtitle: 'Complete the Italian sentence',
              color: AppColors.secondary,
              onTap: () => context.pushNamed(Routes.fillBlankName),
            ),
            const SizedBox(height: AppSpacing.md),
            _GameTile(
              emoji: '😀',
              title: 'Emoji Match',
              subtitle: 'Match words to their emoji',
              color: AppColors.accent,
              onTap: () => context.pushNamed(Routes.emojiMatchName),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Material(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: text.titleLarge),
                    const SizedBox(height: 2),
                    Text(subtitle, style: text.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.play_arrow_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
