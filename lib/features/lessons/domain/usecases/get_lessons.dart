import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

/// Use case: fetch the full lesson catalog.
class GetLessons {
  /// Creates the use case with its [LessonRepository] dependency.
  const GetLessons(this._repository);

  final LessonRepository _repository;

  /// Returns all lessons in catalog order.
  Future<List<Lesson>> call() => _repository.getLessons();
}
