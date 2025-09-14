// This is a basic Flutter widget test for RanSanMaker app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ran_san_maker/main.dart';

void main() {
  testWidgets('RanSanMaker app basic structure test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: RanSanMakerApp()));

    // Verify that our app loads the basic structure
    expect(find.byType(MaterialApp), findsOneWidget);

    // Pump one frame to check basic widget creation
    await tester.pump();

    // The app should have created the basic widget structure without exceptions
    // This is a minimal smoke test to ensure the app can be instantiated
  });
}
