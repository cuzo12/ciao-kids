/// Text similarity helpers used by the pronunciation coach to compare what the
/// child said (speech transcript) with the target word.
abstract final class TextSimilarity {
  /// Best similarity (0–100) between the target [word] and anything the speech
  /// engine returned across [candidates].
  ///
  /// Speech recognizers often wrap a word in filler ("the gatto please") or
  /// offer several guesses. We score the whole transcript AND each individual
  /// word, across every candidate, and keep the best — so a correctly-spoken
  /// word still scores high even when surrounded by noise.
  static int bestScore(Iterable<String> candidates, String word) {
    int best = 0;
    for (final String candidate in candidates) {
      best = best > score(candidate, word) ? best : score(candidate, word);
      for (final String piece in candidate.split(RegExp(r'\s+'))) {
        if (piece.isEmpty) continue;
        final int s = score(piece, word);
        if (s > best) best = s;
      }
      if (best == 100) break;
    }
    return best;
  }

  /// Returns a 0–100 similarity score between [a] and [b].
  ///
  /// Both strings are normalized (lowercased, accent-stripped, letters only)
  /// then compared with the Levenshtein edit distance, scaled to a percentage
  /// of the longer string's length. 100 = identical, 0 = completely different.
  static int score(String a, String b) {
    final String na = _normalize(a);
    final String nb = _normalize(b);
    if (na.isEmpty && nb.isEmpty) return 100;
    if (na.isEmpty || nb.isEmpty) return 0;
    if (na == nb) return 100;

    final int distance = _levenshtein(na, nb);
    final int longest = na.length > nb.length ? na.length : nb.length;
    final double ratio = 1 - (distance / longest);
    final int pct = (ratio * 100).round();
    return pct.clamp(0, 100);
  }

  /// Lowercases, strips Italian accents, and keeps only letters.
  static String _normalize(String input) {
    final StringBuffer buffer = StringBuffer();
    for (final String ch in input.toLowerCase().trim().split('')) {
      buffer.write(_deaccent(ch));
    }
    return buffer.toString().replaceAll(RegExp('[^a-z]'), '');
  }

  static String _deaccent(String ch) {
    switch (ch) {
      case 'à':
      case 'á':
      case 'â':
        return 'a';
      case 'è':
      case 'é':
      case 'ê':
        return 'e';
      case 'ì':
      case 'í':
      case 'î':
        return 'i';
      case 'ò':
      case 'ó':
      case 'ô':
        return 'o';
      case 'ù':
      case 'ú':
      case 'û':
        return 'u';
      default:
        return ch;
    }
  }

  /// Classic Levenshtein edit distance between two strings.
  static int _levenshtein(String s, String t) {
    final int m = s.length;
    final int n = t.length;
    final List<int> previous = List<int>.generate(n + 1, (int i) => i);
    final List<int> current = List<int>.filled(n + 1, 0);

    for (int i = 1; i <= m; i++) {
      current[0] = i;
      for (int j = 1; j <= n; j++) {
        final int cost = s[i - 1] == t[j - 1] ? 0 : 1;
        final int deletion = previous[j] + 1;
        final int insertion = current[j - 1] + 1;
        final int substitution = previous[j - 1] + cost;
        current[j] = deletion < insertion
            ? (deletion < substitution ? deletion : substitution)
            : (insertion < substitution ? insertion : substitution);
      }
      for (int j = 0; j <= n; j++) {
        previous[j] = current[j];
      }
    }
    return previous[n];
  }
}
