import 'package:equatable/equatable.dart';

import 'story_choice.dart';

/// A single scene in an interactive story.
class StoryNode extends Equatable {
  /// Creates a [StoryNode].
  const StoryNode({
    required this.id,
    required this.emoji,
    required this.narrationItalian,
    required this.narrationEnglish,
    this.choices = const <StoryChoice>[],
    this.isEnding = false,
  });

  /// Stable node id (referenced by [StoryChoice.nextNodeId]).
  final String id;

  /// A large scene emoji.
  final String emoji;

  /// The scene narration in Italian.
  final String narrationItalian;

  /// English translation of the narration.
  final String narrationEnglish;

  /// Branches out of this scene (empty for endings).
  final List<StoryChoice> choices;

  /// Whether this node ends the story.
  final bool isEnding;

  @override
  List<Object?> get props =>
      <Object?>[id, emoji, narrationItalian, narrationEnglish, choices, isEnding];
}
