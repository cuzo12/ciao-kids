import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/vocab/vocab_bank.dart';

/// Adaptive vocabulary engine shared by the games, pronunciation, and review.
///
/// Every word the child has practiced sits in a Leitner "box" (0 = brand new or
/// struggling, 5 = mastered). When picking words to practice, lower boxes get a
/// much higher chance of appearing — so **the more a word is missed, the more it
/// shows up, and the more it's known, the less it shows up.** State is per-user
/// and local (no backend).
class MasteryService {
  MasteryService(this._prefs);

  final SharedPreferences _prefs;
  final Random _rng = Random();

  static const int _maxBox = 5;
  // Hours until a word is "due" again, by box. Higher box = longer rest.
  static const List<int> _intervalHours = <int>[0, 12, 36, 96, 240, 600];

  String _key(String userId) => 'ciao_kids.mastery.$userId';

  Map<String, Map<String, dynamic>> _load(String userId) {
    final String? raw = _prefs.getString(_key(userId));
    if (raw == null) return <String, Map<String, dynamic>>{};
    try {
      final Map<String, dynamic> j = jsonDecode(raw) as Map<String, dynamic>;
      return j.map((String k, dynamic v) =>
          MapEntry<String, Map<String, dynamic>>(k, v as Map<String, dynamic>));
    } catch (_) {
      return <String, Map<String, dynamic>>{};
    }
  }

  double _weight(Map<String, dynamic>? entry, int now) {
    final int box = (entry?['box'] as int?) ?? 0;
    double w = (_maxBox + 1 - box).toDouble(); // box 0 → 6, box 5 → 1
    final int due = (entry?['due'] as num?)?.toInt() ?? 0;
    if (entry == null || due <= now) w *= 2; // due / never-seen words come first
    return w;
  }

  /// Draws [count] distinct words to practice, weighted toward weak/new words.
  ///
  /// Set [needEmoji] for games that show an emoji (Emoji Match).
  List<VocabWord> draw(String userId, int count, {bool needEmoji = false}) {
    final Map<String, Map<String, dynamic>> store = _load(userId);
    final int now = DateTime.now().millisecondsSinceEpoch;
    final List<VocabWord> candidates =
        List<VocabWord>.of(needEmoji ? VocabBank.withEmoji : VocabBank.all);

    final List<VocabWord> picked = <VocabWord>[];
    final int target = min(count, candidates.length);
    while (picked.length < target && candidates.isNotEmpty) {
      double total = 0;
      final List<double> weights = <double>[
        for (final VocabWord w in candidates)
          () {
            final double weight = _weight(store[w.id], now);
            total += weight;
            return weight;
          }(),
      ];
      double r = _rng.nextDouble() * total;
      int idx = 0;
      for (; idx < weights.length; idx++) {
        r -= weights[idx];
        if (r <= 0) break;
      }
      if (idx >= candidates.length) idx = candidates.length - 1;
      picked.add(candidates.removeAt(idx));
    }
    return picked;
  }

  /// Returns [n] distractor words different from [target] (for multiple choice).
  List<VocabWord> distractors(VocabWord target, int n, {bool needEmoji = false}) {
    final List<VocabWord> pool =
        List<VocabWord>.of(needEmoji ? VocabBank.withEmoji : VocabBank.all)
          ..removeWhere((VocabWord w) => w.id == target.id)
          ..shuffle(_rng);
    return pool.take(n).toList();
  }

  /// Records a practice result and reschedules the word.
  ///
  /// Correct → up a box (seen less). Wrong → down a box (seen more, sooner).
  Future<void> record(String userId, String wordId, bool correct) async {
    final Map<String, Map<String, dynamic>> store = _load(userId);
    int box = (store[wordId]?['box'] as int?) ?? 0;
    box = (correct ? box + 1 : box - 1).clamp(0, _maxBox);
    final int due = DateTime.now()
        .add(Duration(hours: _intervalHours[box]))
        .millisecondsSinceEpoch;
    store[wordId] = <String, dynamic>{'box': box, 'due': due};
    await _prefs.setString(_key(userId), jsonEncode(store));
  }

  /// How many words the child has fully mastered (box 5).
  int masteredCount(String userId) =>
      _load(userId).values.where((Map<String, dynamic> v) => (v['box'] as int) >= _maxBox).length;

  /// How many words have been practiced at all.
  int seenCount(String userId) => _load(userId).length;

  /// Total words available in the pool.
  int get poolSize => VocabBank.all.length;
}
