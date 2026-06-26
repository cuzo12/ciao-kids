/// Low-level exceptions thrown by the data layer (datasources).
///
/// These are deliberately distinct from [Failure]s: exceptions are thrown deep
/// in the stack (e.g. a datasource), caught by repositories, and translated
/// into user-safe [Failure]s. Presentation code should never see these types.
library;

/// Base class for all Ciao Kids data-layer exceptions.
sealed class AppException implements Exception {
  /// Creates an exception carrying a developer-facing [message].
  const AppException(this.message);

  /// Developer-facing description (not shown to children/parents directly).
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when local persistence (read/write) fails unexpectedly.
final class CacheException extends AppException {
  /// Creates a [CacheException].
  const CacheException([super.message = 'A local storage error occurred.']);
}

/// Thrown when credentials are invalid or the account does not exist.
final class AuthException extends AppException {
  /// Creates an [AuthException].
  const AuthException([super.message = 'Authentication failed.']);
}

/// Thrown when attempting to register an email that already exists.
final class EmailAlreadyInUseException extends AppException {
  /// Creates an [EmailAlreadyInUseException].
  const EmailAlreadyInUseException([super.message = 'Email already in use.']);
}
