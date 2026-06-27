/// Application-wide constants that are not visual design tokens.
///
/// Anything that is a "magic value" used by business logic (key names, limits,
/// supported ranges) lives here so it can be changed in one place and unit
/// tested without reaching into widgets.
abstract final class AppConstants {
  /// Human-readable product name.
  static const String appName = 'Ciao Kids';

  /// Supported learner age range (years), per the product brief (5–15).
  static const int minChildAge = 5;
  static const int maxChildAge = 15;

  /// Minimum password length enforced at sign-up.
  static const int minPasswordLength = 6;

  // --- Learning & rewards --------------------------------------------------

  /// Base experience points awarded for completing a lesson.
  static const int xpPerLesson = 30;

  /// Extra experience points awarded per star earned in a lesson.
  static const int xpPerStar = 10;

  /// Base coins awarded for completing a lesson.
  static const int coinsPerLesson = 10;

  /// Extra coins awarded per star earned in a lesson.
  static const int coinsPerStar = 5;

  // --- Conversation --------------------------------------------------------

  /// Wrong attempts allowed on a conversation step before the tutor gently
  /// reveals the answer and moves on (so a child never gets stuck).
  static const int conversationMaxAttempts = 2;

  /// BCP-47 locale used for Italian speech synthesis and recognition.
  ///
  /// Must be the hyphen form `it-IT`: on the web the Web Speech API (Chrome on
  /// Android) requires a valid BCP-47 tag, and an underscore variant (`it_IT`)
  /// is silently ignored — the browser then falls back to English and mishears
  /// Italian words.
  static const String italianTtsLocale = 'it-IT';

  /// Locale used for Italian speech recognition (same hyphen form as TTS).
  static const String italianSttLocale = 'it-IT';

  // --- Persistence keys (shared_preferences) -------------------------------

  /// Key under which the currently signed-in user's JSON is stored.
  static const String kCurrentUserKey = 'ciao_kids.current_user';

  /// Key under which the local "user database" (email -> record) is stored.
  static const String kUsersDbKey = 'ciao_kids.users_db';

  /// Prefix for per-user lesson-progress storage (`<prefix><userId>`).
  static const String kProgressKeyPrefix = 'ciao_kids.progress.';

  /// Prefix for per-user streak storage (`<prefix><userId>`).
  static const String kStreakKeyPrefix = 'ciao_kids.streak.';

  /// Prefix for per-user practice-stats storage (`<prefix><userId>`).
  static const String kStatsKeyPrefix = 'ciao_kids.stats.';

  // --- Pronunciation -------------------------------------------------------

  /// Similarity (0–100) at/above which a spoken word is accepted as correct.
  static const int pronunciationPassScore = 70;

  // --- Parent gate ---------------------------------------------------------

  /// Operands for the simple multiplication gate protecting the dashboard.
  static const int parentGateLeft = 7;
  static const int parentGateRight = 8;
}
