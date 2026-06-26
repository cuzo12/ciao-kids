import '../../../../core/result/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case: register a new account.
class SignUp {
  /// Creates the use case with its [AuthRepository] dependency.
  const SignUp(this._repository);

  final AuthRepository _repository;

  /// Executes the registration.
  Future<Result<AppUser>> call({
    required String displayName,
    required String email,
    required String password,
    required int childAge,
  }) {
    return _repository.signUp(
      displayName: displayName,
      email: email,
      password: password,
      childAge: childAge,
    );
  }
}
