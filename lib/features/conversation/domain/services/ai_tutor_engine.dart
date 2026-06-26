import '../entities/conversation_script.dart';
import '../entities/tutor_response.dart';

/// The "brain" that decides how the tutor responds in a conversation.
///
/// This is the key extension point of the conversation feature. Milestone 3
/// ships [ScriptedTutorEngine] — a deterministic, fully-offline, child-safe
/// implementation that follows an authored [ConversationScript] with gentle
/// correction. It is intentionally predictable: for ages 5–15 we want total
/// control over every word the tutor says.
///
/// A future `ClaudeTutorEngine` can implement this same interface to add
/// open-ended conversation, calling the Claude API (`claude-opus-4-8`) **via a
/// server proxy** (Cloud Functions) — never directly from the client, since API
/// keys must not ship in a mobile app. That engine should still be grounded in
/// the active [ConversationScript] and moderated, with the scripted engine as a
/// guaranteed-safe fallback. Swapping engines is a one-line change in the
/// service locator; no UI or domain code changes.
abstract interface class AiTutorEngine {
  /// Produces the opening turn (intro + first question) for [script].
  TutorResponse greeting(ConversationScript script);

  /// Evaluates the child's [utterance] for the step at [stepIndex] (on its
  /// [attempt], zero-based) and returns the tutor's reply.
  TutorResponse evaluate({
    required ConversationScript script,
    required int stepIndex,
    required int attempt,
    required String utterance,
  });
}
