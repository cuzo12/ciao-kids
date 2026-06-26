import '../entities/lesson.dart';

/// Contract for accessing lesson content.
///
/// Implemented against bundled local content in this milestone; a remote
/// (Firestore/CDN) implementation can later satisfy the same interface to
/// deliver or update lessons over the air without touching callers.
abstract interface class LessonRepository {
  /// Returns all lessons, in catalog order.
  Future<List<Lesson>> getLessons();

  /// Returns the lesson with the given [id], or `null` if none exists.
  Future<Lesson?> getLessonById(String id);
}
