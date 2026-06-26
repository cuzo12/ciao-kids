import '../../domain/entities/conversation_script.dart';
import '../../domain/entities/conversation_step.dart';

/// The bundled, hand-authored conversation scripts.
///
/// Each script is a short, friendly, structured chat with a character. Steps
/// use lenient keyword matching (see [ScriptedTutorEngine]), so children can
/// answer by voice, by tapping a suggestion, or by typing.
abstract final class ConversationCatalog {
  /// All conversation scripts.
  static const List<ConversationScript> scripts = <ConversationScript>[
    _greetings,
    _family,
    _gelato,
  ];

  // --- Saluti / Greetings (Luca) ------------------------------------------

  static const ConversationScript _greetings = ConversationScript(
    id: 'talk_greetings',
    title: 'Saluti',
    subtitle: 'Meet Luca and introduce yourself',
    characterName: 'Luca',
    characterEmoji: '👦',
    intro: 'Ciao! Sono Luca. Parliamo un po\'!',
    introEnglish: "Hi! I'm Luca. Let's chat a little!",
    steps: <ConversationStep>[
      ConversationStep(
        tutorItalian: 'Come ti chiami?',
        tutorEnglish: "What's your name?",
        expectedAnswers: <String>['mi chiamo', 'sono', 'io sono'],
        suggestions: <String>['Mi chiamo Sofia', 'Sono Marco'],
        successReply: 'Piacere di conoscerti! Che bel nome!',
        retryHint: "Try: 'Mi chiamo ...' (My name is ...)",
      ),
      ConversationStep(
        tutorItalian: 'Come stai?',
        tutorEnglish: 'How are you?',
        expectedAnswers: <String>['bene', 'molto bene', 'cosi cosi', 'male'],
        suggestions: <String>['Sto bene!', 'Molto bene!', 'Così così'],
        successReply: 'Sono felice di sentirlo!',
        retryHint: "Try: 'Sto bene!' (I'm well!)",
      ),
      ConversationStep(
        tutorItalian: 'Quanti anni hai?',
        tutorEnglish: 'How old are you?',
        expectedAnswers: <String>['anni', 'ho'],
        suggestions: <String>['Ho otto anni', 'Ho dieci anni'],
        successReply: 'Wow, fantastico!',
        retryHint: "Try: 'Ho ... anni' (I am ... years old)",
      ),
    ],
    closing: 'Bravissimo! Ci vediamo presto. Ciao!',
    closingEnglish: 'Great job! See you soon. Bye!',
  );

  // --- La famiglia / Family (Nonna Rosa) ----------------------------------

  static const ConversationScript _family = ConversationScript(
    id: 'talk_family',
    title: 'La famiglia',
    subtitle: 'Talk about your family with Nonna Rosa',
    characterName: 'Nonna Rosa',
    characterEmoji: '👵',
    intro: 'Ciao tesoro! Sono Nonna Rosa. Parliamo della famiglia!',
    introEnglish: "Hi sweetie! I'm Nonna Rosa. Let's talk about family!",
    steps: <ConversationStep>[
      ConversationStep(
        tutorItalian: 'Come si chiama la tua mamma?',
        tutorEnglish: "What's your mom's name?",
        expectedAnswers: <String>['si chiama', 'mamma', 'mia mamma'],
        suggestions: <String>['Si chiama Maria', 'Mia mamma si chiama Anna'],
        successReply: 'Che bel nome!',
        retryHint: "Try: 'Si chiama ...' (Her name is ...)",
      ),
      ConversationStep(
        tutorItalian: 'Hai fratelli o sorelle?',
        tutorEnglish: 'Do you have brothers or sisters?',
        expectedAnswers: <String>['si', 'no', 'fratello', 'sorella', 'ho'],
        suggestions: <String>['Sì, ho un fratello', 'Ho una sorella', 'No'],
        successReply: 'Che bello, capisco!',
        retryHint: "Try: 'Ho un fratello' or 'Ho una sorella'",
      ),
      ConversationStep(
        tutorItalian: 'Chi cucina a casa tua?',
        tutorEnglish: 'Who cooks at your house?',
        expectedAnswers: <String>['mamma', 'papa', 'nonna', 'cucina', 'cucino'],
        suggestions: <String>['La mamma cucina', 'Cucina papà', 'La nonna!'],
        successReply: 'In casa mia cucino sempre io! 🍝',
        retryHint: "Try: 'La mamma cucina' (Mom cooks)",
      ),
    ],
    closing: 'Che bella chiacchierata! A presto, tesoro!',
    closingEnglish: 'What a lovely chat! See you soon, sweetie!',
  );

  // --- Al gelato / Ordering gelato (Giulia) -------------------------------

  static const ConversationScript _gelato = ConversationScript(
    id: 'talk_gelato',
    title: 'Al gelato',
    subtitle: 'Order an ice cream with Giulia',
    characterName: 'Giulia',
    characterEmoji: '👧',
    intro: 'Ciao! Sono Giulia. Andiamo a prendere un gelato!',
    introEnglish: "Hi! I'm Giulia. Let's go get some ice cream!",
    steps: <ConversationStep>[
      ConversationStep(
        tutorItalian: 'Che gusto vuoi?',
        tutorEnglish: 'What flavor do you want?',
        expectedAnswers: <String>[
          'voglio',
          'cioccolato',
          'fragola',
          'limone',
          'vaniglia',
        ],
        suggestions: <String>[
          'Voglio il cioccolato',
          'Voglio la fragola',
          'Limone, per favore',
        ],
        successReply: 'Mmm, buonissimo!',
        retryHint: "Try: 'Voglio il cioccolato' (I want chocolate)",
      ),
      ConversationStep(
        tutorItalian: 'Vuoi un cono o una coppetta?',
        tutorEnglish: 'Do you want a cone or a cup?',
        expectedAnswers: <String>['cono', 'coppetta'],
        suggestions: <String>['Un cono!', 'Una coppetta'],
        successReply: 'Ottima scelta!',
        retryHint: "Try: 'Un cono!' (A cone!)",
      ),
      ConversationStep(
        tutorItalian: 'Come si dice per ringraziare?',
        tutorEnglish: 'How do you say thank you?',
        expectedAnswers: <String>['grazie'],
        suggestions: <String>['Grazie!', 'Grazie mille!'],
        successReply: 'Prego! 😊',
        retryHint: "Try: 'Grazie!' (Thank you!)",
      ),
    ],
    closing: 'Che buono! Ci vediamo, ciao!',
    closingEnglish: 'So good! See you, bye!',
  );
}
