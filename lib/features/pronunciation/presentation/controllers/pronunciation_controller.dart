import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/speech/speech_recognition_service.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/utils/text_similarity.dart';
import '../../../lessons/domain/entities/vocabulary_item.dart';
import '../../../stats/domain/usecases/add_practice_time.dart';
import '../../../stats/domain/usecases/record_pronunciation_result.dart';

/// State of a single pronunciation drill word.
enum PronStatus {
  /// Awaiting the child's attempt.
  idle,

  /// Microphone is capturing.
  listening,

  /// An attempt has been scored.
  scored,
}

/// Drives the pronunciation coach: the tutor models each word, the child
/// repeats it, and the attempt is scored by comparing the speech transcript to
/// the target ([TextSimilarity]). Feedback is always encouraging; on a low
/// score the word is offered slowly with its syllables to practice.
class PronunciationController extends ChangeNotifier {
  /// Creates the controller.
  PronunciationController({
    required this.words,
    required String userId,
    required TtsService tts,
    required SpeechRecognitionService speech,
    required RecordPronunciationResult recordResult,
    required AddPracticeTime addPracticeTime,
  })  : _userId = userId,
        _tts = tts,
        _speech = speech,
        _recordResult = recordResult,
        _addPracticeTime = addPracticeTime;

  /// The words to drill.
  final List<VocabularyItem> words;

  final String _userId;
  final TtsService _tts;
  final SpeechRecognitionService _speech;
  final RecordPronunciationResult _recordResult;
  final AddPracticeTime _addPracticeTime;

  final DateTime _startedAt = DateTime.now();

  int _index = 0;
  PronStatus _status = PronStatus.idle;
  int _lastScore = 0;
  String _lastTranscript = '';
  bool _speechAvailable = false;
  bool _finished = false;

  /// The current word.
  VocabularyItem get current => words[_index];

  /// Status of the current attempt.
  PronStatus get status => _status;

  /// Score (0–100) of the last attempt.
  int get lastScore => _lastScore;

  /// What the child was heard to say last.
  String get lastTranscript => _lastTranscript;

  /// Whether speech recognition is available.
  bool get speechAvailable => _speechAvailable;

  /// Whether all words have been practiced.
  bool get finished => _finished;

  /// Whether the last attempt met the pass threshold.
  bool get passed => _lastScore >= AppConstants.pronunciationPassScore;

  /// Position in the drill (0–1).
  double get progress => (_index + 1) / words.length;

  /// 1-based current word number.
  int get position => _index + 1;

  /// Total word count.
  int get total => words.length;

  /// Prepares speech and models the first word.
  Future<void> init() async {
    await _tts.init();
    _speechAvailable = await _speech.init();
    notifyListeners();
    await _tts.speak(current.italian);
  }

  /// Speaks the current word at normal speed.
  Future<void> hear() => _tts.speak(current.italian);

  /// Speaks the current word slowly for syllable practice.
  Future<void> hearSlow() => _tts.speakSlow(current.italian);

  /// Starts listening for the child's attempt.
  Future<void> listen() async {
    if (!_speechAvailable || _status == PronStatus.listening) return;
    _status = PronStatus.listening;
    _lastTranscript = '';
    notifyListeners();
    await _speech.listen(
      onResult: (String transcript, bool isFinal) {
        _lastTranscript = transcript;
        notifyListeners();
        if (isFinal) _score(transcript);
      },
    );
  }

  /// Stops listening and scores whatever was captured.
  Future<void> stopListening() async {
    await _speech.stop();
    if (_status == PronStatus.listening) _score(_lastTranscript);
  }

  /// Scores a typed attempt (fallback when speech is unavailable).
  void submitTyped(String text) => _score(text);

  /// Manual override: the child says they pronounced it right, so accept it.
  /// A guard against the recognizer simply mishearing a correct attempt.
  void acceptManually() {
    _lastScore = 100;
    _status = PronStatus.scored;
    notifyListeners();
    _recordResult(userId: _userId, score: 100);
  }

  void _score(String transcript) {
    final int score = TextSimilarity.bestScore(<String>[transcript], current.italian);
    _lastScore = score;
    _lastTranscript = transcript.trim().isEmpty ? '(silence)' : transcript;
    _status = PronStatus.scored;
    notifyListeners();
    _recordResult(userId: _userId, score: score);
  }

  /// Moves to the next word, or finishes the drill.
  Future<void> next() async {
    if (_index < words.length - 1) {
      _index++;
      _status = PronStatus.idle;
      _lastScore = 0;
      _lastTranscript = '';
      notifyListeners();
      await hear();
    } else {
      _finished = true;
      notifyListeners();
    }
  }

  /// Persists the time spent in this drill. Call when leaving the screen.
  Future<void> saveSession() async {
    final int seconds = DateTime.now().difference(_startedAt).inSeconds;
    await _addPracticeTime(userId: _userId, seconds: seconds);
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }
}
