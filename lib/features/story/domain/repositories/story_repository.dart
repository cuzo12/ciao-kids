import '../entities/story.dart';

/// Contract for accessing interactive stories.
abstract interface class StoryRepository {
  /// Returns all stories.
  Future<List<Story>> getAll();

  /// Returns the story with [id], or `null` if not found.
  Future<Story?> getById(String id);
}
