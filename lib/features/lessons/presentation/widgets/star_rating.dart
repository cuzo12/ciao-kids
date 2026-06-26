import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A row of filled/empty stars showing an earned rating out of [max].
class StarRating extends StatelessWidget {
  /// Creates a [StarRating].
  const StarRating({
    required this.stars,
    this.max = 3,
    this.size = 24,
    this.color = AppColors.accent,
    super.key,
  });

  /// Number of filled stars.
  final int stars;

  /// Total number of stars to render.
  final int max;

  /// Icon size in logical pixels.
  final double size;

  /// Color of filled stars (empty stars use a muted version).
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < max; i++)
          Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < stars ? color : color.withValues(alpha: 0.3),
            size: size,
          ),
      ],
    );
  }
}
