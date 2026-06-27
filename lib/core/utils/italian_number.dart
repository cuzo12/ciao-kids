/// Spells an integer 0–100 in Italian (e.g. 47 → "quarantasette").
///
/// Lets the numbers game generate endless questions without a hand-written list.
/// Handles the usual elisions: the tens word drops its final vowel before "uno"
/// and "otto" (ventuno, ventotto), and "tre" takes an accent when compounded
/// (ventitré).
String italianNumber(int n) {
  const List<String> ones = <String>[
    'zero', 'uno', 'due', 'tre', 'quattro', 'cinque', 'sei', 'sette', 'otto',
    'nove', 'dieci', 'undici', 'dodici', 'tredici', 'quattordici', 'quindici',
    'sedici', 'diciassette', 'diciotto', 'diciannove',
  ];
  const List<String> tens = <String>[
    '', '', 'venti', 'trenta', 'quaranta', 'cinquanta', 'sessanta', 'settanta',
    'ottanta', 'novanta',
  ];

  if (n < 0 || n > 100) return '$n';
  if (n < 20) return ones[n];
  if (n == 100) return 'cento';

  final int t = n ~/ 10;
  final int u = n % 10;
  String base = tens[t];
  if (u == 0) return base;
  if (u == 1 || u == 8) base = base.substring(0, base.length - 1); // drop final vowel
  final String unit = u == 3 ? 'tré' : ones[u];
  return '$base$unit';
}
