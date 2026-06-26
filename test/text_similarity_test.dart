import 'package:ciao_kids/core/utils/text_similarity.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the pronunciation similarity scorer.
void main() {
  test('identical words score 100', () {
    expect(TextSimilarity.score('gelato', 'gelato'), 100);
  });

  test('scoring ignores case and accents', () {
    expect(TextSimilarity.score('CITTÀ', 'citta'), 100);
    expect(TextSimilarity.score('Però', 'pero'), 100);
  });

  test('a close miss scores high but below 100', () {
    final int s = TextSimilarity.score('gelatto', 'gelato');
    expect(s, greaterThan(70));
    expect(s, lessThan(100));
  });

  test('unrelated words score low', () {
    expect(TextSimilarity.score('gatto', 'cane'), lessThan(60));
  });

  test('empty against non-empty scores 0', () {
    expect(TextSimilarity.score('', 'ciao'), 0);
  });
}
