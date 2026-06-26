import 'package:ciao_kids/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the pure-function form [Validators].
///
/// These run without a widget tree and guard the input rules that protect the
/// auth flows (valid email, password length, supported age range).
void main() {
  group('Validators.email', () {
    test('rejects empty and malformed addresses', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('missing@domain'), isNotNull);
    });

    test('accepts a well-formed address', () {
      expect(Validators.email('parent@email.com'), isNull);
      expect(Validators.email('  family.name+tag@school.it '), isNull);
    });
  });

  group('Validators.password', () {
    test('enforces the minimum length', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('secret1'), isNull);
    });
  });

  group('Validators.childAge', () {
    test('rejects non-numbers and out-of-range ages', () {
      expect(Validators.childAge('abc'), isNotNull);
      expect(Validators.childAge('4'), isNotNull);
      expect(Validators.childAge('16'), isNotNull);
    });

    test('accepts ages within 5–15', () {
      expect(Validators.childAge('5'), isNull);
      expect(Validators.childAge('10'), isNull);
      expect(Validators.childAge('15'), isNull);
    });
  });

  group('Validators.name', () {
    test('rejects empty and too-short names', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name('A'), isNotNull);
    });

    test('accepts a normal name', () {
      expect(Validators.name('Sofia'), isNull);
    });
  });
}
