// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ict602_carrymark/main.dart';

void main() {
  testWidgets('Login page loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Check for Login title and create account hint
    expect(find.text('Login'), findsWidgets);
    expect(find.textContaining('Create an account'), findsOneWidget);

    // Check username and password fields are present
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
