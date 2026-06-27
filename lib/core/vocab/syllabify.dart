/// Rough Italian syllable splitter, used to show pronunciation chips for any
/// word in the pool (e.g. "spaghetti" → "spa-ghet-ti").
///
/// Italian syllabification is highly regular, so a simple heuristic gives
/// learner-friendly chunks: each syllable is built around a vowel, a single
/// consonant between vowels joins the following vowel, doubled consonants split,
/// and common digraphs (ch, gh, gn, gl, sc) and mute-r/l clusters stay together.
String syllabify(String word) {
  final String w = word.trim();
  if (w.length <= 2 || w.contains(' ')) return w;

  const String vowels = 'aeiouàèéìíòóùúAEIOUÀÈÉÌÍÒÓÙÚ';
  bool isVowel(String c) => vowels.contains(c);

  // Digraphs that must never be split.
  bool isDigraph(String a, String b) {
    final String p = '${a.toLowerCase()}${b.toLowerCase()}';
    return p == 'ch' || p == 'gh' || p == 'gn' || p == 'gl' || p == 'sc';
  }

  // Consonant clusters that can begin a syllable (so they move to the next one).
  bool isValidOnset(String a, String b) {
    final String x = a.toLowerCase();
    final String y = b.toLowerCase();
    if (y == 'r' && 'bcdfgptv'.contains(x)) return true; // br, tr, pr...
    if (y == 'l' && 'bcfgp'.contains(x)) return true; // bl, cl, fl...
    return false;
  }

  final List<String> out = <String>[];
  final StringBuffer cur = StringBuffer();

  for (int i = 0; i < w.length; i++) {
    final String c = w[i];
    cur.write(c);
    if (i == w.length - 1) break;

    final String next = w[i + 1];
    if (isVowel(c) && !isVowel(next)) {
      // Decide where the break falls after this vowel.
      final String c1 = next;
      final String? c2 = i + 2 < w.length ? w[i + 2] : null;
      final String? c3 = i + 3 < w.length ? w[i + 3] : null;

      if (c2 != null && isVowel(c2)) {
        // V - C V : single consonant starts the next syllable.
        out.add(cur.toString());
        cur.clear();
      } else if (c2 != null) {
        if (isDigraph(c1, c2) || isValidOnset(c1, c2)) {
          // V - (CC) ... : keep cluster with the next syllable.
          out.add(cur.toString());
          cur.clear();
        } else if (c3 != null) {
          // VC - C... : split between the two consonants (gat-to, por-ta).
          cur.write(c1);
          out.add(cur.toString());
          cur.clear();
          i++; // consumed c1
        }
      }
    }
  }
  if (cur.isNotEmpty) out.add(cur.toString());
  return out.where((String s) => s.isNotEmpty).join('-');
}
