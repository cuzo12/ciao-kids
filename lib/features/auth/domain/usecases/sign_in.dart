import '../../../../core/result/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case: sign an existing user in.
///
/// Use cases are single-responsibility, callable objects that express one piece
/// of application behavior. They keep controllers thin and make business intent
/// readable (`signIn(email, password)`), while staying trivial to mock in tests.
class SignIn {
  /// Creates the use case with its [AuthRepository] dependency.
  const SignIn(this._repository);

  final AuthRepository _repository;

  /// Executes the sign-in.
  Future<Result<AppUser>> call({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}
