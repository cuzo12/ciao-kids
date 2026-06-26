import '../entities/conversation_script.dart';
import '../repositories/conversation_repository.dart';

/// Use case: list the available conversation scripts.
class GetConversations {
  /// Creates the use case with its [ConversationRepository] dependency.
  const GetConversations(this._repository);

  final ConversationRepository _repository;

  /// Returns all conversation scripts.
  Future<List<ConversationScript>> call() => _repository.getAll();
}
