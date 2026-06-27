/// Sentences for the Sentence Builder game, roughly easy → harder.
///
/// The game scrambles the Italian words and the child taps them into order.
/// Sentences reuse vocabulary and verbs taught elsewhere, so building them
/// reinforces both words and Italian word order — the bridge to real speaking.
class SentenceItem {
  const SentenceItem(this.italian, this.english, [this.emoji = '']);
  final String italian;
  final String english;
  final String emoji;

  /// The Italian words as ordered tiles (punctuation stripped).
  List<String> get words =>
      italian.replaceAll(RegExp('[?!.,]'), '').split(' ').where((String w) => w.isNotEmpty).toList();
}

abstract final class SentenceBank {
  static const List<SentenceItem> sentences = <SentenceItem>[
    SentenceItem('Mi chiamo Luca', 'My name is Luca', '🏷️'),
    SentenceItem('Ho dieci anni', "I'm ten years old", '🎂'),
    SentenceItem('Voglio una pizza', 'I want a pizza', '🍕'),
    SentenceItem('Il gatto è nero', 'The cat is black', '🐱'),
    SentenceItem('Mangio una mela', 'I eat an apple', '🍎'),
    SentenceItem('Mi piace il gelato', 'I like ice cream', '🍨'),
    SentenceItem('Vado a scuola', 'I go to school', '🏫'),
    SentenceItem('La casa è grande', 'The house is big', '🏠'),
    SentenceItem('Oggi fa caldo', "Today it's hot", '🥵'),
    SentenceItem('Tu parli italiano', 'You speak Italian', '🗣️'),
    SentenceItem('Noi mangiamo la pasta', 'We eat pasta', '🍝'),
    SentenceItem('Voglio bere acqua', 'I want to drink water', '💧'),
    SentenceItem('Il cane corre nel parco', 'The dog runs in the park', '🐕'),
    SentenceItem('Lei ha un fratello', 'She has a brother', '👦'),
    SentenceItem('Andiamo alla spiaggia', "We're going to the beach", '🏖️'),
    SentenceItem('Posso andare in bagno', 'Can I go to the bathroom', '🚻'),
    SentenceItem('Vorrei un caffè per favore', 'I would like a coffee please', '☕'),
    SentenceItem('Il mio colore preferito è blu', 'My favorite color is blue', '🔵'),
    SentenceItem('Ho un cane e un gatto', 'I have a dog and a cat', '🐾'),
    SentenceItem('Dove è la stazione', 'Where is the station', '🚉'),
  ];
}
