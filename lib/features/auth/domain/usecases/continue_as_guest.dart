import '../../../../core/result/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case: start a guest session for instant access without sign-up.
class ContinueAsGuest {
  /// Creates the use case with its [AuthRepository] dependency.
  const ContinueAsGuest(this._repository);

  final AuthRepository _repository;

  /// Executes the guest sign-in.
  Future<Result<AppUser>> call() => _repository.continueAsGuest();
}
