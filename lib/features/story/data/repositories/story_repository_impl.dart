import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../content/story_catalog.dart';

/// [StoryRepository] backed by the bundled [StoryCatalog].
class StoryRepositoryImpl implements StoryRepository {
  /// Creates the repository.
  const StoryRepositoryImpl();

  @override
  Future<List<Story>> getAll() async => StoryCatalog.stories;

  @override
  Future<Story?> getById(String id) async {
    for (final Story story in StoryCatalog.stories) {
      if (story.id == id) return story;
    }
    return null;
  }
}
