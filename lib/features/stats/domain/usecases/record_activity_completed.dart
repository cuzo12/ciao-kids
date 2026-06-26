import '../repositories/stats_repository.dart';

/// Use case: record that a conversation was completed.
class RecordConversationCompleted {
  /// Creates the use case with its [StatsRepository] dependency.
  const RecordConversationCompleted(this._repository);

  final StatsRepository _repository;

  /// Increments the conversation counter for [userId].
  Future<void> call(String userId) => _repository.incrementConversations(userId);
}

/// Use case: record that a story was completed.
class RecordStoryCompleted {
  /// Creates the use case with its [StatsRepository] dependency.
  const RecordStoryCompleted(this._repository);

  final StatsRepository _repository;

  /// Increments the story counter for [userId].
  Future<void> call(String userId) => _repository.incrementStories(userId);
}
