import 'package:flutter/foundation.dart';

import '../../../../core/services/speech/speech_recognition_service.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../conversation/domain/entities/chat_message.dart';
import '../../../stats/domain/usecases/add_practice_time.dart';
import '../../../stats/domain/usecases/record_activity_completed.dart';
import '../../data/remote_tutor_service.dart';

/// Drives a free-form conversation with the real Claude tutor (via the proxy).
///
/// Unlike the scripted [ConversationController], this has no fixed steps — the
/// child can say anything and Claude replies in character. The tutor's Italian
/// is spoken aloud (TTS); the child answers by voice (STT) or typing. Network
/// failures degrade to a gentle in-chat message rather than an error screen.
class ClaudeChatController extends ChangeNotifier {
  /// Creates the controller.
  ClaudeChatController({
    required RemoteTutorService service,
    required TtsService tts,
    required SpeechRecognitionService speech,
    required this.childAge,
    required this.topic,
    required String userId,
    required RecordConversationCompleted recordConversation,
    required AddPracticeTime addPracticeTime,
  })  : _service = service,
        _tts = tts,
        _speech = speech,
        _userId = userId,
        _recordConversation = recordConversation,
        _addPracticeTime = addPracticeTime;

  /// The learner's age (shapes Claude's vocabulary).
  final int childAge;

  /// Loose topic to steer the chat (e.g. "Greetings").
  final String topic;

  final RemoteTutorService _service;
  final TtsService _tts;
  final SpeechRecognitionService _speech;
  final String _userId;
  final RecordConversationCompleted _recordConversation;
  final AddPracticeTime _addPracticeTime;

  final DateTime _startedAt = DateTime.now();
  final List<ChatMessage> _messages = <ChatMessage>[];
  int _seq = 0;
  bool _busy = false;
  bool _listening = false;
  bool _speechAvailable = false;
  bool _exchanged = false;
  String _partial = '';

  /// The conversation so far (oldest→newest).
  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);

  /// Whether a reply is in flight (drives the typing indicator).
  bool get busy => _busy;

  /// Whether the mic is capturing.
  bool get listening => _listening;

  /// Whether speech recognition is available on this device.
  bool get speechAvailable => _speechAvailable;

  /// Live partial transcript while listening.
  String get partialTranscript => _partial;

  /// Greets the child and prepares speech.
  Future<void> init() async {
    await _tts.init();
    _speechAvailable = await _speech.init();
    const String greeting = 'Ciao! Sono Luca. 😊 Come ti chiami? '
        '(Hi! I\'m Luca. What\'s your name?)';
    _messages.add(_msg(MessageSender.tutor, greeting));
    notifyListeners();
    await _tts.speak('Ciao! Sono Luca. Come ti chiami?');
  }

  /// Sends the child's [text] and appends the tutor's reply.
  Future<void> send(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || _busy) return;

    _messages.add(_msg(MessageSender.child, trimmed));
    _busy = true;
    _partial = '';
    notifyListeners();

    try {
      final String reply = await _service.reply(
        history: _messages,
        childAge: childAge,
        topic: topic,
      );
      _messages.add(_msg(MessageSender.tutor, reply));
      _exchanged = true;
      await _tts.speak(_stripHints(reply));
    } on TutorUnavailable catch (e) {
      _messages.add(_msg(MessageSender.tutor, '${e.message} 🙂'));
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Starts/stops listening; a final transcript is sent automatically.
  Future<void> toggleListening() async {
    if (!_speechAvailable || _busy) return;
    if (_listening) {
      await _speech.stop();
      _listening = false;
      notifyListeners();
      if (_partial.trim().isNotEmpty) await send(_partial);
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
          send(transcript);
        }
      },
    );
  }

  /// Re-speaks a tutor [message].
  Future<void> speak(ChatMessage message) => _tts.speak(_stripHints(message.text));

  /// Persists practice time and a completion (if any real exchange happened).
  Future<void> saveSession() async {
    if (_exchanged) await _recordConversation(_userId);
    await _addPracticeTime(
      userId: _userId,
      seconds: DateTime.now().difference(_startedAt).inSeconds,
    );
  }

  ChatMessage _msg(MessageSender sender, String text) =>
      ChatMessage(id: 'm${_seq++}', sender: sender, text: text);

  /// Removes "(English hint)" parentheticals so TTS only speaks the Italian.
  String _stripHints(String text) =>
      text.replaceAll(RegExp(r'\([^)]*\)'), '').replaceAll('  ', ' ').trim();

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }
}
