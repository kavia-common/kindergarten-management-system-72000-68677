import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/widgets/recent_activity_card.dart';

void main() {
  group('RecentActivityCard Widget Tests', () {
    testWidgets('should display all properties correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentActivityCard(
              title: 'Test Message',
              subtitle: 'This is a test message content',
              time: '10:30 AM',
              icon: Icons.message,
              isUnread: false,
            ),
          ),
        ),
      );

      expect(find.text('Test Message'), findsOneWidget);
      expect(find.text('This is a test message content'), findsOneWidget);
      expect(find.text('10:30 AM'), findsOneWidget);
      expect(find.byIcon(Icons.message), findsOneWidget);
    });

    testWidgets('should handle unread state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentActivityCard(
              title: 'Unread Message',
              subtitle: 'This message is unread',
              time: '11:45 AM',
              icon: Icons.notification_important,
              isUnread: true,
            ),
          ),
        ),
      );

      expect(find.text('Unread Message'), findsOneWidget);
      
      // Find the title text widget and check if it's bold
      final titleWidget = tester.widget<Text>(
        find.text('Unread Message'),
      );
      expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should handle read state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentActivityCard(
              title: 'Read Message',
              subtitle: 'This message is read',
              time: '09:15 AM',
              icon: Icons.check,
              isUnread: false,
            ),
          ),
        ),
      );

      expect(find.text('Read Message'), findsOneWidget);
      
      // Find the title text widget and check if it's normal weight
      final titleWidget = tester.widget<Text>(
        find.text('Read Message'),
      );
      expect(titleWidget.style?.fontWeight, equals(FontWeight.normal));
    });

    testWidgets('should display different icons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RecentActivityCard(
                  title: 'Message',
                  subtitle: 'Content',
                  time: '10:00',
                  icon: Icons.message,
                  isUnread: false,
                ),
                RecentActivityCard(
                  title: 'Notification',
                  subtitle: 'Content',
                  time: '11:00',
                  icon: Icons.notifications,
                  isUnread: false,
                ),
                RecentActivityCard(
                  title: 'Alert',
                  subtitle: 'Content',
                  time: '12:00',
                  icon: Icons.warning,
                  isUnread: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.message), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should handle long content with ellipsis', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentActivityCard(
              title: 'Very Long Title That Should Be Handled Properly',
              subtitle: 'This is a very long subtitle content that should be truncated properly with ellipsis when it exceeds the maximum number of lines allowed for display',
              time: '14:30',
              icon: Icons.info,
              isUnread: false,
            ),
          ),
        ),
      );

      expect(find.text('Very Long Title That Should Be Handled Properly'), findsOneWidget);
      // The subtitle should be found even if truncated
      expect(find.textContaining('This is a very long subtitle'), findsOneWidget);
    });

    testWidgets('should render card structure correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentActivityCard(
              title: 'Test',
              subtitle: 'Test content',
              time: '10:00',
              icon: Icons.science,
              isUnread: false,
            ),
          ),
        ),
      );

      // Check that Card and ListTile are present
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should apply correct avatar styling for unread', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              primary: Colors.blue,
            ),
          ),
          home: Scaffold(
            body: RecentActivityCard(
              title: 'Unread Item',
              subtitle: 'Content',
              time: '10:00',
              icon: Icons.star,
              isUnread: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should handle different time formats', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RecentActivityCard(
                  title: '12 Hour Format',
                  subtitle: 'Content',
                  time: '2:30 PM',
                  icon: Icons.access_time,
                  isUnread: false,
                ),
                RecentActivityCard(
                  title: '24 Hour Format',
                  subtitle: 'Content',
                  time: '14:30',
                  icon: Icons.schedule,
                  isUnread: false,
                ),
                RecentActivityCard(
                  title: 'Relative Time',
                  subtitle: 'Content',
                  time: '2 hours ago',
                  icon: Icons.history,
                  isUnread: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('2:30 PM'), findsOneWidget);
      expect(find.text('14:30'), findsOneWidget);
      expect(find.text('2 hours ago'), findsOneWidget);
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentActivityCard(
              title: 'Accessible Title',
              subtitle: 'Accessible content',
              time: '10:00',
              icon: Icons.accessibility,
              isUnread: false,
            ),
          ),
        ),
      );

      // Test that the widget is found by semantics
      expect(tester.getSemantics(find.byType(RecentActivityCard)), isNotNull);
      expect(find.text('Accessible Title'), findsOneWidget);
      expect(find.text('Accessible content'), findsOneWidget);
    });
  });
}
