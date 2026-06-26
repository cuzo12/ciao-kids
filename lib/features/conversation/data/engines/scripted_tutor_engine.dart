import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation_script.dart';
import '../../domain/entities/conversation_step.dart';
import '../../domain/entities/tutor_response.dart';
import '../../domain/services/ai_tutor_engine.dart';

/// Offline, deterministic [AiTutorEngine] driven by an authored script.
///
/// Matching is intentionally lenient (case- and accent-insensitive, substring
/// based) so imperfect speech recognition or spelling still counts. After
/// [AppConstants.conversationMaxAttempts] misses the tutor gently reveals the
/// model answer and moves on, so a child is never stuck — embodying the brief's
/// rule: never just say "wrong".
class ScriptedTutorEngine implements AiTutorEngine {
  /// Creates the engine.
  ScriptedTutorEngine();

  int _counter = 0;

  String _nextId() => 'tutor_${_counter++}';

  ChatMessage _tutor(String text, {String? translation, bool correction = false}) {
    return ChatMessage(
      id: _nextId(),
      sender: MessageSender.tutor,
      text: text,
      translation: translation,
      isCorrection: correction,
    );
  }

  @override
  TutorResponse greeting(ConversationScript script) {
    if (script.steps.isEmpty) {
      return TutorResponse(
        messages: <ChatMessage>[
          _tutor(script.intro, translation: script.introEnglish),
          _tutor(script.closing, translation: script.closingEnglish),
        ],
        understood: true,
        nextStepIndex: 0,
        finished: true,
        suggestions: const <String>[],
      );
    }

    final ConversationStep first = script.steps.first;
    return TutorResponse(
      messages: <ChatMessage>[
        _tutor(script.intro, translation: script.introEnglish),
        _tutor(first.tutorItalian, translation: first.tutorEnglish),
      ],
      understood: true,
      nextStepIndex: 0,
      finished: false,
      suggestions: first.suggestions,
    );
  }

  @override
  TutorResponse evaluate({
    required ConversationScript script,
    required int stepIndex,
    required int attempt,
    required String utterance,
  }) {
    final ConversationStep step = script.steps[stepIndex];
    final bool isLastStep = stepIndex >= script.steps.length - 1;
    final bool matched = _matches(utterance, step.expectedAnswers);

    if (matched) {
      return _advance(
        script,
        stepIndex,
        isLastStep,
        leadMessage: _tutor(step.successReply),
        understood: true,
      );
    }

    // Not understood. Either nudge for another try, or reveal and move on.
    final bool outOfTries = attempt + 1 >= AppConstants.conversationMaxAttempts;
    if (!outOfTries) {
      return TutorResponse(
        messages: <ChatMessage>[_tutor('Quasi! ${step.retryHint}', correction: true)],
        understood: false,
        nextStepIndex: stepIndex,
        finished: false,
        suggestions: step.suggestions,
      );
    }

    final String model =
        step.suggestions.isNotEmpty ? step.suggestions.first : step.tutorItalian;
    return _advance(
      script,
      stepIndex,
      isLastStep,
      leadMessage: _tutor(
        'Quasi! Si dice: "$model". Proviamo insieme la prossima volta! 😊',
        correction: true,
      ),
      understood: false,
    );
  }

  /// Builds the response that moves the conversation forward from [stepIndex],
  /// appending the next prompt (or the closing if this was the last step).
  TutorResponse _advance(
    ConversationScript script,
    int stepIndex,
    bool isLastStep, {
    required ChatMessage leadMessage,
    required bool understood,
  }) {
    final List<ChatMessage> messages = <ChatMessage>[leadMessage];

    if (isLastStep) {
      messages.add(_tutor(script.closing, translation: script.closingEnglish));
      return TutorResponse(
        messages: messages,
        understood: understood,
        nextStepIndex: stepIndex,
        finished: true,
        suggestions: const <String>[],
      );
    }

    final ConversationStep next = script.steps[stepIndex + 1];
    messages.add(_tutor(next.tutorItalian, translation: next.tutorEnglish));
    return TutorResponse(
      messages: messages,
      understood: understood,
      nextStepIndex: stepIndex + 1,
      finished: false,
      suggestions: next.suggestions,
    );
  }

  /// Lenient match: true if the normalized [utterance] and any normalized
  /// expected fragment overlap.
  bool _matches(String utterance, List<String> expected) {
    final String u = _normalize(utterance);
    if (u.isEmpty) return false;
    for (final String raw in expected) {
      final String n = _normalize(raw);
      if (n.isEmpty) continue;
      if (u == n) return true;
      if (n.length >= 2 && u.contains(n)) return true;
      if (u.length >= 3 && n.contains(u)) return true;
    }
    return false;
  }

  /// Lowercases, strips Italian accents, and keeps only letters/spaces.
  String _normalize(String input) {
    final StringBuffer buffer = StringBuffer();
    for (final String ch in input.toLowerCase().trim().split('')) {
      buffer.write(_deaccent(ch));
    }
    return buffer
        .toString()
        .replaceAll(RegExp('[^a-z ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _deaccent(String ch) {
    switch (ch) {
      case 'à':
      case 'á':
      case 'â':
        return 'a';
      case 'è':
      case 'é':
      case 'ê':
        return 'e';
      case 'ì':
      case 'í':
      case 'î':
        return 'i';
      case 'ò':
      case 'ó':
      case 'ô':
        return 'o';
      case 'ù':
      case 'ú':
      case 'û':
        return 'u';
      default:
        return ch;
    }
  }
}
