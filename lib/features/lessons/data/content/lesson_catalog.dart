import '../../domain/entities/lesson.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/vocabulary_item.dart';

/// The bundled, hand-authored lesson catalog.
///
/// Content is defined in code (not yet fetched remotely) so the app ships with
/// real, playable lessons offline. Each lesson is built via [Lesson.standard],
/// which assembles the conventional Intro → Vocabulary → Pronunciation → Match
/// → Quiz → Review flow from a single word list plus its quiz. Lessons unlock in
/// ascending [Lesson.order].
abstract final class LessonCatalog {
  /// All lessons, already in display/unlock order.
  static final List<Lesson> lessons = <Lesson>[
    _greetings,
    _numbers,
    _colors,
    _animals,
    _food,
    _family,
  ];

  // --- 1. Greetings --------------------------------------------------------

  static final Lesson _greetings = Lesson.standard(
    id: 'greetings',
    title: 'Greetings',
    emoji: '👋',
    subtitle: 'Say hello like an Italian',
    order: 1,
    characterName: 'Luca',
    characterEmoji: '👦',
    greeting: 'Ciao! I\'m Luca. Let\'s learn to say hello together!',
    goal: 'You\'ll learn to greet people and say thank you.',
    vocabulary: const <VocabularyItem>[
      VocabularyItem(
          italian: 'Ciao', english: 'Hi / Bye', emoji: '👋', pronunciation: 'CHOW'),
      VocabularyItem(
          italian: 'Buongiorno',
          english: 'Good morning',
          emoji: '☀️',
          pronunciation: 'bwon-JOR-no'),
      VocabularyItem(
          italian: 'Buonasera',
          english: 'Good evening',
          emoji: '🌆',
          pronunciation: 'bwo-na-SEH-ra'),
      VocabularyItem(
          italian: 'Grazie',
          english: 'Thank you',
          emoji: '🙏',
          pronunciation: 'GRAH-tsyeh'),
      VocabularyItem(
          italian: 'Prego',
          english: "You're welcome",
          emoji: '😊',
          pronunciation: 'PREH-go'),
      VocabularyItem(
          italian: 'Arrivederci',
          english: 'Goodbye',
          emoji: '👋',
          pronunciation: 'ah-ree-veh-DEHR-chee'),
    ],
    quiz: const <QuizQuestion>[
      QuizQuestion(
        prompt: "How do you say 'Hi'?",
        options: <String>['Ciao', 'Grazie', 'Prego', 'Buonasera'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: "What does 'Grazie' mean?",
        options: <String>['Goodbye', 'Thank you', 'Good morning', 'Hello'],
        correctIndex: 1,
        explanation: "'Grazie' means thank you.",
      ),
      QuizQuestion(
        prompt: 'Which one means "Good morning"?',
        options: <String>['Buonasera', 'Buongiorno', 'Arrivederci', 'Prego'],
        correctIndex: 1,
      ),
    ],
    reviewMessage: 'Bravissimo! You can now greet anyone in Italian. 🎉',
  );

  // --- 2. Numbers ----------------------------------------------------------

  static final Lesson _numbers = Lesson.standard(
    id: 'numbers',
    title: 'Numbers',
    emoji: '🔢',
    subtitle: 'Count from one to six',
    order: 2,
    characterName: 'Giulia',
    characterEmoji: '👧',
    greeting: "Ciao! I'm Giulia. Ready to count in Italian?",
    goal: "You'll learn the numbers from one to six.",
    vocabulary: const <VocabularyItem>[
      VocabularyItem(
          italian: 'Uno', english: 'One', emoji: '1️⃣', pronunciation: 'OO-no'),
      VocabularyItem(
          italian: 'Due', english: 'Two', emoji: '2️⃣', pronunciation: 'DOO-eh'),
      VocabularyItem(
          italian: 'Tre', english: 'Three', emoji: '3️⃣', pronunciation: 'TREH'),
      VocabularyItem(
          italian: 'Quattro',
          english: 'Four',
          emoji: '4️⃣',
          pronunciation: 'KWAH-tro'),
      VocabularyItem(
          italian: 'Cinque',
          english: 'Five',
          emoji: '5️⃣',
          pronunciation: 'CHEEN-kweh'),
      VocabularyItem(
          italian: 'Sei', english: 'Six', emoji: '6️⃣', pronunciation: 'SEH-ee'),
    ],
    quiz: const <QuizQuestion>[
      QuizQuestion(
        prompt: "What is 'Tre' in English?",
        options: <String>['Two', 'Three', 'Five', 'One'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: "How do you say 'Five'?",
        options: <String>['Cinque', 'Quattro', 'Sei', 'Due'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: "'Uno' means…",
        options: <String>['One', 'Four', 'Six', 'Three'],
        correctIndex: 0,
      ),
    ],
    reviewMessage: 'Uno, due, tre… fantastico! You can count now. 🌟',
  );

  // --- 3. Colors -----------------------------------------------------------

  static final Lesson _colors = Lesson.standard(
    id: 'colors',
    title: 'Colors',
    emoji: '🎨',
    subtitle: 'Paint with Italian words',
    order: 3,
    characterName: 'Giulia',
    characterEmoji: '👧',
    greeting: 'Colors are everywhere! Let\'s name them in Italian.',
    goal: "You'll learn six bright colors.",
    vocabulary: const <VocabularyItem>[
      VocabularyItem(
          italian: 'Rosso', english: 'Red', emoji: '❤️', pronunciation: 'ROS-so'),
      VocabularyItem(
          italian: 'Blu', english: 'Blue', emoji: '💙', pronunciation: 'BLOO'),
      VocabularyItem(
          italian: 'Verde',
          english: 'Green',
          emoji: '💚',
          pronunciation: 'VEHR-deh'),
      VocabularyItem(
          italian: 'Giallo',
          english: 'Yellow',
          emoji: '💛',
          pronunciation: 'JAHL-lo'),
      VocabularyItem(
          italian: 'Nero', english: 'Black', emoji: '🖤', pronunciation: 'NEH-ro'),
      VocabularyItem(
          italian: 'Bianco',
          english: 'White',
          emoji: '🤍',
          pronunciation: 'BYAN-ko'),
    ],
    quiz: const <QuizQuestion>[
      QuizQuestion(
        prompt: "What color is 'Rosso'?",
        options: <String>['Red', 'Blue', 'Green', 'Yellow'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: "How do you say 'Green'?",
        options: <String>['Giallo', 'Verde', 'Nero', 'Blu'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: "'Bianco' means…",
        options: <String>['Black', 'White', 'Red', 'Blue'],
        correctIndex: 1,
      ),
    ],
    reviewMessage: 'Che bei colori! Your Italian is full of color now. 🎨',
  );

  // --- 4. Animals ----------------------------------------------------------

  static final Lesson _animals = Lesson.standard(
    id: 'animals',
    title: 'Animals',
    emoji: '🐶',
    subtitle: 'Meet the animal friends',
    order: 4,
    characterName: 'Captain Leo',
    characterEmoji: '🧭',
    greeting: "Adventure time! Let's meet some animali.",
    goal: "You'll learn the names of six animals.",
    vocabulary: const <VocabularyItem>[
      VocabularyItem(
          italian: 'Cane', english: 'Dog', emoji: '🐶', pronunciation: 'KAH-neh'),
      VocabularyItem(
          italian: 'Gatto', english: 'Cat', emoji: '🐱', pronunciation: 'GAHT-to'),
      VocabularyItem(
          italian: 'Cavallo',
          english: 'Horse',
          emoji: '🐴',
          pronunciation: 'ka-VAHL-lo'),
      VocabularyItem(
          italian: 'Uccello',
          english: 'Bird',
          emoji: '🐦',
          pronunciation: 'oo-CHEL-lo'),
      VocabularyItem(
          italian: 'Pesce',
          english: 'Fish',
          emoji: '🐟',
          pronunciation: 'PEH-sheh'),
      VocabularyItem(
          italian: 'Coniglio',
          english: 'Rabbit',
          emoji: '🐰',
          pronunciation: 'ko-NEE-lyo'),
    ],
    quiz: const <QuizQuestion>[
      QuizQuestion(
        prompt: "What is 'Gatto'?",
        options: <String>['Dog', 'Cat', 'Fish', 'Bird'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: "How do you say 'Dog'?",
        options: <String>['Cane', 'Cavallo', 'Pesce', 'Gatto'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: "'Pesce' means…",
        options: <String>['Horse', 'Rabbit', 'Fish', 'Bird'],
        correctIndex: 2,
      ),
    ],
    reviewMessage: 'Che bravo! You met all the animal friends. 🐾',
  );

  // --- 5. Food -------------------------------------------------------------

  static final Lesson _food = Lesson.standard(
    id: 'food',
    title: 'Food',
    emoji: '🍝',
    subtitle: 'Delizioso! Italian for food',
    order: 5,
    characterName: 'Nonna Rosa',
    characterEmoji: '👵',
    greeting: 'Vieni in cucina! Let\'s name some yummy food.',
    goal: "You'll learn six tasty food words.",
    vocabulary: const <VocabularyItem>[
      VocabularyItem(
          italian: 'Pane', english: 'Bread', emoji: '🍞', pronunciation: 'PAH-neh'),
      VocabularyItem(
          italian: 'Pizza',
          english: 'Pizza',
          emoji: '🍕',
          pronunciation: 'PEET-tsa'),
      VocabularyItem(
          italian: 'Mela', english: 'Apple', emoji: '🍎', pronunciation: 'MEH-la'),
      VocabularyItem(
          italian: 'Acqua',
          english: 'Water',
          emoji: '💧',
          pronunciation: 'AH-kwa'),
      VocabularyItem(
          italian: 'Formaggio',
          english: 'Cheese',
          emoji: '🧀',
          pronunciation: 'for-MAHD-jo'),
      VocabularyItem(
          italian: 'Gelato',
          english: 'Ice cream',
          emoji: '🍨',
          pronunciation: 'jeh-LAH-to'),
    ],
    quiz: const <QuizQuestion>[
      QuizQuestion(
        prompt: "What is 'Mela'?",
        options: <String>['Bread', 'Apple', 'Cheese', 'Water'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: "How do you say 'Ice cream'?",
        options: <String>['Gelato', 'Pane', 'Pizza', 'Acqua'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: "'Acqua' means…",
        options: <String>['Cheese', 'Bread', 'Water', 'Apple'],
        correctIndex: 2,
      ),
    ],
    reviewMessage: 'Mangia, mangia! You\'re ready to order in Italian. 🍽️',
  );

  // --- 6. Family -----------------------------------------------------------

  static final Lesson _family = Lesson.standard(
    id: 'family',
    title: 'Family',
    emoji: '👨‍👩‍👧',
    subtitle: 'La famiglia: your loved ones',
    order: 6,
    characterName: 'Nonna Rosa',
    characterEmoji: '👵',
    greeting: 'Family is everything! Let\'s name la famiglia.',
    goal: "You'll learn to name family members.",
    vocabulary: const <VocabularyItem>[
      VocabularyItem(
          italian: 'Mamma', english: 'Mom', emoji: '👩', pronunciation: 'MAHM-ma'),
      VocabularyItem(
          italian: 'Papà', english: 'Dad', emoji: '👨', pronunciation: 'pa-PA'),
      VocabularyItem(
          italian: 'Sorella',
          english: 'Sister',
          emoji: '👧',
          pronunciation: 'so-REL-la'),
      VocabularyItem(
          italian: 'Fratello',
          english: 'Brother',
          emoji: '👦',
          pronunciation: 'fra-TEL-lo'),
      VocabularyItem(
          italian: 'Nonna',
          english: 'Grandma',
          emoji: '👵',
          pronunciation: 'NON-na'),
      VocabularyItem(
          italian: 'Nonno',
          english: 'Grandpa',
          emoji: '👴',
          pronunciation: 'NON-no'),
    ],
    quiz: const <QuizQuestion>[
      QuizQuestion(
        prompt: "What is 'Sorella'?",
        options: <String>['Brother', 'Sister', 'Mom', 'Dad'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: "How do you say 'Grandma'?",
        options: <String>['Nonno', 'Nonna', 'Mamma', 'Papà'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: "'Fratello' means…",
        options: <String>['Sister', 'Brother', 'Dad', 'Grandpa'],
        correctIndex: 1,
      ),
    ],
    reviewMessage: 'Che bella famiglia! You can talk about everyone now. 💚',
  );
}
