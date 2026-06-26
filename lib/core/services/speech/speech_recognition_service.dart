import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../constants/app_constants.dart';

/// Callback delivering a (partial or final) speech transcript.
typedef TranscriptCallback = void Function(String transcript, bool isFinal);

/// Listens to the child and returns what they said as text.
///
/// Behind an interface so the UI depends on the capability, not the
/// `speech_to_text` plugin. Recognition is treated as optional: if the device
/// can't provide it (web without setup, denied permission, simulator), the app
/// falls back to typed input and suggestion chips — the conversation still
/// works end-to-end without a microphone.
abstract interface class SpeechRecognitionService {
  /// Initializes the engine and requests permission. Returns whether speech
  /// recognition is available on this device.
  Future<bool> init();

  /// Whether recognition initialized successfully and may be used.
  bool get isAvailable;

  /// Whether the engine is actively listening.
  bool get isListening;

  /// Begins listening, reporting transcripts via [onResult].
  Future<void> listen({
    required TranscriptCallback onResult,
    String localeId,
  });

  /// Stops listening (keeping any final result already delivered).
  Future<void> stop();
}

/// [SpeechRecognitionService] backed by the `speech_to_text` plugin.
class SttSpeechRecognitionService implements SpeechRecognitionService {
  /// Creates the service (call [init] before first use).
  SttSpeechRecognitionService();

  final SpeechToText _speech = SpeechToText();
  bool _available = false;

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> init() async {
    try {
      _available = await _speech.initialize();
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  @override
  Future<void> listen({
    required TranscriptCallback onResult,
    String localeId = AppConstants.italianSttLocale,
  }) async {
    if (!_available) return;
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) =>
            onResult(result.recognizedWords, result.finalResult),
        listenOptions: SpeechListenOptions(localeId: localeId),
      );
    } catch (_) {
      // Treat any listen failure as "no input"; the UI offers typed fallback.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {
      // ignore
    }
  }
}
