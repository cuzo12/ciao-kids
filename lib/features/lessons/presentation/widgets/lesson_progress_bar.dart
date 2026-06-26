import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// A rounded progress bar with a "Stage X of Y" label, shown atop the player.
class LessonProgressBar extends StatelessWidget {
  /// Creates a [LessonProgressBar].
  const LessonProgressBar({
    required this.value,
    required this.label,
    super.key,
  });

  /// Completion fraction in the range 0–1.
  final double value;

  /// Caption shown beside the bar (e.g. "Stage 2 of 6").
  final String label;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: text.labelMedium),
      ],
    );
  }
}
