import '../entities/conversation_script.dart';
import '../repositories/conversation_repository.dart';

/// Use case: fetch a single conversation script by id.
class GetConversationById {
  /// Creates the use case with its [ConversationRepository] dependency.
  const GetConversationById(this._repository);

  final ConversationRepository _repository;

  /// Returns the script with [id], or `null` if not found.
  Future<ConversationScript?> call(String id) => _repository.getById(id);
}
