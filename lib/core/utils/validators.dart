import '../constants/app_constants.dart';

/// Pure, reusable form-field validators.
///
/// Each method returns `null` when the input is valid, or a friendly error
/// message string when it is not — the exact contract Flutter's
/// [TextFormField.validator] expects. Keeping them pure (no widget references)
/// makes them trivially unit-testable.
abstract final class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$',
  );

  /// Validates an email address.
  static String? email(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) return 'Please enter an email.';
    if (!_emailRegExp.hasMatch(input)) return 'That email looks off.';
    return null;
  }

  /// Validates a password against the minimum-length rule.
  static String? password(String? value) {
    final String input = value ?? '';
    if (input.isEmpty) return 'Please enter a password.';
    if (input.length < AppConstants.minPasswordLength) {
      return 'Use at least ${AppConstants.minPasswordLength} characters.';
    }
    return null;
  }

  /// Validates a display / child name.
  static String? name(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) return 'Please enter a name.';
    if (input.length < 2) return 'That name is too short.';
    return null;
  }

  /// Validates the child's age against the supported range (5–15).
  static String? childAge(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) return 'Please enter an age.';
    final int? age = int.tryParse(input);
    if (age == null) return 'Enter a number.';
    if (age < AppConstants.minChildAge || age > AppConstants.maxChildAge) {
      return 'Ages ${AppConstants.minChildAge}–${AppConstants.maxChildAge}.';
    }
    return null;
  }
}
