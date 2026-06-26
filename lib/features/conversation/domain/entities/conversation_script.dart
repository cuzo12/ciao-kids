import 'package:equatable/equatable.dart';

import 'conversation_step.dart';

/// A complete, authored conversation a child can have with a character.
///
/// The flow is: [intro] → each [ConversationStep] in [steps] → [closing]. This
/// is the structured "lesson plan" the [AiTutorEngine] follows; a future
/// Claude-backed engine can use the same script as grounding/guardrails.
class ConversationScript extends Equatable {
  /// Creates a [ConversationScript].
  const ConversationScript({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.characterName,
    required this.characterEmoji,
    required this.intro,
    required this.introEnglish,
    required this.steps,
    required this.closing,
    required this.closingEnglish,
  });

  /// Stable id used in routes.
  final String id;

  /// Display title (e.g. "Saluti — Greetings").
  final String title;

  /// One-line description for the chooser.
  final String subtitle;

  /// Guiding character's name.
  final String characterName;

  /// Guiding character's emoji avatar.
  final String characterEmoji;

  /// The tutor's opening Italian line.
  final String intro;

  /// English hint for the opening line.
  final String introEnglish;

  /// The ordered exchanges.
  final List<ConversationStep> steps;

  /// The tutor's Italian farewell.
  final String closing;

  /// English hint for the farewell.
  final String closingEnglish;

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        subtitle,
        characterName,
        characterEmoji,
        intro,
        introEnglish,
        steps,
        closing,
        closingEnglish,
      ];
}
