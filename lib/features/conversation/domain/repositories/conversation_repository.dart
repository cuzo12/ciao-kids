import '../entities/conversation_script.dart';

/// Contract for accessing authored conversation scripts.
///
/// Bundled locally for now; a remote implementation could deliver new
/// conversations over the air without changing callers.
abstract interface class ConversationRepository {
  /// Returns all available conversation scripts.
  Future<List<ConversationScript>> getAll();

  /// Returns the script with [id], or `null` if not found.
  Future<ConversationScript?> getById(String id);
}
