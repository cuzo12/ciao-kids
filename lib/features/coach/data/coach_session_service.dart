import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../mastery/data/mastery_service.dart';
import 'coach_profile.dart';

/// Asks the AI coach to generate a personalized mini-lesson based on the
/// learner's weak words, mastery stats, goals, and interests.
///
/// The response is structured JSON that the coach screen renders into
/// vocab cards, exercises, and a conversation prompt. Falls back to a
/// simple offline session if the proxy is unavailable.
class CoachSessionService {
  CoachSessionService({required this.mastery, http.Client? client})
      : _client = client ?? http.Client();

  final MasteryService mastery;
  final http.Client _client;

  /// Generates a personalized session. Returns parsed JSON with keys:
  /// `greeting`, `vocab` (list of {it, en, tip}), `exercise` (a question
  /// string), `conversationPrompt`, `encouragement`.
  Future<Map<String, dynamic>> generate({
    required String userId,
    required CoachProfile profile,
  }) async {
    final int seen = mastery.seenCount(userId);
    final int mastered = mastery.masteredCount(userId);
    final int total = mastery.poolSize;

    final List<String> weakWords = mastery
        .draw(userId, 6)
        .map((w) => '${w.it} (${w.en})')
        .toList();

    final String systemPrompt = _buildSystemPrompt(profile, seen, mastered, total, weakWords);

    if (!AppConfig.claudeEnabled) return _offlineFallback(weakWords);

    try {
      final http.Response resp = await _client
          .post(
            Uri.parse(AppConfig.claudeProxyUrl),
            headers: <String, String>{'content-type': 'application/json'},
            body: jsonEncode(<String, dynamic>{
              'childAge': 11,
              'topic': 'personalized coach session',
              'messages': <Map<String, String>>[
                <String, String>{
                  'role': 'user',
                  'content': systemPrompt,
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(resp.body) as Map<String, dynamic>;
        final String reply = (data['reply'] as String?) ?? '';
        return _parseCoachReply(reply, weakWords);
      }
    } catch (_) {
      // Fall through to offline fallback.
    }
    return _offlineFallback(weakWords);
  }

  String _buildSystemPrompt(
    CoachProfile profile,
    int seen,
    int mastered,
    int total,
    List<String> weakWords,
  ) {
    final StringBuffer sb = StringBuffer();
    sb.writeln('You are an Italian language coach. Generate a SHORT personalized lesson.');
    sb.writeln('');
    sb.writeln('Student info:');
    sb.writeln('- Goal: ${profile.goalLabel}');
    if (profile.tripDate != null) sb.writeln('- Trip in: ${profile.daysUntilTrip ?? "soon"}');
    sb.writeln('- Level: ${profile.level} (1=beginner, 2=intermediate, 3=advanced)');
    sb.writeln('- Interests: ${profile.interests.join(", ")}');
    sb.writeln('- Words seen: $seen / $total, mastered: $mastered');
    sb.writeln('- Weak words (needs practice): ${weakWords.join(", ")}');
    sb.writeln('');
    sb.writeln('Reply with EXACTLY this format (no extra text):');
    sb.writeln('GREETING: (one encouraging sentence)');
    sb.writeln('WORD1: Italian | English | one short usage tip');
    sb.writeln('WORD2: Italian | English | one short usage tip');
    sb.writeln('WORD3: Italian | English | one short usage tip');
    sb.writeln('EXERCISE: (a fill-in-the-blank or translate question using the weak words)');
    sb.writeln('CONVERSATION: (a conversation starter prompt for the student to practice)');
    sb.writeln('ENCOURAGEMENT: (one motivating sentence about their progress)');
    return sb.toString();
  }

  Map<String, dynamic> _parseCoachReply(String reply, List<String> weakWords) {
    final Map<String, dynamic> result = <String, dynamic>{
      'greeting': '',
      'vocab': <Map<String, String>>[],
      'exercise': '',
      'conversationPrompt': '',
      'encouragement': '',
    };

    for (final String line in reply.split('\n')) {
      final String trimmed = line.trim();
      if (trimmed.startsWith('GREETING:')) {
        result['greeting'] = trimmed.substring(9).trim();
      } else if (trimmed.startsWith('WORD')) {
        final int colon = trimmed.indexOf(':');
        if (colon > 0) {
          final List<String> parts = trimmed.substring(colon + 1).split('|');
          if (parts.length >= 2) {
            (result['vocab'] as List<Map<String, String>>).add(<String, String>{
              'it': parts[0].trim(),
              'en': parts[1].trim(),
              'tip': parts.length > 2 ? parts[2].trim() : '',
            });
          }
        }
      } else if (trimmed.startsWith('EXERCISE:')) {
        result['exercise'] = trimmed.substring(9).trim();
      } else if (trimmed.startsWith('CONVERSATION:')) {
        result['conversationPrompt'] = trimmed.substring(13).trim();
      } else if (trimmed.startsWith('ENCOURAGEMENT:')) {
        result['encouragement'] = trimmed.substring(14).trim();
      }
    }

    if ((result['greeting'] as String).isEmpty) {
      return _offlineFallback(weakWords);
    }
    return result;
  }

  Map<String, dynamic> _offlineFallback(List<String> weakWords) => <String, dynamic>{
    'greeting': "Let's focus on the words that need the most practice!",
    'vocab': <Map<String, String>>[
      for (final String w in weakWords.take(3))
        <String, String>{
          'it': w.split(' (').first,
          'en': w.contains('(') ? w.split('(').last.replaceAll(')', '') : '',
          'tip': 'Practice this one today!',
        },
    ],
    'exercise': 'Try using these words in a sentence with Giulia.',
    'conversationPrompt': 'Tell Giulia about your day using these words.',
    'encouragement': 'Every word you learn is one step closer to Italy!',
  };

  void dispose() => _client.close();
}
