import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// A horizontal wrap of tappable suggested replies.
///
/// Gives children who can't or don't want to speak/type a one-tap way to answer
/// — and doubles as a scaffold of correct phrasing.
class SuggestionChips extends StatelessWidget {
  /// Creates [SuggestionChips].
  const SuggestionChips({
    required this.suggestions,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  /// The example replies to show.
  final List<String> suggestions;

  /// Called with the chosen suggestion.
  final ValueChanged<String> onTap;

  /// Whether the chips are tappable.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    final TextTheme text = Theme.of(context).textTheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final String suggestion in suggestions)
          ActionChip(
            label: Text(suggestion, style: text.labelMedium),
            onPressed: enabled ? () => onTap(suggestion) : null,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
      ],
    );
  }
}
