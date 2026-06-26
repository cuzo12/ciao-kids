import 'package:equatable/equatable.dart';

/// A signed-in user of Ciao Kids.
///
/// In this product a "user" is the learner's profile (a child), typically set
/// up by a parent. The entity is intentionally free of any serialization or
/// framework concerns — that belongs to the data layer ([AppUserModel]) — so
/// the domain stays pure and testable.
///
/// Reward/progress fields ([coins], [xp], [streakDays]) are included from the
/// start so later milestones can populate them without a schema migration.
class AppUser extends Equatable {
  /// Creates an immutable [AppUser].
  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.childAge,
    required this.createdAt,
    this.isGuest = false,
    this.coins = 0,
    this.xp = 0,
    this.streakDays = 0,
  });

  /// Stable unique identifier (UUID locally; Firebase UID later).
  final String id;

  /// The child's chosen name, shown throughout the app.
  final String displayName;

  /// Account email (also the parent's contact for the dashboard).
  final String email;

  /// The child's age in years; gates age-appropriate content (5–15).
  final int childAge;

  /// When the account was created.
  final DateTime createdAt;

  /// Whether this is a temporary guest session (no persisted credentials).
  final bool isGuest;

  /// Reward currency balance.
  final int coins;

  /// Experience points earned across lessons.
  final int xp;

  /// Current daily-practice streak length, in days.
  final int streakDays;

  /// Returns the first name (text before the first space) for friendly copy.
  String get firstName =>
      displayName.trim().isEmpty ? displayName : displayName.trim().split(' ').first;

  /// Returns a copy with selected fields overridden.
  AppUser copyWith({
    String? displayName,
    String? email,
    int? childAge,
    int? coins,
    int? xp,
    int? streakDays,
  }) {
    return AppUser(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      childAge: childAge ?? this.childAge,
      createdAt: createdAt,
      isGuest: isGuest,
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  @override
  List<Object?> get props =>
      [id, displayName, email, childAge, createdAt, isGuest, coins, xp, streakDays];
}
