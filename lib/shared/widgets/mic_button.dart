import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A large circular microphone button with a pulsing "listening" animation.
///
/// Shared by the conversation and pronunciation features.
class MicButton extends StatefulWidget {
  /// Creates a [MicButton].
  const MicButton({
    required this.listening,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  /// Whether the mic is currently capturing.
  final bool listening;

  /// Whether the button is interactive.
  final bool enabled;

  /// Tap handler (start/stop listening).
  final VoidCallback onTap;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.listening) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listening && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.listening && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color =
        widget.listening ? AppColors.secondary : AppColors.primary;

    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (BuildContext context, Widget? child) {
          final double scale = 1 + (_pulse.value * 0.12);
          return Opacity(
            opacity: widget.enabled ? 1 : 0.4,
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            widget.listening ? Icons.stop_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
