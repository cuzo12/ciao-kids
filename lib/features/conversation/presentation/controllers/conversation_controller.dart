import 'package:flutter/foundation.dart';

import '../../../../core/services/speech/speech_recognition_service.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../stats/domain/usecases/add_practice_time.dart';
import '../../../stats/domain/usecases/record_activity_completed.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation_script.dart';
import '../../domain/entities/tutor_response.dart';
import '../../domain/services/ai_tutor_engine.dart';

/// Drives a single conversation session.
///
/// Owns the transcript and step/attempt state, and coordinates the three
/// collaborators: the [AiTutorEngine] (decides replies), the [TtsService]
/// (speaks the tutor's Italian), and the [SpeechRecognitionService] (listens to
/// the child). Speech is optional — when unavailable, suggestion chips and typed
/// input keep the conversation fully usable. A fresh instance is created per
/// conversation screen.
class ConversationController extends ChangeNotifier {
  /// Creates a controller for [script] with its injected collaborators.
  ConversationController({
    required this.script,
    required String userId,
    required AiTutorEngine engine,
    required TtsService tts,
    required SpeechRecognitionService speech,
    required RecordConversationCompleted recordConversation,
    required AddPracticeTime addPracticeTime,
  })  : _userId = userId,
        _engine = engine,
        _tts = tts,
        _speech = speech,
        _recordConversation = recordConversation,
        _addPracticeTime = addPracticeTime;

  /// The script being played.
  final ConversationScript script;

  final String _userId;
  final AiTutorEngine _engine;
  final TtsService _tts;
  final SpeechRecognitionService _speech;
  final RecordConversationCompleted _recordConversation;
  final AddPracticeTime _addPracticeTime;

  final DateTime _startedAt = DateTime.now();
  bool _recorded = false;

  final List<ChatMessage> _messages = <ChatMessage>[];
  int _stepIndex = 0;
  int _attempt = 0;
  bool _finished = false;
  bool _busy = false;
  bool _speechAvailable = false;
  bool _listening = false;
  String _partial = '';
  List<String> _suggestions = const <String>[];

  /// The full transcript so far.
  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);

  /// Whether the conversation has ended.
  bool get finished => _finished;

  /// Whether the tutor is currently "talking" (input is disabled).
  bool get busy => _busy;

  /// Whether speech recognition is available on this device.
  bool get speechAvailable => _speechAvailable;

  /// Whether the microphone is actively listening.
  bool get listening => _listening;

  /// The live (partial) transcript while listening.
  String get partialTranscript => _partial;

  /// Suggested replies for the current step.
  List<String> get suggestions => _suggestions;

  /// Initializes speech, then plays the tutor's opening turn.
  Future<void> start() async {
    await _tts.init();
    _speechAvailable = await _speech.init();

    final TutorResponse opening = _engine.greeting(script);
    _stepIndex = opening.nextStepIndex;
    _finished = opening.finished;
    _suggestions = opening.suggestions;
    _messages.addAll(opening.messages);
    _busy = true;
    notifyListeners();

    await _speak(opening.messages);
    _busy = false;
    notifyListeners();
    _maybeRecordCompletion();
  }

  /// Submits the child's [utterance] (from voice, a suggestion, or typing).
  Future<void> submit(String utterance) async {
    final String text = utterance.trim();
    if (text.isEmpty || _finished || _busy) return;

    _messages.add(
      ChatMessage(
        id: 'child_${_messages.length}',
        sender: MessageSender.child,
        text: text,
      ),
    );
    _partial = '';
    _suggestions = const <String>[];
    _busy = true;
    notifyListeners();

    final int prevStep = _stepIndex;
    final TutorResponse response = _engine.evaluate(
      script: script,
      stepIndex: prevStep,
      attempt: _attempt,
      utterance: text,
    );

    final bool stayed = response.nextStepIndex == prevStep && !response.finished;
    _attempt = stayed ? _attempt + 1 : 0;
    _stepIndex = response.nextStepIndex;
    _finished = response.finished;
    _suggestions = response.suggestions;
    _messages.addAll(response.messages);
    notifyListeners();

    await _speak(response.messages);
    _busy = false;
    notifyListeners();
    _maybeRecordCompletion();
  }

  /// Records completion + practice time once, when the conversation ends.
  void _maybeRecordCompletion() {
    if (!_finished || _recorded) return;
    _recorded = true;
    _recordConversation(_userId);
    _addPracticeTime(
      userId: _userId,
      seconds: DateTime.now().difference(_startedAt).inSeconds,
    );
  }

  /// Starts or stops microphone listening.
  Future<void> toggleListening() async {
    if (!_speechAvailable || _busy || _finished) return;
    if (_listening) {
      await stopListening();
      return;
    }
    _listening = true;
    _partial = '';
    notifyListeners();

    await _speech.listen(
      onResult: (String transcript, bool isFinal) {
        _partial = transcript;
        notifyListeners();
        if (isFinal) {
          _listening = false;
          notifyListeners();
          if (transcript.trim().isNotEmpty) {
            submit(transcript);
          }
        }
      },
    );
  }

  /// Stops listening and submits whatever was captured.
  Future<void> stopListening() async {
    await _speech.stop();
    _listening = false;
    final String captured = _partial;
    _partial = '';
    notifyListeners();
    if (captured.trim().isNotEmpty) {
      await submit(captured);
    }
  }

  /// Replays a tutor [message] aloud.
  Future<void> replay(ChatMessage message) async {
    if (message.isTutor) await _tts.speak(message.text);
  }

  Future<void> _speak(Iterable<ChatMessage> messages) async {
    for (final ChatMessage message in messages) {
      if (message.isTutor) await _tts.speak(message.text);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }
}
