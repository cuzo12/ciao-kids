import '../../../../core/result/result.dart';
import '../repositories/auth_repository.dart';

/// Use case: sign the current user out.
class SignOut {
  /// Creates the use case with its [AuthRepository] dependency.
  const SignOut(this._repository);

  final AuthRepository _repository;

  /// Executes the sign-out.
  Future<Result<void>> call() => _repository.signOut();
}
