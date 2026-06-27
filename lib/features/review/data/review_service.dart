import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../games/data/game_word_bank.dart';

/// Spaced-repetition review using a Leitner-box schedule.
///
/// Each word the child has seen lives in a "box" (0–5). A correct answer moves
/// it up a box (longer interval before it's due again); a wrong answer drops it
/// back to box 0. A session prioritizes words that are due (weakest first), then
/// fills with words not yet seen. All state is local (no backend).
class ReviewService {
  ReviewService(this._prefs);

  final SharedPreferences _prefs;

  /// Hours until a word is due again, indexed by box (0–5).
  static const List<int> _intervalHours = <int>[0, 24, 48, 96, 168, 336];

  static final List<GameWord> _pool = <GameWord>[
    ...GameWordBank.beginner,
    ...GameWordBank.intermediate,
    ...GameWordBank.advanced,
  ];

  String _key(String userId) => 'ciao_kids.review.$userId';

  Map<String, Map<String, dynamic>> _load(String userId) {
    final String? raw = _prefs.getString(_key(userId));
    if (raw == null) return <String, Map<String, dynamic>>{};
    try {
      final Map<String, dynamic> j = jsonDecode(raw) as Map<String, dynamic>;
      return j.map((String k, dynamic v) =>
          MapEntry<String, Map<String, dynamic>>(k, (v as Map<String, dynamic>)));
    } catch (_) {
      return <String, Map<String, dynamic>>{};
    }
  }

  /// Number of seen words that are currently due (for a home badge).
  int dueCount(String userId) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    return _load(userId).values.where((Map<String, dynamic> v) => (v['due'] as num) <= now).length;
  }

  /// Builds a review session of up to [size] words.
  List<GameWord> buildSession(String userId, {int size = 10}) {
    final Map<String, Map<String, dynamic>> store = _load(userId);
    final int now = DateTime.now().millisecondsSinceEpoch;

    final List<GameWord> due = _pool
        .where((GameWord w) => store.containsKey(w.italian) && (store[w.italian]!['due'] as num) <= now)
        .toList()
      ..sort((GameWord a, GameWord b) {
        final int ba = store[a.italian]!['box'] as int;
        final int bb = store[b.italian]!['box'] as int;
        return ba != bb ? ba.compareTo(bb) : 0;
      });

    final List<GameWord> session = <GameWord>[...due];
    final List<GameWord> fresh = _pool.where((GameWord w) => !store.containsKey(w.italian)).toList()
      ..shuffle();
    for (final GameWord w in fresh) {
      if (session.length >= size) break;
      session.add(w);
    }
    // If everything has been seen and nothing is due yet, top up with the
    // soonest-due words so a session is never empty.
    if (session.length < size) {
      final List<GameWord> rest = _pool.where((GameWord w) => !session.contains(w)).toList()
        ..sort((GameWord a, GameWord b) => ((store[a.italian]?['due'] as num?) ?? 0)
            .compareTo((store[b.italian]?['due'] as num?) ?? 0));
      for (final GameWord w in rest) {
        if (session.length >= size) break;
        session.add(w);
      }
    }
    session.shuffle();
    return session.take(size).toList();
  }

  /// 4 shuffled Italian options for [target] (the answer + 3 distractors).
  List<String> buildOptions(GameWord target) {
    final List<GameWord> others = _pool.where((GameWord w) => w.italian != target.italian).toList()
      ..shuffle();
    final List<String> options = <String>[
      target.italian,
      ...others.take(3).map((GameWord w) => w.italian),
    ]..shuffle(Random());
    return options;
  }

  /// Records the result for [italian] and reschedules it.
  Future<void> recordResult(String userId, String italian, bool correct) async {
    final Map<String, Map<String, dynamic>> store = _load(userId);
    int box = (store[italian]?['box'] as int?) ?? 0;
    box = correct ? (box + 1).clamp(0, 5) : 0;
    final int due = DateTime.now().add(Duration(hours: _intervalHours[box])).millisecondsSinceEpoch;
    store[italian] = <String, dynamic>{'box': box, 'due': due};
    await _prefs.setString(_key(userId), jsonEncode(store));
  }
}
