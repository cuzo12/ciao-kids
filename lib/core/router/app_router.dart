import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/conversation/domain/entities/conversation_script.dart';
import '../../features/conversation/presentation/screens/conversation_list_screen.dart';
import '../../features/conversation/presentation/screens/conversation_screen.dart';
import '../../features/ai_chat/presentation/screens/claude_chat_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/lessons/domain/entities/lesson.dart';
import '../../features/lessons/presentation/controllers/learning_controller.dart';
import '../../features/lessons/presentation/screens/lesson_player_screen.dart';
import '../../features/parent/presentation/screens/parent_dashboard_screen.dart';
import '../../features/pronunciation/presentation/screens/pronunciation_screen.dart';
import '../../features/rewards/presentation/screens/rewards_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/story/domain/entities/story.dart';
import '../../features/games/presentation/screens/games_hub_screen.dart';
import '../../features/games/presentation/screens/word_scramble_screen.dart';
import '../../features/games/presentation/screens/flashcard_screen.dart';
import '../../features/games/presentation/screens/fill_blank_screen.dart';
import '../../features/games/presentation/screens/emoji_match_screen.dart';
import '../../features/games/presentation/screens/sound_match_screen.dart';
import '../../features/games/presentation/screens/memory_match_screen.dart';
import '../../features/games/presentation/screens/numbers_game_screen.dart';
import '../../features/curriculum/data/curriculum_data.dart';
import '../../features/curriculum/presentation/screens/curriculum_screen.dart';
import '../../features/curriculum/presentation/screens/curriculum_day_screen.dart';
import '../../features/review/presentation/screens/review_screen.dart';
import '../../features/player/presentation/screens/avatar_screen.dart';
import '../../features/phrasebook/presentation/screens/phrasebook_screen.dart';
import '../../features/verbs/presentation/screens/verbs_screen.dart';
import '../../features/sentences/presentation/screens/sentence_builder_screen.dart';
import '../../features/listening/presentation/screens/listening_screen.dart';
import '../../features/story/presentation/screens/story_list_screen.dart';
import '../../features/story/presentation/screens/story_screen.dart';
import 'app_routes.dart';

/// Builds and owns the application's [GoRouter] instance.
///
/// The router is *auth-aware*: it observes [AuthController] (via
/// `refreshListenable`) and redirects between the public area (splash / login /
/// signup) and the private area (home) whenever the authentication state
/// changes. This keeps navigation guards in one declarative place instead of
/// scattered across screens.
class AppRouter {
  /// Creates an [AppRouter] driven by the supplied [authController].
  AppRouter(this._authController);

  final AuthController _authController;

