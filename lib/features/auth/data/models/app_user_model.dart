import '../../domain/entities/app_user.dart';

/// Data-layer representation of [AppUser] with JSON (de)serialization.
///
/// Extending the domain entity (rather than duplicating its fields) means a
/// model *is* a valid [AppUser] everywhere the domain expects one, while adding
/// the persistence concerns the domain deliberately omits.
class AppUserModel extends AppUser {
  /// Creates an [AppUserModel].
  const AppUserModel({
    required super.id,
    required super.displayName,
    required super.email,
    required super.childAge,
    required super.createdAt,
    super.isGuest,
    super.coins,
    super.xp,
    super.streakDays,
  });

  /// Builds a model from a decoded JSON map.
  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      childAge: (json['childAge'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isGuest: (json['isGuest'] as bool?) ?? false,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
    );
  }

  /// Promotes any [AppUser] (e.g. one returned from the domain) to a model.
  factory AppUserModel.fromEntity(AppUser user) {
    return AppUserModel(
      id: user.id,
      displayName: user.displayName,
      email: user.email,
      childAge: user.childAge,
      createdAt: user.createdAt,
      isGuest: user.isGuest,
      coins: user.coins,
      xp: user.xp,
      streakDays: user.streakDays,
    );
  }

  /// Serializes this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'displayName': displayName,
      'email': email,
      'childAge': childAge,
      'createdAt': createdAt.toIso8601String(),
      'isGuest': isGuest,
      'coins': coins,
      'xp': xp,
      'streakDays': streakDays,
    };
  }
}
