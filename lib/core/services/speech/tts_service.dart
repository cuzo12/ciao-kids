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
      await _selectBestItalianVoice();
      // A natural conversational pace (not the choppy slow that sounds robotic),
      // with a slightly brighter pitch for a friendly girl voice.
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.08);
      await _tts.awaitSpeakCompletion(true);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  /// Picks the smoothest, most natural-sounding female Italian voice available.
  ///
  /// Default "compact" voices sound robotic; higher-quality voices (Apple
  /// "enhanced/premium", Google/Microsoft "neural/natural") sound far smoother.
  /// We also prefer a female voice to match the tutor persona (Giulia). Falls
  /// back silently to the platform default when nothing better is installed.
  Future<void> _selectBestItalianVoice() async {
    try {
      final dynamic raw = await _tts.getVoices;
      if (raw is! List) return;

      Map<String, dynamic>? best;
      int bestScore = -1;
      for (final dynamic v in raw) {
        if (v is! Map) continue;
        final String locale = '${v['locale'] ?? ''}'.toLowerCase();
        if (!locale.startsWith('it')) continue;
        final String name = '${v['name'] ?? ''}'.toLowerCase();

        int score = 0;
        for (final String q in const <String>[
          'enhanced', 'premium', 'neural', 'natural',
        ]) {
          if (name.contains(q)) score += 6;
        }
        for (final String f in const <String>[
          'female', 'alice', 'federica', 'elsa', 'isabella',
          'giulia', 'paola', 'luciana', 'emma', 'google',
        ]) {
          if (name.contains(f)) score += 4;
        }
        for (final String m in const <String>[
          'male', 'cosimo', 'diego', 'paolo', 'luca',
        ]) {
          if (name.contains(m)) score -= 6;
        }
        if (name.contains('compact')) score -= 3;

        if (score > bestScore) {
          bestScore = score;
          best = <String, dynamic>{'name': v['name'], 'locale': v['locale']};
        }
      }

      if (best != null) {
        await _tts.setVoice(<String, String>{
          'name': '${best['name']}',
          'locale': '${best['locale']}',
        });
      }
    } catch (_) {
      // Voice selection is best-effort; keep the default voice on any failure.
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
      await _tts.setSpeechRate(0.5); // restore the default conversational rate
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

