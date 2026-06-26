import 'package:equatable/equatable.dart';

import 'quiz_question.dart';
import 'vocabulary_item.dart';

/// One step in a lesson's flow.
///
/// Modeled as a **sealed** hierarchy so the player can exhaustively `switch`
/// over the concrete stage types to pick the right view, with the compiler
/// guaranteeing no stage kind is forgotten. The brief's lesson structure maps
/// to these types: Introduction → Vocabulary → Pronunciation → Mini-game
/// (Match) → Quiz → Review. (Conversation arrives with the AI milestone.)
sealed class LessonStage extends Equatable {
  /// Const base constructor.
  const LessonStage();

  /// Short label for the stage indicator (e.g. "Words", "Quiz").
  String get title;

  @override
  List<Object?> get props => const <Object?>[];
}

/// Opening stage: a character welcomes the child and states the goal.
final class IntroStage extends LessonStage {
  /// Creates an [IntroStage].
  const IntroStage({
    required this.characterName,
    required this.characterEmoji,
    required this.greeting,
    required this.goal,
  });

  /// Name of the guiding character (e.g. "Luca").
  final String characterName;

  /// Emoji avatar for the character.
  final String characterEmoji;

  /// The character's welcoming line.
  final String greeting;

  /// What the child will learn in this lesson.
  final String goal;

  @override
  String get title => 'Intro';

  @override
  List<Object?> get props =>
      <Object?>[characterName, characterEmoji, greeting, goal];
}

/// Vocabulary stage: flashcards for each new word.
final class VocabularyStage extends LessonStage {
  /// Creates a [VocabularyStage].
  const VocabularyStage(this.items);

  /// The words taught in this lesson.
  final List<VocabularyItem> items;

  @override
  String get title => 'Words';

  @override
  List<Object?> get props => <Object?>[items];
}

/// Pronunciation stage: listen-and-repeat practice for each word.
final class PronunciationStage extends LessonStage {
  /// Creates a [PronunciationStage].
  const PronunciationStage(this.items);

  /// The words to practice saying aloud.
  final List<VocabularyItem> items;

  @override
  String get title => 'Say it';

  @override
  List<Object?> get props => <Object?>[items];
}

/// Mini-game stage: match Italian words to their English meanings.
final class MatchStage extends LessonStage {
  /// Creates a [MatchStage].
  const MatchStage(this.pairs);

  /// The word pairs to match.
  final List<VocabularyItem> pairs;

  @override
  String get title => 'Match';

  @override
  List<Object?> get props => <Object?>[pairs];
}

/// Quiz stage: multiple-choice questions that determine the lesson score.
final class QuizStage extends LessonStage {
  /// Creates a [QuizStage].
  const QuizStage(this.questions);

  /// The quiz questions.
  final List<QuizQuestion> questions;

  @override
  String get title => 'Quiz';

  @override
  List<Object?> get props => <Object?>[questions];
}

/// Closing stage: celebrate, show the score, and award rewards.
final class ReviewStage extends LessonStage {
  /// Creates a [ReviewStage].
  const ReviewStage({required this.message});

  /// An encouraging wrap-up message.
  final String message;

  @override
  String get title => 'Review';

  @override
  List<Object?> get props => <Object?>[message];
}
