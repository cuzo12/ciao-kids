import '../../../../core/result/result.dart';
import '../entities/app_user.dart';

/// Contract for authentication, owned by the domain layer.
///
/// The presentation layer depends only on this abstraction; the concrete
/// implementation ([AuthRepositoryImpl]) and its datasource can be swapped from
/// a local store to Firebase Auth without touching any UI or use case. This is
/// the dependency-inversion boundary of the auth feature.
abstract interface class AuthRepository {
  /// Signs an existing user in with [email] and [password].
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  /// Registers a new account and returns the created [AppUser].
  Future<Result<AppUser>> signUp({
    required String displayName,
    required String email,
    required String password,
    required int childAge,
  });

  /// Creates a temporary guest session for instant, no-signup access.
  Future<Result<AppUser>> continueAsGuest();

  /// Signs the current user out and clears the persisted session.
  Future<Result<void>> signOut();

  /// Returns the currently persisted user, or `null` if signed out.
  Future<AppUser?> currentUser();
}
