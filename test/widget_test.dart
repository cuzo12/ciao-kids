import 'package:ciao_kids/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests for shared UI primitives.
///
/// Deliberately scoped to a single themeless widget so the suite is fast and
/// has no dependency on network font loading or the DI container.
void main() {
  testWidgets('PrimaryButton renders its label and reports taps',
      (WidgetTester tester) async {
    int taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Sign In',
            onPressed: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('Sign In'), findsOneWidget);

    await tester.tap(find.byType(PrimaryButton));
    expect(taps, 1);
  });

  testWidgets('PrimaryButton hides its label and ignores taps while loading',
      (WidgetTester tester) async {
    int taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Sign In',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('Sign In'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(PrimaryButton));
    expect(taps, 0);
  });
}
