/// 30-day structured curriculum: 3 levels × 10 days.
///
/// Each day is ~20 minutes: vocabulary review + a practice game + a short
/// conversation prompt + a quiz. Days unlock sequentially within each level;
/// levels unlock when all 10 days of the prior level are complete.

class CurriculumDay {
  const CurriculumDay({
    required this.day,
    required this.level,
    required this.title,
    required this.emoji,
    required this.vocabWords,
    required this.gameName,
    required this.conversationPrompt,
    required this.quizQuestions,
  });

  final int day;
  final int level;
  final String title;
  final String emoji;
  final List<VocabPair> vocabWords;
  final String gameName;
  final String conversationPrompt;
  final List<CurrQuizQ> quizQuestions;
}

class VocabPair {
  const VocabPair(this.italian, this.english, this.emoji);
  final String italian;
  final String english;
  final String emoji;
}

class CurrQuizQ {
  const CurrQuizQ(this.prompt, this.options, this.correctIndex);
  final String prompt;
  final List<String> options;
  final int correctIndex;
}

abstract final class CurriculumData {
  static const List<CurriculumDay> days = <CurriculumDay>[
    // ═══════════ LEVEL 1: Basics (Days 1–10) ═══════════
    CurriculumDay(day: 1, level: 1, title: 'Greetings & Introductions', emoji: '👋',
      vocabWords: <VocabPair>[
        VocabPair('Ciao', 'Hi / Bye', '👋'), VocabPair('Buongiorno', 'Good morning', '☀️'),
        VocabPair('Come stai?', 'How are you?', '🤔'), VocabPair('Sto bene', "I'm fine", '😊'),
        VocabPair('Mi chiamo…', 'My name is…', '🏷️'), VocabPair('Piacere', 'Nice to meet you', '🤝'),
      ], gameName: 'flashcard', conversationPrompt: 'Introduce yourself in Italian.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Come stai?' means…", <String>['How old are you?', 'How are you?', 'Where are you?', 'Who are you?'], 1),
        CurrQuizQ("Say 'Nice to meet you':", <String>['Grazie', 'Piacere', 'Ciao', 'Buonasera'], 1),
      ]),
    CurriculumDay(day: 2, level: 1, title: 'Numbers 1–20', emoji: '🔢',
      vocabWords: <VocabPair>[
        VocabPair('Uno', '1', '1️⃣'), VocabPair('Cinque', '5', '5️⃣'),
        VocabPair('Dieci', '10', '🔟'), VocabPair('Quindici', '15', '🔢'),
        VocabPair('Venti', '20', '✌️'), VocabPair('Dodici', '12', '🕛'),
      ], gameName: 'word_scramble', conversationPrompt: 'Count to 20 and say your age.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Quindici' means…", <String>['12', '15', '50', '20'], 1),
        CurrQuizQ("How do you say '20'?", <String>['Dieci', 'Dodici', 'Venti', 'Trenta'], 2),
      ]),
    CurriculumDay(day: 3, level: 1, title: 'Colors', emoji: '🎨',
      vocabWords: <VocabPair>[
        VocabPair('Rosso', 'Red', '🔴'), VocabPair('Blu', 'Blue', '🔵'),
        VocabPair('Verde', 'Green', '🟢'), VocabPair('Giallo', 'Yellow', '🟡'),
        VocabPair('Nero', 'Black', '⚫'), VocabPair('Bianco', 'White', '⚪'),
      ], gameName: 'emoji_match', conversationPrompt: 'Describe the colors in your room.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Verde' is…", <String>['Red', 'Green', 'Yellow', 'Blue'], 1),
        CurrQuizQ("What color is 'Giallo'?", <String>['Black', 'White', 'Yellow', 'Green'], 2),
      ]),
    CurriculumDay(day: 4, level: 1, title: 'Animals', emoji: '🐾',
      vocabWords: <VocabPair>[
        VocabPair('Gatto', 'Cat', '🐱'), VocabPair('Cane', 'Dog', '🐕'),
        VocabPair('Uccello', 'Bird', '🐦'), VocabPair('Pesce', 'Fish', '🐟'),
        VocabPair('Cavallo', 'Horse', '🐴'), VocabPair('Coniglio', 'Rabbit', '🐰'),
      ], gameName: 'emoji_match', conversationPrompt: 'Talk about your favorite animal.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("A 'Coniglio' is a…", <String>['Cat', 'Dog', 'Rabbit', 'Fish'], 2),
        CurrQuizQ("'Uccello' means…", <String>['Horse', 'Bird', 'Cat', 'Fish'], 1),
      ]),
    CurriculumDay(day: 5, level: 1, title: 'Food & Drinks', emoji: '🍕',
      vocabWords: <VocabPair>[
        VocabPair('Pizza', 'Pizza', '🍕'), VocabPair('Pasta', 'Pasta', '🍝'),
        VocabPair('Acqua', 'Water', '💧'), VocabPair('Latte', 'Milk', '🥛'),
        VocabPair('Frutta', 'Fruit', '🍎'), VocabPair('Pane', 'Bread', '🍞'),
      ], gameName: 'fill_blank', conversationPrompt: 'Order your favorite food in Italian.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Latte' means…", <String>['Water', 'Juice', 'Milk', 'Coffee'], 2),
        CurrQuizQ("How do you say 'bread'?", <String>['Pasta', 'Pane', 'Pesce', 'Pizza'], 1),
      ]),
    CurriculumDay(day: 6, level: 1, title: 'Family', emoji: '👨‍👩‍👧‍👦',
      vocabWords: <VocabPair>[
        VocabPair('Mamma', 'Mom', '👩'), VocabPair('Papà', 'Dad', '👨'),
        VocabPair('Fratello', 'Brother', '👦'), VocabPair('Sorella', 'Sister', '👧'),
        VocabPair('Nonno', 'Grandpa', '👴'), VocabPair('Nonna', 'Grandma', '👵'),
      ], gameName: 'flashcard', conversationPrompt: 'Describe your family in Italian.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Sorella' means…", <String>['Brother', 'Sister', 'Mom', 'Grandma'], 1),
        CurrQuizQ("Your dad is your…", <String>['Nonno', 'Fratello', 'Papà', 'Zio'], 2),
      ]),
    CurriculumDay(day: 7, level: 1, title: 'Days & Months', emoji: '📅',
      vocabWords: <VocabPair>[
        VocabPair('Lunedì', 'Monday', '📅'), VocabPair('Venerdì', 'Friday', '🎉'),
        VocabPair('Sabato', 'Saturday', '😎'), VocabPair('Domenica', 'Sunday', '☀️'),
        VocabPair('Gennaio', 'January', '❄️'), VocabPair('Luglio', 'July', '🌴'),
      ], gameName: 'word_scramble', conversationPrompt: 'Say what day and month it is today.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Venerdì' is…", <String>['Monday', 'Wednesday', 'Friday', 'Sunday'], 2),
        CurrQuizQ("'Luglio' is…", <String>['June', 'July', 'August', 'March'], 1),
      ]),
    CurriculumDay(day: 8, level: 1, title: 'Polite Phrases', emoji: '🙏',
      vocabWords: <VocabPair>[
        VocabPair('Per favore', 'Please', '🙏'), VocabPair('Grazie', 'Thank you', '😊'),
        VocabPair('Prego', "You're welcome", '👍'), VocabPair('Scusa', 'Excuse me', '😅'),
        VocabPair('Mi dispiace', "I'm sorry", '😔'), VocabPair('Non capisco', "I don't understand", '🤷'),
      ], gameName: 'fill_blank', conversationPrompt: 'Practice asking for help politely.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Mi dispiace' means…", <String>['Thank you', "I'm sorry", 'Please', 'Excuse me'], 1),
        CurrQuizQ("'Non capisco' means…", <String>["I don't understand", "I don't like", "I can't", "I don't want"], 0),
      ]),
    CurriculumDay(day: 9, level: 1, title: 'Around the House', emoji: '🏠',
      vocabWords: <VocabPair>[
        VocabPair('Camera', 'Bedroom', '🛏️'), VocabPair('Cucina', 'Kitchen', '🍳'),
        VocabPair('Bagno', 'Bathroom', '🚿'), VocabPair('Tavolo', 'Table', '🪑'),
        VocabPair('Porta', 'Door', '🚪'), VocabPair('Finestra', 'Window', '🪟'),
      ], gameName: 'emoji_match', conversationPrompt: 'Describe the rooms in your house.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Cucina' is the…", <String>['Bathroom', 'Kitchen', 'Bedroom', 'Garden'], 1),
        CurrQuizQ("A 'Finestra' is a…", <String>['Door', 'Table', 'Window', 'Chair'], 2),
      ]),
    CurriculumDay(day: 10, level: 1, title: 'Level 1 Review', emoji: '⭐',
      vocabWords: <VocabPair>[
        VocabPair('Buongiorno', 'Good morning', '☀️'), VocabPair('Rosso', 'Red', '🔴'),
        VocabPair('Gatto', 'Cat', '🐱'), VocabPair('Acqua', 'Water', '💧'),
        VocabPair('Mamma', 'Mom', '👩'), VocabPair('Grazie', 'Thank you', '🙏'),
      ], gameName: 'word_scramble', conversationPrompt: 'Talk about your week using everything from Level 1.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("Say 'Good morning':", <String>['Buonasera', 'Buongiorno', 'Buonanotte', 'Ciao'], 1),
        CurrQuizQ("'Acqua' is…", <String>['Bread', 'Milk', 'Water', 'Juice'], 2),
      ]),

    // ═══════════ LEVEL 2: Everyday (Days 11–20) ═══════════
    CurriculumDay(day: 11, level: 2, title: 'At School', emoji: '🏫',
      vocabWords: <VocabPair>[
        VocabPair('Scuola', 'School', '🏫'), VocabPair('Insegnante', 'Teacher', '👩‍🏫'),
        VocabPair('Compiti', 'Homework', '📝'), VocabPair('Zaino', 'Backpack', '🎒'),
        VocabPair('Matita', 'Pencil', '✏️'), VocabPair('Quaderno', 'Notebook', '📓'),
      ], gameName: 'flashcard', conversationPrompt: 'Describe your school day.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Compiti' means…", <String>['Classmate', 'Homework', 'Teacher', 'Pencil'], 1),
        CurrQuizQ("Your 'Zaino' is your…", <String>['Desk', 'Notebook', 'Backpack', 'Pencil'], 2),
      ]),
    CurriculumDay(day: 12, level: 2, title: 'Weather', emoji: '🌤️',
      vocabWords: <VocabPair>[
        VocabPair('Sole', 'Sun/Sunny', '☀️'), VocabPair('Pioggia', 'Rain', '🌧️'),
        VocabPair('Neve', 'Snow', '❄️'), VocabPair('Vento', 'Wind', '💨'),
        VocabPair('Caldo', 'Hot', '🥵'), VocabPair('Freddo', 'Cold', '🥶'),
      ], gameName: 'fill_blank', conversationPrompt: "Describe today's weather in Italian.",
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Pioggia' is…", <String>['Snow', 'Wind', 'Rain', 'Sun'], 2),
        CurrQuizQ("When it's 'Caldo' you feel…", <String>['Cold', 'Hot', 'Windy', 'Rainy'], 1),
      ]),
    CurriculumDay(day: 13, level: 2, title: 'Telling Time', emoji: '⏰',
      vocabWords: <VocabPair>[
        VocabPair('Che ora è?', 'What time is it?', '⏰'), VocabPair('Mezzanotte', 'Midnight', '🌙'),
        VocabPair('Mezzogiorno', 'Noon', '☀️'), VocabPair('Ora', 'Hour', '🕐'),
        VocabPair('Minuto', 'Minute', '⏱️'), VocabPair('Mattina', 'Morning', '🌅'),
      ], gameName: 'word_scramble', conversationPrompt: 'Say what time you do different activities.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Mezzanotte' is…", <String>['Noon', 'Midnight', 'Evening', 'Morning'], 1),
        CurrQuizQ("'Che ora è?' asks…", <String>['How old are you?', 'What time is it?', 'What day is it?', 'Where are you?'], 1),
      ]),
    CurriculumDay(day: 14, level: 2, title: 'Body Parts', emoji: '🦶',
      vocabWords: <VocabPair>[
        VocabPair('Testa', 'Head', '🗣️'), VocabPair('Mano', 'Hand', '✋'),
        VocabPair('Piede', 'Foot', '🦶'), VocabPair('Occhi', 'Eyes', '👀'),
        VocabPair('Bocca', 'Mouth', '👄'), VocabPair('Orecchio', 'Ear', '👂'),
      ], gameName: 'emoji_match', conversationPrompt: 'Describe yourself using body part words.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Occhi' are your…", <String>['Ears', 'Eyes', 'Hands', 'Feet'], 1),
        CurrQuizQ("'Mano' is your…", <String>['Head', 'Foot', 'Hand', 'Mouth'], 2),
      ]),
    CurriculumDay(day: 15, level: 2, title: 'Clothing', emoji: '👗',
      vocabWords: <VocabPair>[
        VocabPair('Maglietta', 'T-shirt', '👕'), VocabPair('Pantaloni', 'Pants', '👖'),
        VocabPair('Scarpe', 'Shoes', '👟'), VocabPair('Cappello', 'Hat', '🧢'),
        VocabPair('Giacca', 'Jacket', '🧥'), VocabPair('Vestito', 'Dress', '👗'),
      ], gameName: 'flashcard', conversationPrompt: 'Describe what you are wearing.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Scarpe' are…", <String>['Hats', 'Shirts', 'Shoes', 'Pants'], 2),
        CurrQuizQ("A 'Giacca' is a…", <String>['Dress', 'Jacket', 'Hat', 'T-shirt'], 1),
      ]),
    CurriculumDay(day: 16, level: 2, title: 'Directions', emoji: '🧭',
      vocabWords: <VocabPair>[
        VocabPair('Destra', 'Right', '➡️'), VocabPair('Sinistra', 'Left', '⬅️'),
        VocabPair('Dritto', 'Straight', '⬆️'), VocabPair('Vicino', 'Near', '📍'),
        VocabPair('Lontano', 'Far', '🌍'), VocabPair("Dov'è…?", 'Where is…?', '❓'),
      ], gameName: 'fill_blank', conversationPrompt: 'Give directions to your school.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Sinistra' means…", <String>['Right', 'Left', 'Straight', 'Near'], 1),
        CurrQuizQ("'Vicino' means…", <String>['Far', 'Right', 'Left', 'Near'], 3),
      ]),
    CurriculumDay(day: 17, level: 2, title: 'Hobbies', emoji: '⚽',
      vocabWords: <VocabPair>[
        VocabPair('Giocare', 'To play', '🎮'), VocabPair('Leggere', 'To read', '📖'),
        VocabPair('Nuotare', 'To swim', '🏊'), VocabPair('Disegnare', 'To draw', '🎨'),
        VocabPair('Cantare', 'To sing', '🎤'), VocabPair('Ballare', 'To dance', '💃'),
      ], gameName: 'word_scramble', conversationPrompt: 'Talk about what you like to do for fun.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Nuotare' means to…", <String>['Run', 'Swim', 'Read', 'Sing'], 1),
        CurrQuizQ("'Disegnare' means to…", <String>['Dance', 'Play', 'Draw', 'Swim'], 2),
      ]),
    CurriculumDay(day: 18, level: 2, title: 'Feelings', emoji: '😊',
      vocabWords: <VocabPair>[
        VocabPair('Felice', 'Happy', '😊'), VocabPair('Triste', 'Sad', '😢'),
        VocabPair('Arrabbiato', 'Angry', '😠'), VocabPair('Stanco', 'Tired', '😴'),
        VocabPair('Sorpreso', 'Surprised', '😲'), VocabPair('Spaventato', 'Scared', '😨'),
      ], gameName: 'emoji_match', conversationPrompt: 'Describe how you feel and why.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Stanco' means…", <String>['Happy', 'Tired', 'Angry', 'Scared'], 1),
        CurrQuizQ("If you're 'Felice' you are…", <String>['Sad', 'Surprised', 'Happy', 'Tired'], 2),
      ]),
    CurriculumDay(day: 19, level: 2, title: 'Shopping', emoji: '🛒',
      vocabWords: <VocabPair>[
        VocabPair('Quanto costa?', 'How much?', '💰'), VocabPair('Comprare', 'To buy', '🛍️'),
        VocabPair('Negozio', 'Shop', '🏪'), VocabPair('Soldi', 'Money', '💵'),
        VocabPair('Troppo caro', 'Too expensive', '😬'), VocabPair('Taglia', 'Size', '📏'),
      ], gameName: 'fill_blank', conversationPrompt: 'Pretend to buy something at a market.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Quanto costa?' means…", <String>['Where is it?', 'How much?', 'What size?', 'Too expensive'], 1),
        CurrQuizQ("A 'Negozio' is a…", <String>['Market', 'Shop', 'School', 'Restaurant'], 1),
      ]),
    CurriculumDay(day: 20, level: 2, title: 'Level 2 Review', emoji: '🌟',
      vocabWords: <VocabPair>[
        VocabPair('Scuola', 'School', '🏫'), VocabPair('Pioggia', 'Rain', '🌧️'),
        VocabPair('Testa', 'Head', '🗣️'), VocabPair('Felice', 'Happy', '😊'),
        VocabPair('Destra', 'Right', '➡️'), VocabPair('Comprare', 'To buy', '🛍️'),
      ], gameName: 'flashcard', conversationPrompt: 'Use words from all of Level 2 in a story.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Freddo' means…", <String>['Hot', 'Cold', 'Windy', 'Rainy'], 1),
        CurrQuizQ("'Ballare' means to…", <String>['Sing', 'Swim', 'Dance', 'Draw'], 2),
      ]),

    // ═══════════ LEVEL 3: Real Life (Days 21–30) ═══════════
    CurriculumDay(day: 21, level: 3, title: 'At the Restaurant', emoji: '🍽️',
      vocabWords: <VocabPair>[
        VocabPair('Il conto', 'The bill', '🧾'), VocabPair('Cameriere', 'Waiter', '🧑‍🍳'),
        VocabPair('Il menù', 'The menu', '📋'), VocabPair('Prenotazione', 'Reservation', '📞'),
        VocabPair('Vorrei…', 'I would like…', '🤔'), VocabPair('Antipasto', 'Appetizer', '🥗'),
      ], gameName: 'fill_blank', conversationPrompt: 'Order a full meal at a restaurant.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Il conto' is…", <String>['The menu', 'The bill', 'The tip', 'The waiter'], 1),
        CurrQuizQ("'Vorrei…' means…", <String>['I need', 'I have', 'I would like', 'I want'], 2),
      ]),
    CurriculumDay(day: 22, level: 3, title: 'Traveling', emoji: '✈️',
      vocabWords: <VocabPair>[
        VocabPair('Aeroporto', 'Airport', '✈️'), VocabPair('Treno', 'Train', '🚂'),
        VocabPair('Biglietto', 'Ticket', '🎫'), VocabPair('Valigia', 'Suitcase', '🧳'),
        VocabPair('Partenza', 'Departure', '🛫'), VocabPair('Arrivo', 'Arrival', '🛬'),
      ], gameName: 'word_scramble', conversationPrompt: 'Plan a trip to Italy and buy a ticket.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Biglietto' is a…", <String>['Suitcase', 'Passport', 'Ticket', 'Train'], 2),
        CurrQuizQ("'Partenza' means…", <String>['Arrival', 'Departure', 'Delay', 'Platform'], 1),
      ]),
    CurriculumDay(day: 23, level: 3, title: 'In the City', emoji: '🏙️',
      vocabWords: <VocabPair>[
        VocabPair('Piazza', 'Square/Plaza', '🏛️'), VocabPair('Museo', 'Museum', '🎨'),
        VocabPair('Chiesa', 'Church', '⛪'), VocabPair('Farmacia', 'Pharmacy', '💊'),
        VocabPair('Banca', 'Bank', '🏦'), VocabPair('Fermata', 'Bus stop', '🚏'),
      ], gameName: 'emoji_match', conversationPrompt: 'Ask for directions in an Italian city.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("A 'Farmacia' is a…", <String>['Farm', 'Pharmacy', 'Factory', 'Restaurant'], 1),
        CurrQuizQ("'Fermata' is a…", <String>['Bridge', 'Church', 'Bus stop', 'Park'], 2),
      ]),
    CurriculumDay(day: 24, level: 3, title: 'Sports & Activities', emoji: '⚽',
      vocabWords: <VocabPair>[
        VocabPair('Partita', 'Game/Match', '⚽'), VocabPair('Squadra', 'Team', '👥'),
        VocabPair('Vincere', 'To win', '🏆'), VocabPair('Perdere', 'To lose', '😔'),
        VocabPair('Allenamento', 'Training', '💪'), VocabPair('Arbitro', 'Referee', '🧑‍⚖️'),
      ], gameName: 'flashcard', conversationPrompt: 'Talk about your favorite sport and team.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Vincere' means to…", <String>['Play', 'Lose', 'Win', 'Train'], 2),
        CurrQuizQ("A 'Squadra' is a…", <String>['Score', 'Stadium', 'Team', 'Referee'], 2),
      ]),
    CurriculumDay(day: 25, level: 3, title: 'Technology', emoji: '📱',
      vocabWords: <VocabPair>[
        VocabPair('Telefono', 'Phone', '📱'), VocabPair('Computer', 'Computer', '💻'),
        VocabPair('Messaggio', 'Message', '💬'), VocabPair('Password', 'Password', '🔒'),
        VocabPair('Scaricare', 'To download', '⬇️'), VocabPair('Cercare', 'To search', '🔍'),
      ], gameName: 'fill_blank', conversationPrompt: 'Explain how you use your phone in Italian.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Scaricare' means to…", <String>['Delete', 'Upload', 'Download', 'Search'], 2),
        CurrQuizQ("'Cercare' means to…", <String>['Find', 'Search', 'Send', 'Write'], 1),
      ]),
    CurriculumDay(day: 26, level: 3, title: 'Past Tense Basics', emoji: '⏪',
      vocabWords: <VocabPair>[
        VocabPair('Ho mangiato', 'I ate', '🍽️'), VocabPair('Ho dormito', 'I slept', '😴'),
        VocabPair('Sono andato', 'I went', '🚶'), VocabPair('Ho visto', 'I saw', '👀'),
        VocabPair('Ho comprato', 'I bought', '🛒'), VocabPair('Ieri', 'Yesterday', '📅'),
      ], gameName: 'fill_blank', conversationPrompt: 'Tell Giulia what you did yesterday.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Ho mangiato' means…", <String>['I will eat', 'I eat', 'I ate', 'I am eating'], 2),
        CurrQuizQ("'Ieri' means…", <String>['Today', 'Tomorrow', 'Yesterday', 'Always'], 2),
      ]),
    CurriculumDay(day: 27, level: 3, title: 'Future Plans', emoji: '🔮',
      vocabWords: <VocabPair>[
        VocabPair('Domani', 'Tomorrow', '📅'), VocabPair('Farò', 'I will do', '💪'),
        VocabPair('Andrò', 'I will go', '🚶'), VocabPair('Voglio', 'I want', '🤩'),
        VocabPair('Spero', 'I hope', '🤞'), VocabPair('Quando', 'When', '⏰'),
      ], gameName: 'word_scramble', conversationPrompt: 'Describe your plans for tomorrow.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Domani' means…", <String>['Yesterday', 'Today', 'Tomorrow', 'Later'], 2),
        CurrQuizQ("'Spero' means…", <String>['I think', 'I hope', 'I know', 'I want'], 1),
      ]),
    CurriculumDay(day: 28, level: 3, title: 'Conversation Skills', emoji: '🗣️',
      vocabWords: <VocabPair>[
        VocabPair('Secondo me', 'In my opinion', '💭'), VocabPair('Penso che', 'I think that', '🤔'),
        VocabPair("D'accordo", 'I agree', '✅'), VocabPair('Ma', 'But', '↩️'),
        VocabPair('Perché', 'Because / Why', '❓'), VocabPair('Anche', 'Also', '➕'),
      ], gameName: 'flashcard', conversationPrompt: 'Have a debate about the best Italian food.',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Secondo me' means…", <String>['Second time', 'In my opinion', 'Secondly', 'I agree'], 1),
        CurrQuizQ("'Perché' can mean…", <String>['Because and Why', 'When and Where', 'How and What', 'Who and Which'], 0),
      ]),
    CurriculumDay(day: 29, level: 3, title: 'Italian Culture', emoji: '🇮🇹',
      vocabWords: <VocabPair>[
        VocabPair('Colosseo', 'Colosseum', '🏛️'), VocabPair('Gelato', 'Ice cream', '🍨'),
        VocabPair('Calcio', 'Soccer', '⚽'), VocabPair('Opera', 'Opera', '🎶'),
        VocabPair('Carnevale', 'Carnival', '🎭'), VocabPair('Ferragosto', 'August holiday', '🏖️'),
      ], gameName: 'emoji_match', conversationPrompt: 'What would you want to see and do in Italy?',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Ferragosto' is in…", <String>['December', 'March', 'August', 'June'], 2),
        CurrQuizQ("'Carnevale' is…", <String>['Christmas', 'Easter', 'Carnival', 'New Year'], 2),
      ]),
    CurriculumDay(day: 30, level: 3, title: 'Final Challenge! 🏆', emoji: '🏆',
      vocabWords: <VocabPair>[
        VocabPair('Complimenti', 'Congratulations', '🎉'), VocabPair('Bravo/a', 'Well done', '👏'),
        VocabPair('Ricordare', 'To remember', '🧠'), VocabPair('Imparare', 'To learn', '📚'),
        VocabPair('Parlare', 'To speak', '🗣️'), VocabPair('Capire', 'To understand', '💡'),
      ], gameName: 'word_scramble', conversationPrompt: 'Have a full conversation with Giulia using everything you learned!',
      quizQuestions: <CurrQuizQ>[
        CurrQuizQ("'Imparare' means to…", <String>['Forget', 'Learn', 'Teach', 'Study'], 1),
        CurrQuizQ("'Capire' means to…", <String>['Speak', 'Read', 'Understand', 'Write'], 2),
      ]),
  ];

  static List<CurriculumDay> level(int n) =>
      days.where((CurriculumDay d) => d.level == n).toList();
}
