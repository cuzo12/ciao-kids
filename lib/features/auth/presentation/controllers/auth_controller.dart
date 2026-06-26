import 'package:flutter/foundation.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/continue_as_guest.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';

/// High-level authentication state of the app.
enum AuthStatus {
  /// Session restore is still in progress (show splash).
  unknown,

  /// A user is signed in.
  authenticated,

  /// No user is signed in.
  unauthenticated,
}

/// Presentation-layer state holder for authentication.
///
/// A [ChangeNotifier] (consumed via `provider`) that orchestrates the auth use
/// cases and exposes a small, UI-friendly surface: [status], the active [user],
/// a transient [busy] flag for buttons/spinners, and the last [errorMessage].
///
/// It is also the router's `refreshListenable`, so every `notifyListeners()`
/// here re-evaluates navigation guards (see [AppRouter]).
class AuthController extends ChangeNotifier {
  /// Creates the controller with its injected use cases.
  AuthController({
    required GetCurrentUser getCurrentUser,
    required SignIn signIn,
    required SignUp signUp,
    required SignOut signOut,
    required ContinueAsGuest continueAsGuest,
  })  : _getCurrentUser = getCurrentUser,
        _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _continueAsGuest = continueAsGuest;

  final GetCurrentUser _getCurrentUser;
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final ContinueAsGuest _continueAsGuest;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  bool _busy = false;
  String? _errorMessage;

  /// Current authentication status.
  AuthStatus get status => _status;

  /// The signed-in user, or `null`.
  AppUser? get user => _user;

  /// Whether an auth operation is in flight (drives button spinners).
  bool get busy => _busy;

  /// The most recent error message, or `null` if the last action succeeded.
  String? get errorMessage => _errorMessage;

  /// Restores any persisted session. Called once on app start.
  Future<void> appStarted() async {
    final AppUser? restored = await _getCurrentUser();
    _user = restored;
    _status = restored == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  /// Attempts sign-in; returns `true` on success.
  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _signIn(email: email, password: password));
  }

  /// Attempts registration; returns `true` on success.
  Future<bool> signUp({
    required String displayName,
    required String email,
    required String password,
    required int childAge,
  }) {
    return _run(
      () => _signUp(
        displayName: displayName,
        email: email,
        password: password,
        childAge: childAge,
      ),
    );
  }

  /// Starts a guest session; returns `true` on success.
  Future<bool> continueAsGuest() => _run(_continueAsGuest.call);

  /// Signs out and returns to the unauthenticated state.
  Future<void> signOut() async {
    await _signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears any displayed error (e.g. when the user edits a field).
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Shared execution wrapper: toggles [busy], runs [action], and folds the
  /// [Result] into controller state.
  Future<bool> _run(Future<Result<AppUser>> Function() action) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();

    final Result<AppUser> result = await action();
    _busy = false;

    switch (result) {
      case Success<AppUser>(:final value):
        _user = value;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      case ResultError<AppUser>(:final failure):
        _errorMessage = failure.message;
        notifyListeners();
        return false;
    }
  }
}
