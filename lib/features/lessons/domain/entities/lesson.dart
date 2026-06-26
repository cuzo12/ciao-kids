import 'package:equatable/equatable.dart';

import 'lesson_stage.dart';
import 'quiz_question.dart';
import 'vocabulary_item.dart';

/// A complete, ordered lesson.
///
/// A lesson is metadata ([title], [emoji], [order]) plus an ordered list of
/// [stages] the child works through. Use the [Lesson.standard] factory to build
/// a lesson with the conventional stage sequence so authored content stays
/// compact and consistent.
class Lesson extends Equatable {
  /// Creates a [Lesson] with an explicit stage list.
  const Lesson({
    required this.id,
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.order,
    required this.stages,
  });

  /// Stable identifier used in routes and progress storage (e.g. "greetings").
  final String id;

  /// Display name (e.g. "Greetings").
  final String title;

  /// Emoji shown on the lesson card.
  final String emoji;

  /// One-line description shown under the title.
  final String subtitle;

  /// Sequence position; controls the unlock order (lower unlocks first).
  final int order;

  /// The ordered stages that make up the lesson.
  final List<LessonStage> stages;

  /// Builds a lesson with the standard stage flow:
  /// Intro → Vocabulary → Pronunciation → Match → Quiz → Review.
  ///
  /// The pronunciation and match stages reuse [vocabulary] (the match game uses
  /// the first [matchCount] items) so a lesson is authored from a single word
  /// list plus its quiz.
  factory Lesson.standard({
    required String id,
    required String title,
    required String emoji,
    required String subtitle,
    required int order,
    required String characterName,
    required String characterEmoji,
    required String greeting,
    required String goal,
    required List<VocabularyItem> vocabulary,
    required List<QuizQuestion> quiz,
    required String reviewMessage,
    int matchCount = 4,
  }) {
    final List<VocabularyItem> matchItems =
        vocabulary.take(matchCount).toList(growable: false);

    return Lesson(
      id: id,
      title: title,
      emoji: emoji,
      subtitle: subtitle,
      order: order,
      stages: <LessonStage>[
        IntroStage(
          characterName: characterName,
          characterEmoji: characterEmoji,
          greeting: greeting,
          goal: goal,
        ),
        VocabularyStage(vocabulary),
        PronunciationStage(vocabulary),
        MatchStage(matchItems),
        QuizStage(quiz),
        ReviewStage(message: reviewMessage),
      ],
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[id, title, emoji, subtitle, order, stages];
}
