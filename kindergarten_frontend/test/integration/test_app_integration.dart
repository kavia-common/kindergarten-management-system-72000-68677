import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kindergarten_frontend/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('should load app and navigate through main screens', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pumpAndSettle();

      // Should start with splash screen
      expect(find.text('Kindergarten Management'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should navigate to main navigation
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should navigate between bottom navigation tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Test navigation to Students screen
      await tester.tap(find.text('Students'));
      await tester.pumpAndSettle();
      expect(find.text('Students'), findsOneWidget);

      // Test navigation to Staff screen
      await tester.tap(find.text('Staff'));
      await tester.pumpAndSettle();
      expect(find.text('Staff'), findsOneWidget);

      // Test navigation back to Dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('should handle refresh on dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should be on dashboard
      expect(find.text('Dashboard'), findsOneWidget);

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Dashboard should still be visible
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('should display quick action cards and handle taps', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should see quick action cards
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Take Attendance'), findsOneWidget);
      expect(find.text('Add Student'), findsOneWidget);

      // Test tapping on Add Student action
      await tester.tap(find.text('Add Student'));
      await tester.pumpAndSettle();

      // Should navigate to Students tab
      expect(find.text('Students'), findsOneWidget);
    });

    testWidgets('should show floating action buttons on appropriate screens', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to Students screen
      await tester.tap(find.text('Students'));
      await tester.pumpAndSettle();

      // Should have FAB for adding students
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Navigate to Staff screen
      await tester.tap(find.text('Staff'));
      await tester.pumpAndSettle();

      // Should have FAB for adding staff
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should handle search functionality on screens', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to Students screen
      await tester.tap(find.text('Students'));
      await tester.pumpAndSettle();

      // Should have search field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search students...'), findsOneWidget);

      // Test entering search text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Navigate to Staff screen
      await tester.tap(find.text('Staff'));
      await tester.pumpAndSettle();

      // Should have search field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search staff...'), findsOneWidget);
    });

    testWidgets('should display attendance screen correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to Attendance screen
      await tester.tap(find.text('Attendance'));
      await tester.pumpAndSettle();

      // Should show attendance screen elements
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsAtLeastNWidgets(1));
    });

    testWidgets('should display messages screen correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to Messages screen
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();

      // Should show messages screen elements
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('All Messages'), findsOneWidget);
      expect(find.text('Unread'), findsOneWidget);
    });

    testWidgets('should handle app theme correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should have material app with theme
      expect(find.byType(MaterialApp), findsOneWidget);

      // Check that theme colors are applied
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
    });

    testWidgets('should handle notification badges correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const KindergartenApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should show bottom navigation with message and notification icons
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Check for navigation items
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.items.length, equals(7));
    });
  });
}
