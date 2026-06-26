import 'package:ciao_kids/features/conversation/data/content/conversation_catalog.dart';
import 'package:ciao_kids/features/conversation/data/engines/scripted_tutor_engine.dart';
import 'package:ciao_kids/features/conversation/domain/entities/conversation_script.dart';
import 'package:ciao_kids/features/conversation/domain/entities/conversation_step.dart';
import 'package:ciao_kids/features/conversation/domain/entities/tutor_response.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the offline [ScriptedTutorEngine] matching and branching.
void main() {
  const ConversationScript script = ConversationScript(
    id: 'test',
    title: 'Test',
    subtitle: 'sub',
    characterName: 'Tester',
    characterEmoji: '🧪',
    intro: 'Ciao',
    introEnglish: 'Hi',
    steps: <ConversationStep>[
      ConversationStep(
        tutorItalian: 'Come ti chiami?',
        tutorEnglish: 'name?',
        expectedAnswers: <String>['mi chiamo', 'sono'],
        suggestions: <String>['Mi chiamo Sofia'],
        successReply: 'Bene!',
        retryHint: 'try',
      ),
      ConversationStep(
        tutorItalian: 'Come stai?',
        tutorEnglish: 'how?',
        expectedAnswers: <String>['bene'],
        suggestions: <String>['Sto bene'],
        successReply: 'Ottimo!',
        retryHint: 'try',
      ),
    ],
    closing: 'Ciao ciao',
    closingEnglish: 'bye',
  );

  late ScriptedTutorEngine engine;

  setUp(() => engine = ScriptedTutorEngine());

  test('greeting opens with intro + first question', () {
    final TutorResponse r = engine.greeting(script);
    expect(r.messages.length, 2);
    expect(r.messages.last.text, 'Come ti chiami?');
    expect(r.finished, isFalse);
    expect(r.nextStepIndex, 0);
    expect(r.suggestions, <String>['Mi chiamo Sofia']);
  });

  test('a correct answer advances to the next step', () {
    final TutorResponse r = engine.evaluate(
      script: script,
      stepIndex: 0,
      attempt: 0,
      utterance: 'Mi chiamo Marco',
    );
    expect(r.understood, isTrue);
    expect(r.nextStepIndex, 1);
    expect(r.finished, isFalse);
    expect(r.messages.any((m) => m.text == 'Come stai?'), isTrue);
  });

  test('matching ignores case and accents', () {
    final TutorResponse r = engine.evaluate(
      script: script,
      stepIndex: 0,
      attempt: 0,
      utterance: 'SONO Giulia',
    );
    expect(r.understood, isTrue);
  });

  test('a miss within the attempt limit stays on the step', () {
    final TutorResponse r = engine.evaluate(
      script: script,
      stepIndex: 0,
      attempt: 0,
      utterance: 'banana',
    );
    expect(r.understood, isFalse);
    expect(r.nextStepIndex, 0);
    expect(r.messages.first.isCorrection, isTrue);
  });

  test('after the attempt limit, it reveals the answer and advances', () {
    final TutorResponse r = engine.evaluate(
      script: script,
      stepIndex: 0,
      attempt: 1, // second miss reaches the limit
      utterance: 'banana',
    );
    expect(r.understood, isFalse);
    expect(r.nextStepIndex, 1);
    expect(r.messages.first.text, contains('Mi chiamo Sofia'));
  });

  test('finishing the last step ends with the closing', () {
    final TutorResponse r = engine.evaluate(
      script: script,
      stepIndex: 1,
      attempt: 0,
      utterance: 'Sto bene',
    );
    expect(r.understood, isTrue);
    expect(r.finished, isTrue);
    expect(r.messages.last.text, 'Ciao ciao');
  });

  group('catalog integrity', () {
    test('scripts are well-formed', () {
      expect(ConversationCatalog.scripts, isNotEmpty);
      final Set<String> ids =
          ConversationCatalog.scripts.map((ConversationScript s) => s.id).toSet();
      expect(ids.length, ConversationCatalog.scripts.length);

      for (final ConversationScript s in ConversationCatalog.scripts) {
        expect(s.steps, isNotEmpty, reason: '${s.id} has no steps');
        for (final ConversationStep step in s.steps) {
          expect(step.expectedAnswers, isNotEmpty);
          expect(step.suggestions, isNotEmpty);
        }
      }
    });
  });
}
