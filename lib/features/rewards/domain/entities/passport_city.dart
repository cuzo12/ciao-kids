import 'package:equatable/equatable.dart';

/// An Italian city stamped into the virtual passport as the child progresses.
///
/// A city is "unlocked" (stamped) once [unlockAtLessons] lessons are completed.
class PassportCity extends Equatable {
  /// Creates a [PassportCity].
  const PassportCity({
    required this.name,
    required this.emoji,
    required this.landmark,
    required this.unlockAtLessons,
  });

  /// City name (e.g. "Roma").
  final String name;

  /// A representative emoji (landmark / icon).
  final String emoji;

  /// Short landmark caption (e.g. "Colosseo").
  final String landmark;

  /// Lessons-completed threshold at which the city unlocks.
  final int unlockAtLessons;

  @override
  List<Object?> get props => <Object?>[name, emoji, landmark, unlockAtLessons];
}
