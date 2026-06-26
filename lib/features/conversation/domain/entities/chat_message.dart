import 'package:equatable/equatable.dart';

/// Who sent a chat message.
enum MessageSender {
  /// The AI tutor / character.
  tutor,

  /// The child.
  child,
}

/// A single message in a tutor↔child conversation.
///
/// Tutor messages carry Italian [text] plus an optional English [translation]
/// hint; child messages carry the recognized/typed transcript. [isCorrection]
/// flags a gentle-correction line so the UI can style it distinctly.
class ChatMessage extends Equatable {
  /// Creates a [ChatMessage].
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.translation,
    this.isCorrection = false,
  });

  /// Unique id (used as a list key).
  final String id;

  /// Who sent it.
  final MessageSender sender;

  /// The message body (Italian for the tutor; transcript for the child).
  final String text;

  /// Optional English hint shown under tutor lines.
  final String? translation;

  /// Whether this is a gentle correction (affects styling).
  final bool isCorrection;

  /// Convenience: whether the tutor sent this message.
  bool get isTutor => sender == MessageSender.tutor;

  @override
  List<Object?> get props => <Object?>[id, sender, text, translation, isCorrection];
}
