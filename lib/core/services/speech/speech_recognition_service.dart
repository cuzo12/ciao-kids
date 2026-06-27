import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../constants/app_constants.dart';

/// Callback delivering a (partial or final) speech transcript.
typedef TranscriptCallback = void Function(String transcript, bool isFinal);

/// Callback delivering all candidate transcripts at the end of an utterance.
/// Recognizers rank several guesses; the right word is often not the top one.
typedef AlternativesCallback = void Function(List<String> alternatives);

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

  /// Begins listening, reporting transcripts via [onResult]. If provided,
  /// [onAlternatives] delivers every candidate guess at the end of the utterance.
  Future<void> listen({
    required TranscriptCallback onResult,
    AlternativesCallback? onAlternatives,
    String? localeId,
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

  /// The Italian locale id this device actually exposes (resolved at init).
  String _italianLocale = AppConstants.italianSttLocale;

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> init() async {
    try {
      _available = await _speech.initialize();
      if (_available) {
        // Use whatever Italian locale the device really has, instead of a
        // hard-coded guess — this is what makes it listen in Italian.
        try {
          final List<LocaleName> locales = await _speech.locales();
          final Iterable<LocaleName> italian = locales.where(
            (LocaleName l) => l.localeId.toLowerCase().startsWith('it'),
          );
          if (italian.isNotEmpty) _italianLocale = italian.first.localeId;
        } catch (_) {
          // Keep the default Italian locale if enumeration isn't supported.
        }
      }
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  @override
  Future<void> listen({
    required TranscriptCallback onResult,
    AlternativesCallback? onAlternatives,
    String? localeId,
  }) async {
    if (!_available) return;
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords, result.finalResult);
          if (result.finalResult && onAlternatives != null) {
            final List<String> alts = <String>[
              result.recognizedWords,
              for (final SpeechRecognitionWords a in result.alternates)
                a.recognizedWords,
            ].where((String s) => s.trim().isNotEmpty).toList();
            onAlternatives(alts);
          }
        },
        listenOptions: SpeechListenOptions(localeId: localeId ?? _italianLocale),
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
