import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/app_user_model.dart';

/// On-device authentication backed by `shared_preferences`.
///
/// This is a **fully functional** auth implementation — accounts are created,
/// passwords are salted+hashed (never stored in plain text), and a session is
/// persisted across launches. It exists so the app is runnable and testable
/// end-to-end in Milestone 1 without external infrastructure.
///
/// In the cloud-auth milestone, a `AuthRemoteDataSource` backed by Firebase
/// Auth will implement the same role; because [AuthRepository] depends on an
/// abstraction, swapping it requires no changes to the domain or UI.
abstract interface class AuthLocalDataSource {
  /// Authenticates against the local store. Throws [AuthException] on failure.
  Future<AppUserModel> signIn({required String email, required String password});

  /// Creates and persists a new account, then starts its session.
  /// Throws [EmailAlreadyInUseException] if [email] is taken.
  Future<AppUserModel> signUp({
    required String displayName,
    required String email,
    required String password,
    required int childAge,
  });

  /// Starts a transient guest session (not written to the user database).
  Future<AppUserModel> continueAsGuest();

  /// Clears the active session.
  Future<void> signOut();

  /// Reads the persisted session, or `null` when signed out.
  Future<AppUserModel?> currentUser();
}

/// Default [AuthLocalDataSource] implementation over [SharedPreferences].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  /// Creates the datasource with an injected [SharedPreferences] instance.
  const AuthLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final String key = _normalize(email);
    final Map<String, dynamic> db = _readUsersDb();

    final dynamic record = db[key];
    if (record is! Map<String, dynamic>) {
      throw const AuthException('No account found for that email.');
    }

    final String storedHash = record['passwordHash'] as String;
    final String salt = record['salt'] as String;
    if (_hash(password, salt) != storedHash) {
      throw const AuthException('That password is incorrect.');
    }

    final AppUserModel user =
        AppUserModel.fromJson(record['user'] as Map<String, dynamic>);
    await _persistSession(user);
    return user;
  }

  @override
  Future<AppUserModel> signUp({
    required String displayName,
    required String email,
    required String password,
    required int childAge,
  }) async {
    final String key = _normalize(email);
    final Map<String, dynamic> db = _readUsersDb();
    if (db.containsKey(key)) {
      throw const EmailAlreadyInUseException();
    }

    final String salt = _generateSalt();
    final AppUserModel user = AppUserModel(
      id: _generateId(),
      displayName: displayName.trim(),
      email: key,
      childAge: childAge,
      createdAt: DateTime.now().toUtc(),
    );

    db[key] = <String, dynamic>{
      'salt': salt,
      'passwordHash': _hash(password, salt),
      'user': user.toJson(),
    };
    await _writeUsersDb(db);
    await _persistSession(user);
    return user;
  }

  @override
  Future<AppUserModel> continueAsGuest() async {
    final AppUserModel guest = AppUserModel(
      id: 'guest_${_generateId()}',
      displayName: 'Explorer',
      email: '',
      childAge: AppConstants.minChildAge,
      createdAt: DateTime.now().toUtc(),
      isGuest: true,
    );
    await _persistSession(guest);
    return guest;
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(AppConstants.kCurrentUserKey);
  }

  @override
  Future<AppUserModel?> currentUser() async {
    final String? raw = _prefs.getString(AppConstants.kCurrentUserKey);
    if (raw == null) return null;
    try {
      return AppUserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt session payload — treat as signed out rather than crashing.
      throw const CacheException('Saved session could not be read.');
    }
  }

  // --- Internals -----------------------------------------------------------

  Future<void> _persistSession(AppUserModel user) async {
    await _prefs.setString(
      AppConstants.kCurrentUserKey,
      jsonEncode(user.toJson()),
    );
  }

  Map<String, dynamic> _readUsersDb() {
    final String? raw = _prefs.getString(AppConstants.kUsersDbKey);
    if (raw == null) return <String, dynamic>{};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _writeUsersDb(Map<String, dynamic> db) async {
    await _prefs.setString(AppConstants.kUsersDbKey, jsonEncode(db));
  }

  String _normalize(String email) => email.trim().toLowerCase();

  /// SHA-256 of `salt + password`. Adequate for a local dev store; production
  /// authentication is delegated to Firebase Auth in a later milestone.
  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt$password')).toString();

  String _generateSalt() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(16);

  String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}'
      '${identityHashCode(Object()).toRadixString(16)}';
}
