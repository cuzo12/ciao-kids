import 'package:equatable/equatable.dart';

/// A single word/phrase taught in a lesson.
///
/// Holds everything the UI needs to present a word across stages: the Italian
/// term, its English meaning, an [emoji] cue for pre-readers, and a simple
/// [pronunciation] respelling (e.g. "CHOW" for "Ciao"). Real audio is added in
/// the speech milestone; until then [pronunciation] is the spoken-form hint.
class VocabularyItem extends Equatable {
  /// Creates a [VocabularyItem].
  const VocabularyItem({
    required this.italian,
    required this.english,
    required this.emoji,
    required this.pronunciation,
  });

  /// The Italian word or phrase (e.g. "Buongiorno").
  final String italian;

  /// The English meaning (e.g. "Good morning").
  final String english;

  /// A visual cue suitable for young, pre-literate learners.
  final String emoji;

  /// Phonetic respelling hint (e.g. "bwon-JOR-no").
  final String pronunciation;

  @override
  List<Object?> get props => <Object?>[italian, english, emoji, pronunciation];
}
