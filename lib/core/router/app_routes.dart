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
}
