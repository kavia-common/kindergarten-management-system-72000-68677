import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const KindergartenApp());

    expect(find.text('Kindergarten Management'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Splash screen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const KindergartenApp());

    expect(find.text('Loading...'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
  });
}
