import '../../lessons/domain/entities/vocabulary_item.dart';

/// A curated set of words for pronunciation practice.
///
/// Reuses the shared [VocabularyItem] model. Words are chosen to cover a range
/// of Italian sounds (double consonants, "gli", "cci", "gn") with clear,
/// hyphen-separated syllables in [VocabularyItem.pronunciation].
abstract final class PronunciationWordBank {
  /// The default drill set.
  static const List<VocabularyItem> words = <VocabularyItem>[
    VocabularyItem(
        italian: 'Buongiorno',
        english: 'Good morning',
        emoji: '☀️',
        pronunciation: 'bwon-JOR-no'),
    VocabularyItem(
        italian: 'Grazie',
        english: 'Thank you',
        emoji: '🙏',
        pronunciation: 'GRAH-tsyeh'),
    VocabularyItem(
        italian: 'Gelato',
        english: 'Ice cream',
        emoji: '🍨',
        pronunciation: 'jeh-LAH-to'),
    VocabularyItem(
        italian: 'Famiglia',
        english: 'Family',
        emoji: '👨‍👩‍👧',
        pronunciation: 'fa-MEE-lya'),
    VocabularyItem(
        italian: 'Cioccolato',
        english: 'Chocolate',
        emoji: '🍫',
        pronunciation: 'chok-ko-LAH-to'),
    VocabularyItem(
        italian: 'Spaghetti',
        english: 'Spaghetti',
        emoji: '🍝',
        pronunciation: 'spa-GHET-tee'),
    VocabularyItem(
        italian: 'Arrivederci',
        english: 'Goodbye',
        emoji: '👋',
        pronunciation: 'ah-ree-veh-DEHR-chee'),
    VocabularyItem(
        italian: 'Coniglio',
        english: 'Rabbit',
        emoji: '🐰',
        pronunciation: 'ko-NEE-lyo'),
  ];
}
