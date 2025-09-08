import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/widgets/dashboard_card.dart';

void main() {
  group('DashboardCard Widget Tests', () {
    testWidgets('should display all properties correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardCard(
              title: 'Total Students',
              value: '25',
              icon: Icons.people,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Total Students'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('should apply correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardCard(
              title: 'Test Title',
              value: '100',
              icon: Icons.star,
              color: Colors.red,
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(iconWidget.color, equals(Colors.red));
      expect(iconWidget.size, equals(32));

      // Check if the card is rendered
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle different data types', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DashboardCard(
                  title: 'Zero Value',
                  value: '0',
                  icon: Icons.info,
                  color: Colors.grey,
                ),
                DashboardCard(
                  title: 'Large Number',
                  value: '9999',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Zero Value'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Large Number'), findsOneWidget);
      expect(find.text('9999'), findsOneWidget);
    });

    testWidgets('should handle long titles gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardCard(
              title: 'This is a very long title that might wrap',
              value: '42',
              icon: Icons.description,
              color: Colors.purple,
            ),
          ),
        ),
      );

      expect(find.text('This is a very long title that might wrap'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardCard(
              title: 'Students',
              value: '30',
              icon: Icons.school,
              color: Colors.blue,
            ),
          ),
        ),
      );

      // Verify semantics are present for accessibility
      expect(find.text('Students'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      
      // Test that the widget is found by semantics
      expect(tester.getSemantics(find.byType(DashboardCard)), isNotNull);
    });
  });
}
