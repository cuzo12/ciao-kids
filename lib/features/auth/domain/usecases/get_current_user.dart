import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case: read the persisted session on app start.
class GetCurrentUser {
  /// Creates the use case with its [AuthRepository] dependency.
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  /// Returns the restored user, or `null` when no session exists.
  Future<AppUser?> call() => _repository.currentUser();
}
