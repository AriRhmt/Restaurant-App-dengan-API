import 'package:flutter/material.dart';
import 'package:flutter_submission_app/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads and shows Home tab', (tester) async {
    await tester.pumpWidget(const app.AppRoot());
    await tester.pumpAndSettle();
    expect(find.text('Restaurants'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches to Settings', (tester) async {
    await tester.pumpWidget(const app.AppRoot());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });
}