  /// The configured router, suitable for `MaterialApp.router(routerConfig:)`.
  late final GoRouter config = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: _authController,
    redirect: _redirect,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.splash,
        name: Routes.splashName,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        name: Routes.loginName,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        name: Routes.signupName,
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: Routes.home,
        name: Routes.homeName,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.lesson,
        name: Routes.lessonName,
        builder: (BuildContext context, GoRouterState state) {
          // Prefer the Lesson passed via `extra` (from the home tap); fall back
          // to looking it up by id (e.g. on a deep link / restart).
          final Object? extra = state.extra;
          final String id = state.pathParameters['id'] ?? '';
          final Lesson? lesson = extra is Lesson
              ? extra
              : context.read<LearningController>().lessonById(id);

          if (lesson == null) return const _LessonUnavailable();
          return LessonPlayerScreen(lesson: lesson);
        },
      ),
      GoRoute(
        path: Routes.talk,
        name: Routes.talkName,
        builder: (_, __) => const ConversationListScreen(),
      ),
      GoRoute(
        path: Routes.conversation,
        name: Routes.conversationName,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is ConversationScript) {
            return ConversationScreen(script: extra);
          }
          return const _ConversationUnavailable();
        },
      ),
      GoRoute(
        path: Routes.pronounce,
        name: Routes.pronounceName,
        builder: (_, __) => const PronunciationScreen(),
      ),
      GoRoute(
        path: Routes.rewards,
        name: Routes.rewardsName,
        builder: (_, __) => const RewardsScreen(),
      ),
      GoRoute(
        path: Routes.parent,
        name: Routes.parentName,
        builder: (_, __) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: Routes.stories,
        name: Routes.storiesName,
        builder: (_, __) => const StoryListScreen(),
      ),
      GoRoute(
        path: Routes.aiChat,
        name: Routes.aiChatName,
        builder: (_, __) => const ClaudeChatScreen(),
      ),
      GoRoute(
        path: Routes.story,
        name: Routes.storyName,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is Story) return StoryScreen(story: extra);
          return const _StoryUnavailable();
        },
      ),
      GoRoute(
        path: Routes.games,
        name: Routes.gamesName,
        builder: (_, __) => const GamesHubScreen(),
      ),
      GoRoute(
        path: Routes.wordScramble,
        name: Routes.wordScrambleName,
        builder: (_, __) => const WordScrambleScreen(),
      ),
      GoRoute(
        path: Routes.flashcard,
        name: Routes.flashcardName,
        builder: (_, __) => const FlashcardScreen(),
      ),
      GoRoute(
        path: Routes.fillBlank,
        name: Routes.fillBlankName,
        builder: (_, __) => const FillBlankScreen(),
      ),
      GoRoute(
        path: Routes.emojiMatch,
        name: Routes.emojiMatchName,
        builder: (_, __) => const EmojiMatchScreen(),
      ),
      GoRoute(
        path: Routes.soundMatch,
        name: Routes.soundMatchName,
        builder: (_, __) => const SoundMatchScreen(),
      ),
      GoRoute(
        path: Routes.memoryMatch,
        name: Routes.memoryMatchName,
        builder: (_, __) => const MemoryMatchScreen(),
      ),
      GoRoute(
        path: Routes.numbersGame,
        name: Routes.numbersGameName,
        builder: (_, __) => const NumbersGameScreen(),
      ),
      GoRoute(
        path: Routes.review,
        name: Routes.reviewName,
        builder: (_, __) => const ReviewScreen(),
      ),
      GoRoute(
        path: Routes.phrasebook,
        name: Routes.phrasebookName,
        builder: (_, __) => const PhrasebookScreen(),
      ),
      GoRoute(
        path: Routes.verbs,
        name: Routes.verbsName,
        builder: (_, __) => const VerbsScreen(),
      ),
      GoRoute(
        path: Routes.sentences,
        name: Routes.sentencesName,
        builder: (_, __) => const SentenceBuilderScreen(),
      ),
      GoRoute(
        path: Routes.listening,
        name: Routes.listeningName,
        builder: (_, __) => const ListeningScreen(),
      ),
      GoRoute(
        path: Routes.avatar,
        name: Routes.avatarName,
        builder: (_, __) => const AvatarScreen(),
      ),
      GoRoute(
        path: Routes.curriculum,
        name: Routes.curriculumName,
        builder: (_, __) => const CurriculumScreen(),
      ),
      GoRoute(
        path: Routes.curriculumDay,
        name: Routes.curriculumDayName,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is CurriculumDay) {
            return CurriculumDayScreen(day: extra);
          }
          return const CurriculumScreen();
        },
      ),
    ],
  );

  /// Decides whether the current navigation should be redirected.
  ///
  /// Returns the path to redirect to, or `null` to allow the navigation.
  String? _redirect(BuildContext context, GoRouterState state) {
    final AuthStatus status = _authController.status;
    final String location = state.matchedLocation;

    // While the persisted session is still being restored, hold on splash.
    if (status == AuthStatus.unknown) {
      return location == Routes.splash ? null : Routes.splash;
    }

    final bool onAuthFlow =
        location == Routes.login || location == Routes.signup;

    // Signed out: only the auth flow is reachable.
    if (status == AuthStatus.unauthenticated) {
      return onAuthFlow ? null : Routes.login;
    }

    // Signed in: bounce away from splash/auth into the app.
    if (location == Routes.splash || onAuthFlow) {
      return Routes.home;
    }

    return null;
  }
}

/// Fallback shown if a lesson route resolves to no known lesson.
class _LessonUnavailable extends StatelessWidget {
  const _LessonUnavailable();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.home),
        ),
      ),
      body: const Center(child: Text("We couldn't find that lesson.")),
    );
  }
}

/// Fallback shown if a conversation is opened without its script (e.g. a cold
/// deep link). Conversations are normally launched from the Talk menu.
class _ConversationUnavailable extends StatelessWidget {
  const _ConversationUnavailable();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.talk),
        ),
      ),
      body: const Center(
        child: Text('Open a conversation from the Talk menu.'),
      ),
    );
  }
}

/// Fallback shown if a story is opened without its data (cold deep link).
class _StoryUnavailable extends StatelessWidget {
  const _StoryUnavailable();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.stories),
        ),
      ),
      body: const Center(child: Text('Open a story from the Story menu.')),
    );
  }
}
