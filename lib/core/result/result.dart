import '../errors/failures.dart';

/// A functional result type representing either success or a [Failure].
///
/// Use cases and repositories return `Future<Result<T>>` instead of throwing,
/// which forces presentation code to handle both branches explicitly via
/// pattern matching:
///
/// ```dart
/// switch (await signIn(email: e, password: p)) {
///   case Success(:final value): // value is AppUser
///   case ResultError(:final failure): // failure.message is display-ready
/// }
/// ```
///
/// The failure branch is named [ResultError] (not `Error`) to avoid shadowing
/// `dart:core`'s `Error`.
sealed class Result<T> {
  /// Const base constructor.
  const Result();

  /// Whether this result represents success.
  bool get isSuccess => this is Success<T>;
}

/// The success branch, wrapping a [value] of type [T].
final class Success<T> extends Result<T> {
  /// Creates a successful result.
  const Success(this.value);

  /// The produced value.
  final T value;
}

/// The failure branch, wrapping a domain [failure].
final class ResultError<T> extends Result<T> {
  /// Creates a failed result.
  const ResultError(this.failure);

  /// The failure describing what went wrong.
  final Failure failure;
}
