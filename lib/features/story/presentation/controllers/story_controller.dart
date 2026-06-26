import 'package:flutter/foundation.dart';

import '../../../../core/services/speech/speech_recognition_service.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../stats/domain/usecases/add_practice_time.dart';
import '../../../stats/domain/usecases/record_activity_completed.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_choice.dart';
import '../../domain/entities/story_node.dart';

/// Drives an interactive story: narrates the current scene (TTS), accepts a
/// branch by tap or by voice (keyword match), and walks the node graph until an
/// ending — at which point it records completion. Speech is optional.
class StoryController extends ChangeNotifier {
  /// Creates the controller.
  StoryController({
    required this.story,
    required String userId,
    required TtsService tts,
    required SpeechRecognitionService speech,
    required RecordStoryCompleted recordStory,
    required AddPracticeTime addPracticeTime,
  })  : _userId = userId,
        _tts = tts,
        _speech = speech,
        _recordStory = recordStory,
        _addPracticeTime = addPracticeTime;

  /// The story being played.
  final Story story;

  final String _userId;
  final TtsService _tts;
  final SpeechRecognitionService _speech;
  final RecordStoryCompleted _recordStory;
  final AddPracticeTime _addPracticeTime;

  final DateTime _startedAt = DateTime.now();

  late StoryNode _node = story.start;
  bool _speechAvailable = false;
  bool _listening = false;
  bool _recorded = false;
  String _partial = '';

  /// The current scene.
  StoryNode get node => _node;

  /// Whether the current scene ends the story.
  bool get isEnding => _node.isEnding;

  /// Whether speech recognition is available.
  bool get speechAvailable => _speechAvailable;

  /// Whether the mic is listening.
  bool get listening => _listening;

  /// Live partial transcript.
  String get partialTranscript => _partial;

  /// Prepares speech and narrates the opening scene.
  Future<void> init() async {
    await _tts.init();
    _speechAvailable = await _speech.init();
    notifyListeners();
    await _tts.speak(_node.narrationItalian);
    _maybeRecordEnding();
  }

  /// Re-speaks the current scene.
  Future<void> hear() => _tts.speak(_node.narrationItalian);

  /// Takes a branch.
  Future<void> choose(StoryChoice choice) async {
    final StoryNode? next = story.node(choice.nextNodeId);
    if (next == null) return;
    _node = next;
    _partial = '';
    _listening = false;
    notifyListeners();
    await _tts.speak(_node.narrationItalian);
    _maybeRecordEnding();
  }

  /// Starts/stops voice selection of a branch.
  Future<void> toggleListening() async {
    if (!_speechAvailable || isEnding) return;
    if (_listening) {
      await _speech.stop();
      _listening = false;
      notifyListeners();
      _matchAndChoose(_partial);
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
          _matchAndChoose(transcript);
        }
      },
    );
  }

  /// Persists time spent. Call when leaving the screen.
  Future<void> saveSession() async {
    await _addPracticeTime(
      userId: _userId,
      seconds: DateTime.now().difference(_startedAt).inSeconds,
    );
  }

  void _matchAndChoose(String transcript) {
    final String u = _normalize(transcript);
    if (u.isEmpty) return;
    for (final StoryChoice choice in _node.choices) {
      for (final String keyword in choice.keywords) {
        final String n = _normalize(keyword);
        if (n.isNotEmpty && (u.contains(n) || n.contains(u))) {
          choose(choice);
          return;
        }
      }
    }
  }

  void _maybeRecordEnding() {
    if (_node.isEnding && !_recorded) {
      _recorded = true;
      _recordStory(_userId);
    }
  }

  String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[^a-z ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }
}
