import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// A large, rounded, kid-friendly primary action button.
///
/// Supports an inline [isLoading] state (showing a spinner and disabling taps),
/// an optional leading [icon], and a [secondary] visual style for lower-emphasis
/// actions. Built on top of the global `elevatedButtonTheme` so styling stays
/// centralized.
class PrimaryButton extends StatelessWidget {
  /// Creates a primary button.
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.secondary = false,
    super.key,
  });

  /// The button text.
  final String label;

  /// Tap callback. When `null` (or while [isLoading]), the button is disabled.
  final VoidCallback? onPressed;

  /// When `true`, shows a spinner and ignores taps.
  final bool isLoading;

  /// Optional leading icon.
  final IconData? icon;

  /// When `true`, uses the secondary (coral) color.
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;

    return SizedBox(
      height: AppSpacing.buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: secondary
            ? ElevatedButton.styleFrom(backgroundColor: AppColors.secondary)
            : null,
        child: isLoading
            ? const SizedBox(
                height: 26,
                width: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
