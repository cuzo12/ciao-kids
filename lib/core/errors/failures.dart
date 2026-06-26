import 'package:equatable/equatable.dart';

/// User-facing failures returned from the domain layer.
///
/// A [Failure] is the "safe" counterpart to an [AppException]: repositories
/// translate thrown exceptions into a [Failure] carrying a friendly,
/// child-appropriate [message] that controllers can show directly.
sealed class Failure extends Equatable {
  /// Creates a failure with a friendly, display-ready [message].
  const Failure(this.message);

  /// Message safe to render in the UI.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// A failure caused by invalid or missing credentials.
final class AuthFailure extends Failure {
  /// Creates an [AuthFailure].
  const AuthFailure([super.message = 'We couldn\'t sign you in. Try again.']);
}

/// A failure caused by attempting to register an existing email.
final class EmailInUseFailure extends Failure {
  /// Creates an [EmailInUseFailure].
  const EmailInUseFailure(
      [super.message = 'That email is already registered.']);
}

/// A failure caused by local storage problems.
final class CacheFailure extends Failure {
  /// Creates a [CacheFailure].
  const CacheFailure([super.message = 'Something went wrong. Please retry.']);
}

/// A catch-all failure for unexpected errors.
final class UnknownFailure extends Failure {
  /// Creates an [UnknownFailure].
  const UnknownFailure([super.message = 'Oops! Something went wrong.']);
}
