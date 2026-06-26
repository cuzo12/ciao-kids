import 'package:equatable/equatable.dart';

/// A single multiple-choice quiz question.
///
/// The [options] are presented as tappable answers; [correctIndex] identifies
/// the right one. Pure domain data — scoring lives in the lesson player, not
/// here.
class QuizQuestion extends Equatable {
  /// Creates a [QuizQuestion]. Asserts the correct index is within [options].
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation,
  }) : assert(correctIndex >= 0, 'correctIndex must be non-negative');

  /// The question text shown to the child.
  final String prompt;

  /// The available answers.
  final List<String> options;

  /// Index into [options] of the correct answer.
  final int correctIndex;

  /// Optional one-line teaching note shown after answering.
  final String? explanation;

  /// The text of the correct answer.
  String get correctAnswer => options[correctIndex];

  /// Whether the option at [index] is the correct one.
  bool isCorrect(int index) => index == correctIndex;

  @override
  List<Object?> get props => <Object?>[prompt, options, correctIndex, explanation];
}
