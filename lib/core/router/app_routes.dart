/// Centralized route path and name constants.
///
/// Referencing these constants (instead of raw strings) everywhere navigation
/// happens prevents typos and makes renaming a route a single-edit change.
abstract final class Routes {
  /// Branded loading screen shown while the session is being restored.
  static const String splash = '/splash';

  /// Email/password sign-in screen.
  static const String login = '/login';

  /// Account creation screen.
  static const String signup = '/signup';

  /// Authenticated landing screen (the child's dashboard).
  static const String home = '/home';

  /// Lesson player, parameterized by lesson id (`/lesson/:id`).
  static const String lesson = '/lesson/:id';

  /// Builds a concrete lesson path for the given [id].
  static String lessonPath(String id) => '/lesson/$id';

  /// Conversation chooser ("Practice Talking").
  static const String talk = '/talk';

  /// Conversation player, parameterized by script id (`/talk/:id`).
  static const String conversation = '/talk/:id';

  /// Pronunciation coach.
  static const String pronounce = '/pronounce';

  /// Rewards hub (badges + passport).
  static const String rewards = '/rewards';

  /// Parent dashboard (gated).
  static const String parent = '/parent';

  /// Story chooser.
  static const String stories = '/stories';

  /// Story player, parameterized by story id (`/story/:id`).
  static const String story = '/story/:id';

  /// Live Claude tutor free-chat.
  static const String aiChat = '/ai-chat';

  /// Games hub.
  static const String games = '/games';

  /// Individual game routes.
  static const String wordScramble = '/games/word-scramble';
  static const String flashcard = '/games/flashcard';
  static const String fillBlank = '/games/fill-blank';
  static const String emojiMatch = '/games/emoji-match';
  static const String soundMatch = '/games/sound-match';
  static const String memoryMatch = '/games/memory-match';

  /// Travel phrasebook.
  static const String phrasebook = '/phrasebook';

  /// Verb conjugation trainer.
  static const String verbs = '/verbs';

  /// Sentence builder game.
  static const String sentences = '/sentences';

  /// Listening comprehension game.
  static const String listening = '/listening';

  /// Smart spaced-repetition review.
  static const String review = '/review';

  /// Avatar customization closet.
  static const String avatar = '/avatar';

  /// 30-day curriculum.
  static const String curriculum = '/curriculum';

  /// Curriculum day player (`/curriculum/:day`).
  static const String curriculumDay = '/curriculum/:day';

  // Named-route identifiers (used by GoRouter `goNamed`/`pushNamed`).
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String signupName = 'signup';
  static const String homeName = 'home';
  static const String lessonName = 'lesson';
  static const String talkName = 'talk';
  static const String conversationName = 'conversation';
  static const String pronounceName = 'pronounce';
  static const String rewardsName = 'rewards';
  static const String parentName = 'parent';
  static const String storiesName = 'stories';
  static const String storyName = 'story';
  static const String aiChatName = 'aiChat';
  static const String gamesName = 'games';
  static const String wordScrambleName = 'wordScramble';
  static const String flashcardName = 'flashcard';
  static const String fillBlankName = 'fillBlank';
  static const String emojiMatchName = 'emojiMatch';
  static const String soundMatchName = 'soundMatch';
  static const String memoryMatchName = 'memoryMatch';
  static const String curriculumName = 'curriculum';
  static const String curriculumDayName = 'curriculumDay';
  static const String reviewName = 'review';
  static const String avatarName = 'avatar';
  static const String phrasebookName = 'phrasebook';
  static const String verbsName = 'verbs';
  static const String sentencesName = 'sentences';
  static const String listeningName = 'listening';
}
