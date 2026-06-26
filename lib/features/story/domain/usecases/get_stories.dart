import '../entities/story.dart';
import '../repositories/story_repository.dart';

/// Use case: list available stories.
class GetStories {
  /// Creates the use case with its [StoryRepository] dependency.
  const GetStories(this._repository);

  final StoryRepository _repository;

  /// Returns all stories.
  Future<List<Story>> call() => _repository.getAll();
}
