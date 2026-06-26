import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/lesson_stage.dart';

/// Renders an [IntroStage]: a character welcomes the child and states the goal.
class IntroStageView extends StatelessWidget {
  /// Creates an [IntroStageView].
  const IntroStageView({required this.stage, super.key});

  /// The intro data to display.
  final IntroStage stage;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 120,
              width: 120,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                stage.characterEmoji,
                style: const TextStyle(fontSize: 64),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(stage.characterName, style: text.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Text(
                stage.greeting,
                textAlign: TextAlign.center,
                style: text.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('🎯', style: TextStyle(fontSize: 22)),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(stage.goal, style: text.bodyLarge),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
