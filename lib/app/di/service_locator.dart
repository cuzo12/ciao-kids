import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/speech/speech_recognition_service.dart';
import '../../core/services/speech/tts_service.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/continue_as_guest.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/lessons/data/datasources/progress_local_datasource.dart';
import '../../features/lessons/data/repositories/lesson_repository_impl.dart';
import '../../features/lessons/data/repositories/progress_repository_impl.dart';
import '../../features/lessons/domain/repositories/lesson_repository.dart';
import '../../features/lessons/domain/repositories/progress_repository.dart';
import '../../features/lessons/domain/usecases/get_learning_state.dart';
import '../../features/lessons/domain/usecases/get_lesson_by_id.dart';
import '../../features/lessons/domain/usecases/get_lessons.dart';
import '../../features/lessons/domain/usecases/submit_lesson_result.dart';
import '../../features/lessons/presentation/controllers/learning_controller.dart';
import '../../features/conversation/data/engines/scripted_tutor_engine.dart';
import '../../features/conversation/data/repositories/conversation_repository_impl.dart';
import '../../features/conversation/domain/repositories/conversation_repository.dart';
import '../../features/conversation/domain/services/ai_tutor_engine.dart';
import '../../features/conversation/domain/usecases/get_conversation_by_id.dart';
import '../../features/conversation/domain/usecases/get_conversations.dart';
import '../../features/stats/data/datasources/stats_local_datasource.dart';
import '../../features/stats/data/repositories/stats_repository_impl.dart';
import '../../features/stats/domain/repositories/stats_repository.dart';
import '../../features/stats/domain/usecases/add_practice_time.dart';
import '../../features/stats/domain/usecases/get_practice_stats.dart';
import '../../features/stats/domain/usecases/record_activity_completed.dart';
import '../../features/stats/domain/usecases/record_pronunciation_result.dart';
import '../../features/story/data/repositories/story_repository_impl.dart';
import '../../features/story/domain/repositories/story_repository.dart';
import '../../features/story/domain/usecases/get_stories.dart';
import '../../features/story/domain/usecases/get_story_by_id.dart';

/// The global service locator instance.
final GetIt sl = GetIt.instance;

/// Wires up the dependency graph for the whole app.
///
/// Registration order mirrors clean architecture's dependency direction:
/// external services → datasources → repositories → use cases → controllers.
/// Swapping the local auth datasource for a Firebase-backed one in a later
/// milestone is a single change here; nothing else needs to know.
///
/// Must be awaited once in `main()` before the app starts.
Future<void> configureDependencies() async {
  // --- External -----------------------------------------------------------
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // --- Data layer ---------------------------------------------------------
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthLocalDataSource>()),
  );

  sl.registerLazySingleton<ProgressLocalDataSource>(
    () => ProgressLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<LessonRepository>(LessonRepositoryImpl.new);
  sl.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(sl<ProgressLocalDataSource>()),
  );
  sl.registerLazySingleton<ConversationRepository>(
    ConversationRepositoryImpl.new,
  );
  sl.registerLazySingleton<StoryRepository>(StoryRepositoryImpl.new);
  sl.registerLazySingleton<StatsLocalDataSource>(
    () => StatsLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<StatsRepository>(
    () => StatsRepositoryImpl(sl<StatsLocalDataSource>()),
  );

  // --- Services -----------------------------------------------------------
  // The AI tutor "brain". Swap ScriptedTutorEngine for a Claude-backed engine
  // (server-proxied) in a later milestone — nothing else changes.
  sl.registerLazySingleton<AiTutorEngine>(ScriptedTutorEngine.new);
  sl.registerLazySingleton<TtsService>(FlutterTtsService.new);
  sl.registerLazySingleton<SpeechRecognitionService>(
    SttSpeechRecognitionService.new,
  );

  // --- Domain (use cases) -------------------------------------------------
  sl
    ..registerFactory(() => SignIn(sl<AuthRepository>()))
    ..registerFactory(() => SignUp(sl<AuthRepository>()))
    ..registerFactory(() => SignOut(sl<AuthRepository>()))
    ..registerFactory(() => ContinueAsGuest(sl<AuthRepository>()))
    ..registerFactory(() => GetCurrentUser(sl<AuthRepository>()))
    ..registerFactory(() => GetLessons(sl<LessonRepository>()))
    ..registerFactory(() => GetLessonById(sl<LessonRepository>()))
    ..registerFactory(() => GetLearningState(sl<ProgressRepository>()))
    ..registerFactory(() => SubmitLessonResult(sl<ProgressRepository>()))
    ..registerFactory(() => GetConversations(sl<ConversationRepository>()))
    ..registerFactory(() => GetConversationById(sl<ConversationRepository>()))
    ..registerFactory(() => GetStories(sl<StoryRepository>()))
    ..registerFactory(() => GetStoryById(sl<StoryRepository>()))
    ..registerFactory(() => GetPracticeStats(sl<StatsRepository>()))
    ..registerFactory(() => RecordPronunciationResult(sl<StatsRepository>()))
    ..registerFactory(() => AddPracticeTime(sl<StatsRepository>()))
    ..registerFactory(() => RecordConversationCompleted(sl<StatsRepository>()))
    ..registerFactory(() => RecordStoryCompleted(sl<StatsRepository>()));

  // --- Presentation (controllers) -----------------------------------------
  // Singleton: the same AuthController is both provided to the widget tree and
  // used as the router's refreshListenable, so there is exactly one source of
  // truth for auth state.
  sl.registerLazySingleton<AuthController>(
    () => AuthController(
      getCurrentUser: sl<GetCurrentUser>(),
      signIn: sl<SignIn>(),
      signUp: sl<SignUp>(),
      signOut: sl<SignOut>(),
      continueAsGuest: sl<ContinueAsGuest>(),
    ),
  );

  // Singleton: the home dashboard and the lesson route both read the one
  // LearningController so unlocks and reward totals stay in sync.
  sl.registerLazySingleton<LearningController>(
    () => LearningController(
      getLessons: sl<GetLessons>(),
      getLearningState: sl<GetLearningState>(),
      submitLessonResult: sl<SubmitLessonResult>(),
    ),
  );
}
