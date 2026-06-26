import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../conversation/domain/entities/chat_message.dart';

/// Thrown when the Claude tutor proxy can't be reached or returns an error.
class TutorUnavailable implements Exception {
  /// Creates a [TutorUnavailable] with a child-safe [message].
  const TutorUnavailable([this.message = 'The tutor is napping. Try again!']);

  /// Friendly message safe to show the child.
  final String message;

  @override
  String toString() => 'TutorUnavailable: $message';
}

/// Calls the Cloudflare Worker that proxies Claude (see `cloudflare/worker.js`).
///
/// The Worker — not this app — holds the Anthropic API key. This service only
/// sends the conversation so far plus light context (child age, topic) and gets
/// back the tutor's next line. It never sees a key.
class RemoteTutorService {
  /// Creates the service targeting [proxyUrl]; inject [client] in tests.
  RemoteTutorService({required this.proxyUrl, http.Client? client})
      : _client = client ?? http.Client();

  /// The deployed Worker URL.
  final String proxyUrl;
  final http.Client _client;

  /// Sends [history] (oldest→newest) and returns the tutor's reply text.
  Future<String> reply({
    required List<ChatMessage> history,
    required int childAge,
    required String topic,
  }) async {
    final List<Map<String, String>> messages = <Map<String, String>>[
      for (final ChatMessage m in history)
        <String, String>{
          'role': m.sender == MessageSender.child ? 'user' : 'assistant',
          'content': m.text,
        },
    ];

    http.Response resp;
    try {
      resp = await _client
          .post(
            Uri.parse(proxyUrl),
            headers: <String, String>{'content-type': 'application/json'},
            body: jsonEncode(<String, dynamic>{
              'childAge': childAge,
              'topic': topic,
              'messages': messages,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const TutorUnavailable();
    }

    if (resp.statusCode != 200) {
      throw const TutorUnavailable();
    }

    try {
      final Map<String, dynamic> data =
          jsonDecode(resp.body) as Map<String, dynamic>;
      final String reply = (data['reply'] as String?)?.trim() ?? '';
      if (reply.isEmpty) throw const TutorUnavailable();
      return reply;
    } catch (_) {
      throw const TutorUnavailable();
    }
  }

  /// Releases the underlying HTTP client.
  void dispose() => _client.close();
}
