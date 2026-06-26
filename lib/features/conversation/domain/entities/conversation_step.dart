import 'package:equatable/equatable.dart';

/// One exchange in a scripted conversation: the tutor asks, the child answers.
///
/// [expectedAnswers] are normalized keyword fragments any of which counts as a
/// correct reply (lenient matching suits speech recognition and young
/// spellers). [suggestions] are tappable example phrases shown to the child and
/// double as the model answer revealed after too many misses.
class ConversationStep extends Equatable {
  /// Creates a [ConversationStep].
  const ConversationStep({
    required this.tutorItalian,
    required this.tutorEnglish,
    required this.expectedAnswers,
    required this.suggestions,
    required this.successReply,
    required this.retryHint,
  });

  /// The tutor's Italian prompt/question.
  final String tutorItalian;

  /// English hint for the prompt.
  final String tutorEnglish;

  /// Acceptable answer fragments (matched leniently, case/accent-insensitive).
  final List<String> expectedAnswers;

  /// Tappable example replies for the child.
  final List<String> suggestions;

  /// The tutor's Italian praise when the child answers acceptably.
  final String successReply;

  /// A gentle Italian/English nudge when the child misses.
  final String retryHint;

  @override
  List<Object?> get props => <Object?>[
        tutorItalian,
        tutorEnglish,
        expectedAnswers,
        suggestions,
        successReply,
        retryHint,
      ];
}
