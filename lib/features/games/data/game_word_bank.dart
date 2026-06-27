/// Word bank shared across the mini-games.
///
/// Tuned for 10–12 year olds: slightly more challenging than the beginner
/// lesson vocabulary, with sentence-level context for Fill in the Blank.
class GameWord {
  const GameWord({
    required this.italian,
    required this.english,
    required this.emoji,
    this.sentence,
    this.sentenceAnswer,
  });

  final String italian;
  final String english;
  final String emoji;

  /// An Italian sentence with a blank (_____) where [sentenceAnswer] fits.
  final String? sentence;

  /// The correct word for the sentence blank.
  final String? sentenceAnswer;
}

abstract final class GameWordBank {
  static const List<GameWord> beginner = <GameWord>[
    GameWord(italian: 'Ciao', english: 'Hello', emoji: '👋',
        sentence: '_____, come stai?', sentenceAnswer: 'Ciao'),
    GameWord(italian: 'Grazie', english: 'Thank you', emoji: '🙏',
        sentence: '_____ mille!', sentenceAnswer: 'Grazie'),
    GameWord(italian: 'Gatto', english: 'Cat', emoji: '🐱',
        sentence: 'Il _____ dorme sul divano.', sentenceAnswer: 'gatto'),
    GameWord(italian: 'Cane', english: 'Dog', emoji: '🐕',
        sentence: 'Il _____ gioca nel parco.', sentenceAnswer: 'cane'),
    GameWord(italian: 'Acqua', english: 'Water', emoji: '💧',
        sentence: 'Vorrei un bicchiere di _____.', sentenceAnswer: 'acqua'),
    GameWord(italian: 'Pane', english: 'Bread', emoji: '🍞',
        sentence: 'Compriamo il _____ fresco.', sentenceAnswer: 'pane'),
    GameWord(italian: 'Libro', english: 'Book', emoji: '📚',
        sentence: 'Leggo un _____ interessante.', sentenceAnswer: 'libro'),
    GameWord(italian: 'Casa', english: 'House', emoji: '🏠',
        sentence: 'Torno a _____ dopo scuola.', sentenceAnswer: 'casa'),
    GameWord(italian: 'Sole', english: 'Sun', emoji: '☀️',
        sentence: 'Il _____ splende oggi.', sentenceAnswer: 'sole'),
    GameWord(italian: 'Luna', english: 'Moon', emoji: '🌙',
        sentence: 'La _____ è piena stasera.', sentenceAnswer: 'luna'),
  ];

  static const List<GameWord> intermediate = <GameWord>[
    GameWord(italian: 'Zaino', english: 'Backpack', emoji: '🎒',
        sentence: 'Metto i libri nello _____.', sentenceAnswer: 'zaino'),
    GameWord(italian: 'Orologio', english: 'Watch/Clock', emoji: '⌚',
        sentence: "L'_____ segna le tre.", sentenceAnswer: 'orologio'),
    GameWord(italian: 'Pioggia', english: 'Rain', emoji: '🌧️',
        sentence: 'Prendi l\'ombrello, c\'è _____.', sentenceAnswer: 'pioggia'),
    GameWord(italian: 'Gelato', english: 'Ice cream', emoji: '🍨',
        sentence: 'Voglio un _____ al cioccolato.', sentenceAnswer: 'gelato'),
    GameWord(italian: 'Spiaggia', english: 'Beach', emoji: '🏖️',
        sentence: 'Andiamo in _____ questa estate.', sentenceAnswer: 'spiaggia'),
    GameWord(italian: 'Amico', english: 'Friend', emoji: '🤝',
        sentence: 'Marco è il mio miglior _____.', sentenceAnswer: 'amico'),
    GameWord(italian: 'Compiti', english: 'Homework', emoji: '📝',
        sentence: 'Devo fare i _____ di matematica.', sentenceAnswer: 'compiti'),
    GameWord(italian: 'Calcio', english: 'Soccer', emoji: '⚽',
        sentence: 'Giochiamo a _____ dopo pranzo.', sentenceAnswer: 'calcio'),
    GameWord(italian: 'Cucina', english: 'Kitchen', emoji: '🍳',
        sentence: 'La mamma cucina in _____.', sentenceAnswer: 'cucina'),
    GameWord(italian: 'Giardino', english: 'Garden', emoji: '🌻',
        sentence: 'I fiori crescono nel _____.', sentenceAnswer: 'giardino'),
  ];

  static const List<GameWord> advanced = <GameWord>[
    GameWord(italian: 'Biglietto', english: 'Ticket', emoji: '🎫',
        sentence: 'Ho comprato un _____ per il treno.', sentenceAnswer: 'biglietto'),
    GameWord(italian: 'Prenotazione', english: 'Reservation', emoji: '📋',
        sentence: 'Ho una _____ per le otto.', sentenceAnswer: 'prenotazione'),
    GameWord(italian: 'Biblioteca', english: 'Library', emoji: '🏛️',
        sentence: 'Studio in _____ il pomeriggio.', sentenceAnswer: 'biblioteca'),
    GameWord(italian: 'Viaggio', english: 'Trip', emoji: '✈️',
        sentence: 'Facciamo un _____ in Sicilia.', sentenceAnswer: 'viaggio'),
    GameWord(italian: 'Ristorante', english: 'Restaurant', emoji: '🍽️',
        sentence: 'Ceniamo al _____ stasera.', sentenceAnswer: 'ristorante'),
    GameWord(italian: 'Purtroppo', english: 'Unfortunately', emoji: '😕',
        sentence: '_____ non posso venire.', sentenceAnswer: 'Purtroppo'),
    GameWord(italian: 'Bellissimo', english: 'Very beautiful', emoji: '😍',
        sentence: 'Il tramonto è _____.', sentenceAnswer: 'bellissimo'),
    GameWord(italian: 'Gentile', english: 'Kind', emoji: '😊',
        sentence: 'La maestra è molto _____.', sentenceAnswer: 'gentile'),
    GameWord(italian: 'Provare', english: 'To try', emoji: '💪',
        sentence: 'Devi _____ ancora una volta.', sentenceAnswer: 'provare'),
    GameWord(italian: 'Ricordare', english: 'To remember', emoji: '🧠',
        sentence: 'Devo _____ la password.', sentenceAnswer: 'ricordare'),
  ];
}
