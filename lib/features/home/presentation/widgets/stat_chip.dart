import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// A compact pill showing a single gamification stat (coins, XP, or streak).
///
/// Used in the home dashboard header. The [color] tints both the icon and the
/// pill background so each stat reads at a glance.
class StatChip extends StatelessWidget {
  /// Creates a [StatChip].
  const StatChip({
    required this.icon,
    required this.label,
    required this.color,
    super.key,
  });

  /// Leading glyph (e.g. a coin or flame).
  final IconData icon;

  /// The value text (e.g. "120").
  final String label;

  /// Accent color for the icon and background tint.
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
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: text.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
