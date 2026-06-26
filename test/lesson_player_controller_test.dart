import 'package:ciao_kids/features/lessons/domain/entities/lesson.dart';
import 'package:ciao_kids/features/lessons/domain/entities/lesson_stage.dart';
import 'package:ciao_kids/features/lessons/domain/entities/quiz_question.dart';
import 'package:ciao_kids/features/lessons/presentation/controllers/lesson_player_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the pure scoring logic in [LessonPlayerController].
void main() {
  Lesson buildLesson() {
    return const Lesson(
      id: 'test',
      title: 'Test',
      emoji: '🧪',
      subtitle: 'A test lesson',
      order: 1,
      stages: <LessonStage>[
        QuizStage(<QuizQuestion>[
          QuizQuestion(
            prompt: 'Q1',
            options: <String>['right', 'wrong'],
            correctIndex: 0,
          ),
          QuizQuestion(
            prompt: 'Q2',
            options: <String>['wrong', 'right'],
            correctIndex: 1,
          ),
        ]),
        ReviewStage(message: 'Done'),
      ],
    );
  }

  test('starts unanswered and reports the right question count', () {
    final LessonPlayerController c =
        LessonPlayerController(lesson: buildLesson());
    expect(c.totalQuestions, 2);
    expect(c.allAnswered, isFalse);
    expect(c.correctCount, 0);
  });

  test('a perfect score earns three stars', () {
    final LessonPlayerController c =
        LessonPlayerController(lesson: buildLesson())
          ..answerQuestion(0, 0)
          ..answerQuestion(1, 1);

    expect(c.allAnswered, isTrue);
    expect(c.correctCount, 2);
    expect(c.scorePercent, 100);
    expect(c.stars, 3);
  });

  test('half correct scores 50% and one star', () {
    final LessonPlayerController c =
        LessonPlayerController(lesson: buildLesson())
          ..answerQuestion(0, 0) // correct
          ..answerQuestion(1, 0); // wrong

    expect(c.correctCount, 1);
    expect(c.scorePercent, 50);
    expect(c.stars, 1);
  });

  test('navigation clamps at the first and last stage', () {
    final LessonPlayerController c =
        LessonPlayerController(lesson: buildLesson());
    expect(c.isFirst, isTrue);
    c.back(); // no-op at start
    expect(c.index, 0);

    c.next();
    expect(c.isLast, isTrue);
    c.next(); // no-op at end
    expect(c.index, 1);
  });
}
