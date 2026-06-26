import '../../domain/entities/lesson_progress.dart';

/// Data-layer [LessonProgress] with JSON (de)serialization for local storage.
class LessonProgressModel extends LessonProgress {
  /// Creates a [LessonProgressModel].
  const LessonProgressModel({
    required super.lessonId,
    super.completed,
    super.bestStars,
    super.bestScorePercent,
  });

  /// Builds a model from a decoded JSON map.
  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      lessonId: json['lessonId'] as String,
      completed: (json['completed'] as bool?) ?? false,
      bestStars: (json['bestStars'] as num?)?.toInt() ?? 0,
      bestScorePercent: (json['bestScorePercent'] as num?)?.toInt() ?? 0,
    );
  }

  /// Promotes a domain [LessonProgress] to a serializable model.
  factory LessonProgressModel.fromEntity(LessonProgress progress) {
    return LessonProgressModel(
      lessonId: progress.lessonId,
      completed: progress.completed,
      bestStars: progress.bestStars,
      bestScorePercent: progress.bestScorePercent,
    );
  }

  /// Serializes this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lessonId': lessonId,
      'completed': completed,
      'bestStars': bestStars,
      'bestScorePercent': bestScorePercent,
    };
  }
}
