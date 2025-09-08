import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kindergarten_frontend/screens/dashboard_screen.dart';
import 'package:kindergarten_frontend/providers/student_provider.dart';
import 'package:kindergarten_frontend/providers/staff_provider.dart';
import 'package:kindergarten_frontend/providers/attendance_provider.dart';
import 'package:kindergarten_frontend/providers/schedule_provider.dart';
import 'package:kindergarten_frontend/providers/message_provider.dart';
import 'package:kindergarten_frontend/providers/notification_provider.dart';
import 'package:kindergarten_frontend/models/student.dart';
import 'package:kindergarten_frontend/models/staff.dart';
import 'package:kindergarten_frontend/models/attendance.dart';

import 'test_dashboard_screen.mocks.dart';

@GenerateMocks([
  StudentProvider,
  StaffProvider,
  AttendanceProvider,
  ScheduleProvider,
  MessageProvider,
  NotificationProvider,
])
void main() {
  group('DashboardScreen Tests', () {
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

      // Setup default behavior
      when(mockStudentProvider.students).thenReturn([]);
      when(mockStudentProvider.isLoading).thenReturn(false);
      when(mockStudentProvider.error).thenReturn(null);
      when(mockStudentProvider.loadStudents()).thenAnswer((_) async {});

      when(mockStaffProvider.staff).thenReturn([]);
      when(mockStaffProvider.isLoading).thenReturn(false);
      when(mockStaffProvider.error).thenReturn(null);
      when(mockStaffProvider.loadStaff()).thenAnswer((_) async {});

      when(mockAttendanceProvider.attendance).thenReturn([]);
      when(mockAttendanceProvider.isLoading).thenReturn(false);
      when(mockAttendanceProvider.error).thenReturn(null);
      when(mockAttendanceProvider.loadAttendance(date: anyNamed('date')))
          .thenAnswer((_) async {});
      when(mockAttendanceProvider.getAttendanceStats(any))
          .thenReturn({for (var status in AttendanceStatus.values) status: 0});

      when(mockScheduleProvider.schedules).thenReturn([]);
      when(mockScheduleProvider.isLoading).thenReturn(false);
      when(mockScheduleProvider.error).thenReturn(null);
      when(mockScheduleProvider.loadSchedules()).thenAnswer((_) async {});

      when(mockMessageProvider.messages).thenReturn([]);
      when(mockMessageProvider.isLoading).thenReturn(false);
      when(mockMessageProvider.error).thenReturn(null);
      when(mockMessageProvider.unreadCount).thenReturn(0);
      when(mockMessageProvider.loadMessages()).thenAnswer((_) async {});

      when(mockNotificationProvider.notifications).thenReturn([]);
      when(mockNotificationProvider.isLoading).thenReturn(false);
      when(mockNotificationProvider.error).thenReturn(null);
      when(mockNotificationProvider.loadNotifications()).thenAnswer((_) async {});
    });

    Widget buildDashboardScreen() {
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
          child: const DashboardScreen(),
        ),
      );
    }

    testWidgets('should display app bar with title and refresh button', (WidgetTester tester) async {
      await tester.pumpWidget(buildDashboardScreen());
      await tester.pump();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should display welcome message and current date', (WidgetTester tester) async {
      await tester.pumpWidget(buildDashboardScreen());
      await tester.pump();

      expect(find.text('Welcome back!'), findsOneWidget);
      expect(find.textContaining(DateTime.now().year.toString()), findsOneWidget);
    });

    testWidgets('should display dashboard cards with correct data', (WidgetTester tester) async {
      // Setup test data
      when(mockStudentProvider.students).thenReturn([
        Student(
          id: 1,
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: DateTime(2019, 1, 1),
          classId: 'A',
          enrollmentDate: DateTime(2024, 1, 1),
        ),
      ]);
      when(mockStaffProvider.staff).thenReturn([
        Staff(
          id: 1,
          firstName: 'Jane',
          lastName: 'Teacher',
          email: 'jane@test.com',
          phone: '123',
          role: StaffRole.teacher,
          hireDate: DateTime(2024, 1, 1),
        ),
      ]);
      when(mockAttendanceProvider.getAttendanceStats(any)).thenReturn({
        AttendanceStatus.present: 5,
        AttendanceStatus.absent: 1,
        AttendanceStatus.late: 0,
        AttendanceStatus.excused: 0,
      });
      when(mockMessageProvider.unreadCount).thenReturn(3);

      await tester.pumpWidget(buildDashboardScreen());
      await tester.pump();

      expect(find.text('Total Students'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Staff Members'), findsOneWidget);
      expect(find.text('Present Today'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Unread Messages'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should display quick action cards', (WidgetTester tester) async {
      await tester.pumpWidget(buildDashboardScreen());
      await tester.pump();

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Take Attendance'), findsOneWidget);
      expect(find.text('Add Student'), findsOneWidget);
      expect(find.text('View Schedule'), findsOneWidget);
      expect(find.text('Send Message'), findsOneWidget);
      expect(find.text('Add Staff'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('should refresh data when refresh button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(buildDashboardScreen());
      await tester.pump();

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Verify all providers were called to refresh data
      verify(mockStudentProvider.loadStudents()).called(2); // Once on init, once on refresh
      verify(mockStaffProvider.loadStaff()).called(2);
      verify(mockAttendanceProvider.loadAttendance(date: anyNamed('date'))).called(2);
      verify(mockScheduleProvider.loadSchedules()).called(2);
      verify(mockMessageProvider.loadMessages()).called(2);
      verify(mockNotificationProvider.loadNotifications()).called(2);
    });

    testWidgets('should show recent activity section', (WidgetTester tester) async {
      await tester.pumpWidget(buildDashboardScreen());
      await tester.pump();

      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('should handle pull to refresh', (WidgetTester tester) async {
      await tester.pumpWidget(buildDashboardScreen());
      await tester.pump();

      // Perform pull to refresh
      await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify refresh was triggered
      verify(mockStudentProvider.loadStudents()).called(2);
      verify(mockStaffProvider.loadStaff()).called(2);
    });

    testWidgets('should handle loading state', (WidgetTester tester) async {
      when(mockStudentProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(buildDashboardScreen());
      await tester.pump();

      // Should still render the dashboard even with loading state
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('should handle error state gracefully', (WidgetTester tester) async {
      when(mockStudentProvider.error).thenReturn('Failed to load students');

      await tester.pumpWidget(buildDashboardScreen());
      await tester.pump();

      // Dashboard should still be functional even with errors
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome back!'), findsOneWidget);
    });
  });
}
