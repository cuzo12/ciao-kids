import '../../domain/entities/conversation_script.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../content/conversation_catalog.dart';

/// [ConversationRepository] backed by the bundled [ConversationCatalog].
class ConversationRepositoryImpl implements ConversationRepository {
  /// Creates the repository.
  const ConversationRepositoryImpl();

  @override
  Future<List<ConversationScript>> getAll() async =>
      ConversationCatalog.scripts;

  @override
  Future<ConversationScript?> getById(String id) async {
    for (final ConversationScript script in ConversationCatalog.scripts) {
      if (script.id == id) return script;
    }
    return null;
  }
}
