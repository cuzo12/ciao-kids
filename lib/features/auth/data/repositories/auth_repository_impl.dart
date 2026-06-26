import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Concrete [AuthRepository] that delegates to an [AuthLocalDataSource] and
/// translates low-level [AppException]s into user-facing [Failure]s.
///
/// This translation is the repository's core job: the domain and UI above it
/// only ever deal in [Result]/[Failure], never in thrown exceptions.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates the repository over the given [dataSource].
  const AuthRepositoryImpl(this._dataSource);

  final AuthLocalDataSource _dataSource;

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) {
    return _guard(() => _dataSource.signIn(email: email, password: password));
  }

  @override
  Future<Result<AppUser>> signUp({
    required String displayName,
    required String email,
    required String password,
    required int childAge,
  }) {
    return _guard(
      () => _dataSource.signUp(
        displayName: displayName,
        email: email,
        password: password,
        childAge: childAge,
      ),
    );
  }

  @override
  Future<Result<AppUser>> continueAsGuest() {
    return _guard(_dataSource.continueAsGuest);
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Success<void>(null);
    } catch (_) {
      return const ResultError<void>(CacheFailure());
    }
  }

  @override
  Future<AppUser?> currentUser() async {
    try {
      return await _dataSource.currentUser();
    } catch (_) {
      // A failed restore should not crash startup; behave as signed out.
      return null;
    }
  }

  /// Runs [action], mapping known exceptions to their matching [Failure].
  Future<Result<AppUser>> _guard(
    Future<AppUser> Function() action,
  ) async {
    try {
      final AppUser user = await action();
      return Success<AppUser>(user);
    } on EmailAlreadyInUseException catch (e) {
      return ResultError<AppUser>(EmailInUseFailure(e.message));
    } on AuthException catch (e) {
      return ResultError<AppUser>(AuthFailure(e.message));
    } on CacheException catch (e) {
      return ResultError<AppUser>(CacheFailure(e.message));
    } catch (_) {
      return const ResultError<AppUser>(UnknownFailure());
    }
  }
}
