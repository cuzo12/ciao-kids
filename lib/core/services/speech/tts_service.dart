import 'package:flutter_tts/flutter_tts.dart';

import '../../constants/app_constants.dart';

/// Speaks Italian text aloud (the tutor's voice).
///
/// Defined as an interface so the rest of the app depends on the capability,
/// not the `flutter_tts` plugin. All methods fail soft: if synthesis is
/// unavailable (e.g. unsupported platform, no voice installed) calls are no-ops
/// rather than errors, so audio is always an enhancement and never a blocker.
abstract interface class TtsService {
  /// Prepares the engine (language, rate). Safe to call more than once.
  Future<void> init();

  /// Speaks [text] in Italian, interrupting any current utterance.
  Future<void> speak(String text);

  /// Speaks [text] extra slowly for syllable-by-syllable practice.
  Future<void> speakSlow(String text);

  /// Stops any in-progress speech.
  Future<void> stop();
}

/// [TtsService] backed by the `flutter_tts` plugin.
class FlutterTtsService implements TtsService {
  /// Creates the service (call [init] before first use).
  FlutterTtsService();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  @override
  Future<void> init() async {
    if (_ready) return;
    try {
      await _tts.setLanguage(AppConstants.italianTtsLocale);
      // A slower rate helps young learners catch each syllable.
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await init();
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // Audio is optional — never surface a TTS failure to the child.
    }
  }

  @override
  Future<void> speakSlow(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await init();
      await _tts.stop();
      await _tts.setSpeechRate(0.28);
      await _tts.speak(text);
      await _tts.setSpeechRate(0.45); // restore the default learner rate
    } catch (_) {
      // Audio is optional.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // ignore
    }
  }
}

