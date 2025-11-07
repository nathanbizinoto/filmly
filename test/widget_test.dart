import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:filmly/main.dart';

void main() {
  testWidgets('Filmly app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FilmlyApp());

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}