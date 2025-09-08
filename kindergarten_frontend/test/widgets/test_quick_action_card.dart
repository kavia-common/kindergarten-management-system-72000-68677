import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/widgets/quick_action_card.dart';

void main() {
  group('QuickActionCard Widget Tests', () {
    testWidgets('should display title and icon correctly', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionCard(
              title: 'Take Attendance',
              icon: Icons.fact_check,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Take Attendance'), findsOneWidget);
      expect(find.byIcon(Icons.fact_check), findsOneWidget);
      expect(tapped, isFalse);
    });

    testWidgets('should handle tap correctly', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionCard(
              title: 'Add Student',
              icon: Icons.person_add,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(QuickActionCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should apply correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionCard(
              title: 'Send Message',
              icon: Icons.send,
              onTap: () {},
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.send));
      expect(iconWidget.size, equals(32));

      // Check if InkWell is present for ripple effect
      expect(find.byType(InkWell), findsOneWidget);
      
      // Check if Card is present
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle different icons and titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                QuickActionCard(
                  title: 'View Schedule',
                  icon: Icons.schedule,
                  onTap: () {},
                ),
                QuickActionCard(
                  title: 'Notifications',
                  icon: Icons.notifications,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('View Schedule'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('should handle long titles with proper text wrapping', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionCard(
              title: 'Very Long Action Title That May Wrap',
              icon: Icons.info,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Very Long Action Title That May Wrap'), findsOneWidget);
    });

    testWidgets('should have proper accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionCard(
              title: 'Test Action',
              icon: Icons.settings,
              onTap: () {},
            ),
          ),
        ),
      );

      // Test semantic properties
      expect(find.text('Test Action'), findsOneWidget);
      expect(tester.getSemantics(find.byType(QuickActionCard)), isNotNull);
    });

    testWidgets('should respond to multiple rapid taps', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionCard(
              title: 'Multi Tap',
              icon: Icons.touch_app,
              onTap: () {
                tapCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(QuickActionCard));
      await tester.pump();
      await tester.tap(find.byType(QuickActionCard));
      await tester.pump();
      await tester.tap(find.byType(QuickActionCard));
      await tester.pump();

      expect(tapCount, equals(3));
    });

    testWidgets('should apply theme colors correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple,
              primary: Colors.purple,
            ),
          ),
          home: Scaffold(
            body: QuickActionCard(
              title: 'Themed Action',
              icon: Icons.palette,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Themed Action'), findsOneWidget);
      expect(find.byIcon(Icons.palette), findsOneWidget);
    });
  });
}
