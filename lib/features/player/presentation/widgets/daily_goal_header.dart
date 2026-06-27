import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controllers/player_controller.dart';
import 'avatar_view.dart';

/// Home header: avatar, greeting, daily-goal ring, streak, and coin wallet.
class DailyGoalHeader extends StatelessWidget {
  const DailyGoalHeader({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final PlayerController p = context.watch<PlayerController>();
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                onTap: () => context.pushNamed(Routes.avatarName),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: AvatarView(player: p, size: 56),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Ciao, $name! 👋', style: text.headlineSmall),
                    Text(
                      p.goalMet ? 'Goal complete — bravo! 🎉' : 'Tap your avatar to customize',
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(child: _GoalRing(p: p)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatBox(
                  emoji: '🔥',
                  value: '${p.streakDays}',
                  label: p.streakDays == 1 ? 'day streak' : 'day streak',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatBox(
                  emoji: '🪙',
                  value: '${p.coins}',
                  label: 'coins',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.p});
  final PlayerController p;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 46,
            width: 46,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  value: p.goalProgress,
                  strokeWidth: 5,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                Text('${p.todayXp}', style: text.labelLarge),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text('/${PlayerController.dailyGoal} XP', style: text.labelMedium),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.emoji, required this.value, required this.label, required this.color});
  final String emoji;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 22)),
          Text(value, style: text.titleLarge),
          Text(label, style: text.labelMedium),
        ],
      ),
    );
  }
}
