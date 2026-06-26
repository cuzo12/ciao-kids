import 'package:equatable/equatable.dart';

import 'chat_message.dart';

/// The tutor's reaction to a child's turn, produced by an [AiTutorEngine].
///
/// It is a pure value: the [messages] to append, whether the child was
/// [understood], where the conversation goes next ([nextStepIndex]), whether it
/// is [finished], and the [suggestions] to offer for the new current step.
class TutorResponse extends Equatable {
  /// Creates a [TutorResponse].
  const TutorResponse({
    required this.messages,
    required this.understood,
    required this.nextStepIndex,
    required this.finished,
    required this.suggestions,
  });

  /// Tutor message(s) to append to the transcript.
  final List<ChatMessage> messages;

  /// Whether the child's utterance was accepted.
  final bool understood;

  /// The step index the conversation should now be on.
  final int nextStepIndex;

  /// Whether the conversation has ended.
  final bool finished;

  /// Suggested example replies for the new current step.
  final List<String> suggestions;

  @override
  List<Object?> get props =>
      <Object?>[messages, understood, nextStepIndex, finished, suggestions];
}
