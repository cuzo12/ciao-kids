import 'package:flutter/material.dart';

/// A full-screen decorative background with soft, blurred color "blobs".
///
/// Provides the bright, playful backdrop used on the splash and auth screens
/// while keeping content fully legible. The blobs are tinted with the current
/// theme's primary/secondary/tertiary colors so it adapts to light and dark
/// mode automatically.
class GradientBackground extends StatelessWidget {
  /// Creates a [GradientBackground] wrapping [child].
  const GradientBackground({required this.child, super.key});

  /// Foreground content rendered above the decorative layer.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: ColoredBox(color: scheme.surface),
        ),
        Positioned(
          top: -90,
          left: -60,
          child: _Blob(color: scheme.primary, size: 240),
        ),
        Positioned(
          top: 120,
          right: -80,
          child: _Blob(color: scheme.tertiary, size: 200),
        ),
        Positioned(
          bottom: -100,
          left: -40,
          child: _Blob(color: scheme.secondary, size: 260),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

/// A single soft, semi-transparent circular blob.
class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.18),
      ),
    );
  }
}
