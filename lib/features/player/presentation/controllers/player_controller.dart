import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/avatar_catalog.dart';

/// The gamification + economy layer: daily goal, streak, coin wallet, avatar.
///
/// A single [ChangeNotifier] so the home header updates live whenever an
/// activity awards XP/coins. State is persisted per user in `shared_preferences`
/// (no backend needed). Activities call [record]; the avatar shop calls [buy]
/// and [equip].
class PlayerController extends ChangeNotifier {
  PlayerController(this._prefs);

  final SharedPreferences _prefs;

  /// Daily XP target that fills the goal ring.
  static const int dailyGoal = 50;

  String _userId = '';
  bool _loaded = false;

  String _todayDate = '';
  String _lastActiveDate = '';
  int _todayXp = 0;
  int _streakDays = 0;
  int _freezes = 0;
  int _coins = 0;
  Set<String> _unlocked = <String>{...AvatarCatalog.defaultUnlocked};
  Map<String, String> _equipped = <String, String>{...AvatarCatalog.defaultEquipped};

  // --- Read API ------------------------------------------------------------

  int get todayXp => _todayXp;
  double get goalProgress => (_todayXp / dailyGoal).clamp(0, 1).toDouble();
  bool get goalMet => _todayXp >= dailyGoal;
  int get streakDays => _streakDays;
  int get freezes => _freezes;
  int get coins => _coins;

  bool isUnlocked(String id) => _unlocked.contains(id);
  String equippedId(AvatarSlot slot) =>
      _equipped[AvatarCatalog.slotKey(slot)] ?? AvatarCatalog.defaultEquipped[AvatarCatalog.slotKey(slot)]!;
  String equippedEmoji(AvatarSlot slot) => AvatarCatalog.byId(equippedId(slot)).emoji;

  // --- Lifecycle -----------------------------------------------------------

  String _key(String userId) => 'ciao_kids.player.$userId';
  String _todayStr() {
    final DateTime n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  /// Loads the player profile for [userId]. Call once when the home loads.
  Future<void> load(String userId) async {
    _userId = userId;
    final String? raw = _prefs.getString(_key(userId));
    if (raw != null) {
      try {
        final Map<String, dynamic> j = jsonDecode(raw) as Map<String, dynamic>;
        _todayDate = j['todayDate'] as String? ?? '';
        _lastActiveDate = j['lastActiveDate'] as String? ?? '';
        _todayXp = (j['todayXp'] as num?)?.toInt() ?? 0;
        _streakDays = (j['streakDays'] as num?)?.toInt() ?? 0;
        _freezes = (j['freezes'] as num?)?.toInt() ?? 0;
        _coins = (j['coins'] as num?)?.toInt() ?? 0;
        _unlocked = ((j['unlocked'] as List<dynamic>?) ?? <dynamic>[])
            .map((dynamic e) => e as String)
            .toSet()
          ..addAll(AvatarCatalog.defaultUnlocked);
        final Map<String, dynamic> eq = (j['equipped'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        _equipped = <String, String>{
          ...AvatarCatalog.defaultEquipped,
          for (final MapEntry<String, dynamic> e in eq.entries) e.key: e.value as String,
        };
      } catch (_) {
        // Corrupt blob — start fresh with defaults.
      }
    }
    // Reset today's XP if the stored day is stale (don't touch streak here;
    // streak only advances when the child actually practices — see record()).
    if (_todayDate != _todayStr()) _todayXp = 0;
    _loaded = true;
    notifyListeners();
  }

  // --- Mutations -----------------------------------------------------------

  /// Records an activity's reward. Advances the daily goal and streak.
  Future<void> record({required int xp, int coins = 0}) async {
    if (!_loaded) return;
    final String today = _todayStr();
    if (_todayDate != today) {
      _advanceStreak(today);
      _todayDate = today;
      _todayXp = 0;
    }
    _lastActiveDate = today;
    _todayXp += xp;
    _coins += coins;
    await _persist();
    notifyListeners();
  }

  void _advanceStreak(String today) {
    if (_lastActiveDate.isEmpty) {
      _streakDays = 1;
    } else {
      final DateTime last = DateTime.parse(_lastActiveDate);
      final DateTime t = DateTime.parse(today);
      final int gap = t.difference(DateTime(last.year, last.month, last.day)).inDays;
      if (gap <= 1) {
        _streakDays += 1;
      } else if (gap == 2 && _freezes > 0) {
        _freezes -= 1; // a streak freeze covers exactly one missed day
        _streakDays += 1;
      } else {
        _streakDays = 1;
      }
    }
    // Reward a streak freeze at every 5-day milestone (capped at 3).
    if (_streakDays % 5 == 0 && _freezes < 3) _freezes += 1;
  }

  /// Buys [item] if affordable. Returns whether the purchase succeeded.
  Future<bool> buy(AvatarItem item) async {
    if (!_loaded || _unlocked.contains(item.id) || _coins < item.cost) return false;
    _coins -= item.cost;
    _unlocked.add(item.id);
    await _persist();
    notifyListeners();
    return true;
  }

  /// Equips an already-unlocked [item].
  Future<void> equip(AvatarItem item) async {
    if (!_loaded || !_unlocked.contains(item.id)) return;
    _equipped[AvatarCatalog.slotKey(item.slot)] = item.id;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key(_userId),
      jsonEncode(<String, dynamic>{
        'todayDate': _todayDate,
        'lastActiveDate': _lastActiveDate,
        'todayXp': _todayXp,
        'streakDays': _streakDays,
        'freezes': _freezes,
        'coins': _coins,
        'unlocked': _unlocked.toList(),
        'equipped': _equipped,
      }),
    );
  }
}
