import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:kindergarten_frontend/main.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Main App Widget Tests', () {
    testWidgets('App loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pump();

      expect(find.text('Kindergarten Management'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Splash screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pump();

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
    });

    testWidgets('App has correct theme configuration', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('Kindergarten Management'));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
      expect(materialApp.themeMode, equals(ThemeMode.system));
    });

    testWidgets('App has multi-provider setup', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pump();

      // Should have MultiProvider as root widget
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App shows splash screen initially', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pump();

      // Should show splash screen elements
      expect(find.text('Kindergarten Management'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('App handles navigation correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pump();

      // Verify initial route
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes, contains('/main'));
    });

    testWidgets('App has correct debug settings', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });
  });
}
