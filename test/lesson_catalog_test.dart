import 'package:ciao_kids/features/lessons/data/content/lesson_catalog.dart';
import 'package:ciao_kids/features/lessons/domain/entities/lesson.dart';
import 'package:ciao_kids/features/lessons/domain/entities/lesson_stage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Content-integrity tests for the bundled [LessonCatalog].
///
/// These guard the authored data: unique ids/orders, non-empty vocabulary, and
/// quizzes whose correct answers are in range. They catch authoring mistakes
/// without needing the UI.
void main() {
  test('catalog is non-empty', () {
    expect(LessonCatalog.lessons, isNotEmpty);
  });

  test('lesson ids and orders are unique', () {
    final Set<String> ids =
        LessonCatalog.lessons.map((Lesson l) => l.id).toSet();
    final Set<int> orders =
        LessonCatalog.lessons.map((Lesson l) => l.order).toSet();

    expect(ids.length, LessonCatalog.lessons.length,
        reason: 'duplicate lesson id');
    expect(orders.length, LessonCatalog.lessons.length,
        reason: 'duplicate lesson order');
  });

  test('each lesson has vocabulary and a valid quiz', () {
    for (final Lesson lesson in LessonCatalog.lessons) {
      final VocabularyStage vocab =
          lesson.stages.whereType<VocabularyStage>().single;
      expect(vocab.items, isNotEmpty, reason: '${lesson.id} has no vocabulary');

      final QuizStage quiz = lesson.stages.whereType<QuizStage>().single;
      expect(quiz.questions, isNotEmpty, reason: '${lesson.id} has no quiz');

      for (final question in quiz.questions) {
        expect(question.options.length, greaterThanOrEqualTo(2));
        expect(
          question.correctIndex,
          inInclusiveRange(0, question.options.length - 1),
          reason: '${lesson.id} has an out-of-range correct answer',
        );
      }
    }
  });
}
