import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kindergarten_frontend/screens/splash_screen.dart';
import 'package:kindergarten_frontend/providers/student_provider.dart';
import 'package:kindergarten_frontend/providers/staff_provider.dart';
import 'package:kindergarten_frontend/providers/attendance_provider.dart';
import 'package:kindergarten_frontend/providers/schedule_provider.dart';
import 'package:kindergarten_frontend/providers/message_provider.dart';
import 'package:kindergarten_frontend/providers/notification_provider.dart';

import 'test_splash_screen.mocks.dart';

@GenerateMocks([
  StudentProvider,
  StaffProvider,
  AttendanceProvider,
  ScheduleProvider,
  MessageProvider,
  NotificationProvider,
])
void main() {
  group('SplashScreen Tests', () {
    late MockStudentProvider mockStudentProvider;
    late MockStaffProvider mockStaffProvider;
    late MockAttendanceProvider mockAttendanceProvider;
    late MockScheduleProvider mockScheduleProvider;
    late MockMessageProvider mockMessageProvider;
    late MockNotificationProvider mockNotificationProvider;

    setUp(() {
      mockStudentProvider = MockStudentProvider();
      mockStaffProvider = MockStaffProvider();
      mockAttendanceProvider = MockAttendanceProvider();
      mockScheduleProvider = MockScheduleProvider();
      mockMessageProvider = MockMessageProvider();
      mockNotificationProvider = MockNotificationProvider();

      // Setup default behavior for all providers
      when(mockStudentProvider.loadStudents()).thenAnswer((_) async {});
      when(mockStaffProvider.loadStaff()).thenAnswer((_) async {});
      when(mockAttendanceProvider.loadAttendance()).thenAnswer((_) async {});
      when(mockScheduleProvider.loadSchedules()).thenAnswer((_) async {});
      when(mockMessageProvider.loadMessages()).thenAnswer((_) async {});
      when(mockNotificationProvider.loadNotifications()).thenAnswer((_) async {});
    });

    Widget buildSplashScreen() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<StudentProvider>.value(value: mockStudentProvider),
            ChangeNotifierProvider<StaffProvider>.value(value: mockStaffProvider),
            ChangeNotifierProvider<AttendanceProvider>.value(value: mockAttendanceProvider),
            ChangeNotifierProvider<ScheduleProvider>.value(value: mockScheduleProvider),
            ChangeNotifierProvider<MessageProvider>.value(value: mockMessageProvider),
            ChangeNotifierProvider<NotificationProvider>.value(value: mockNotificationProvider),
          ],
          child: const SplashScreen(),
        ),
        routes: {
          '/main': (context) => const Scaffold(body: Text('Main Screen')),
        },
      );
    }

    testWidgets('should display app logo and title', (WidgetTester tester) async {
      await tester.pumpWidget(buildSplashScreen());
      await tester.pump();

      expect(find.byIcon(Icons.school), findsOneWidget);
      expect(find.text('Kindergarten Management'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should display loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(buildSplashScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(buildSplashScreen());
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });

    testWidgets('should load all provider data on initialization', (WidgetTester tester) async {
      await tester.pumpWidget(buildSplashScreen());
      await tester.pump();

      // Allow async operations to complete
      await tester.pump(const Duration(milliseconds: 100));

      // Verify all providers were called to load data
      verify(mockStudentProvider.loadStudents()).called(1);
      verify(mockStaffProvider.loadStaff()).called(1);
      verify(mockAttendanceProvider.loadAttendance()).called(1);
      verify(mockScheduleProvider.loadSchedules()).called(1);
      verify(mockMessageProvider.loadMessages()).called(1);
      verify(mockNotificationProvider.loadNotifications()).called(1);
    });

    testWidgets('should navigate to main screen after loading', (WidgetTester tester) async {
      await tester.pumpWidget(buildSplashScreen());
      await tester.pump();

      // Fast forward through the loading delay
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should navigate to main screen
      expect(find.text('Main Screen'), findsOneWidget);
    });

    testWidgets('should handle provider loading errors gracefully', (WidgetTester tester) async {
      // Make one provider throw an error
      when(mockStudentProvider.loadStudents()).thenThrow(Exception('Load failed'));

      await tester.pumpWidget(buildSplashScreen());
      await tester.pump();

      // Should still show splash screen elements
      expect(find.text('Kindergarten Management'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Should continue with other providers despite error
      await tester.pump(const Duration(milliseconds: 100));
      verify(mockStaffProvider.loadStaff()).called(1);
      verify(mockAttendanceProvider.loadAttendance()).called(1);
    });

    testWidgets('should display elements in correct layout', (WidgetTester tester) async {
      await tester.pumpWidget(buildSplashScreen());
      await tester.pump();

      // Check that all elements are present
      expect(find.byIcon(Icons.school), findsOneWidget);
      expect(find.text('Kindergarten Management'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Check layout structure
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should handle fast loading completion', (WidgetTester tester) async {
      // Make all providers complete immediately
      when(mockStudentProvider.loadStudents()).thenAnswer((_) async {});
      when(mockStaffProvider.loadStaff()).thenAnswer((_) async {});

      await tester.pumpWidget(buildSplashScreen());
      await tester.pump();

      // Verify splash screen is displayed first
      expect(find.text('Kindergarten Management'), findsOneWidget);

      // Fast forward past the minimum display time
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should have navigated
      expect(find.text('Main Screen'), findsOneWidget);
    });

    testWidgets('should maintain splash screen for minimum duration', (WidgetTester tester) async {
      await tester.pumpWidget(buildSplashScreen());
      await tester.pump();

      // Even if providers load quickly, splash should stay for minimum time
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Kindergarten Management'), findsOneWidget);
      expect(find.text('Main Screen'), findsNothing);

      // After full duration, should navigate
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Main Screen'), findsOneWidget);
    });
  });
}
