import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/chat_message.dart';

/// A single chat bubble for a tutor or child [ChatMessage].
///
/// Tutor bubbles sit on the left with the character avatar, the Italian line, a
/// small English hint, and a tap-to-replay speaker. Child bubbles sit on the
/// right in the brand color. Correction bubbles get a warm accent treatment.
class ChatBubble extends StatelessWidget {
  /// Creates a [ChatBubble].
  const ChatBubble({
    required this.message,
    required this.characterEmoji,
    required this.onReplay,
    super.key,
  });

  /// The message to render.
  final ChatMessage message;

  /// The tutor character's emoji (shown beside tutor bubbles).
  final String characterEmoji;

  /// Called when the tutor bubble's replay button is tapped.
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final bool isTutor = message.isTutor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment:
            isTutor ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (isTutor) ...<Widget>[
            Text(characterEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: isTutor
                ? _TutorBubble(message: message, onReplay: onReplay)
                : _ChildBubble(message: message),
          ),
        ],
      ),
    );
  }
}

class _TutorBubble extends StatelessWidget {
  const _TutorBubble({required this.message, required this.onReplay});

  final ChatMessage message;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool correction = message.isCorrection;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: correction
            ? AppColors.accent.withValues(alpha: 0.18)
            : scheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusSm),
          topRight: Radius.circular(AppSpacing.radiusLg),
          bottomLeft: Radius.circular(AppSpacing.radiusLg),
          bottomRight: Radius.circular(AppSpacing.radiusLg),
        ),
        border: correction
            ? Border.all(color: AppColors.accent, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(child: Text(message.text, style: text.titleMedium)),
              const SizedBox(width: AppSpacing.xs),
              InkWell(
                onTap: onReplay,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.volume_up_rounded,
                      size: 20, color: AppColors.tertiary),
                ),
              ),
            ],
          ),
          if (message.translation != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              message.translation!,
              style: text.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChildBubble extends StatelessWidget {
  const _ChildBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusLg),
          topRight: Radius.circular(AppSpacing.radiusSm),
          bottomLeft: Radius.circular(AppSpacing.radiusLg),
          bottomRight: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Text(
        message.text,
        style: text.titleMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}
