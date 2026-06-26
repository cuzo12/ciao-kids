import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

/// Use case: fetch a single lesson by its id.
class GetLessonById {
  /// Creates the use case with its [LessonRepository] dependency.
  const GetLessonById(this._repository);

  final LessonRepository _repository;

  /// Returns the lesson with [id], or `null` if not found.
  Future<Lesson?> call(String id) => _repository.getLessonById(id);
}
