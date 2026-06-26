import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../content/lesson_catalog.dart';

/// [LessonRepository] backed by the bundled [LessonCatalog].
///
/// Content is served from local memory in this milestone. Swapping to a remote
/// source later means replacing only this class — the domain and UI are
/// unaffected.
class LessonRepositoryImpl implements LessonRepository {
  /// Creates the repository.
  const LessonRepositoryImpl();

  @override
  Future<List<Lesson>> getLessons() async {
    final List<Lesson> lessons = List<Lesson>.of(LessonCatalog.lessons)
      ..sort((Lesson a, Lesson b) => a.order.compareTo(b.order));
    return lessons;
  }

  @override
  Future<Lesson?> getLessonById(String id) async {
    for (final Lesson lesson in LessonCatalog.lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }
}
