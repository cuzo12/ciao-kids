import '../entities/story.dart';
import '../repositories/story_repository.dart';

/// Use case: fetch a single story by id.
class GetStoryById {
  /// Creates the use case with its [StoryRepository] dependency.
  const GetStoryById(this._repository);

  final StoryRepository _repository;

  /// Returns the story with [id], or `null` if not found.
  Future<Story?> call(String id) => _repository.getById(id);
}
