import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// The Ciao Kids wordmark/logo.
///
/// Rendered entirely in code (no image asset required for Milestone 1): a
/// rounded "speech bubble" badge with a waving-hand glyph and the product name.
/// [size] scales the whole lockup; [showWordmark] toggles the text label.
class AppLogo extends StatelessWidget {
  /// Creates an [AppLogo].
  const AppLogo({this.size = 96, this.showWordmark = true, super.key});

  /// Diameter of the circular badge in logical pixels.
  final double size;

  /// Whether to render the "Ciao Kids" text beneath the badge.
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text('👋', style: TextStyle(fontSize: size * 0.5)),
        ),
        if (showWordmark) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Text('Ciao Kids', style: text.displayMedium),
          Text(
            'Learn Italian by talking',
            style: text.bodyMedium,
          ),
        ],
      ],
    );
  }
}
