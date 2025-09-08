import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kindergarten_frontend/providers/attendance_provider.dart';
import 'package:kindergarten_frontend/models/attendance.dart';
import 'package:kindergarten_frontend/services/database_service.dart';

import 'test_attendance_provider.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  group('AttendanceProvider Tests', () {
    late AttendanceProvider attendanceProvider;
    late MockDatabaseService mockDatabaseService;
    late List<Attendance> testAttendance;
    late DateTime testDate;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      attendanceProvider = AttendanceProvider();
      testDate = DateTime(2024, 1, 15);
      
      testAttendance = [
        Attendance(
          id: 1,
          studentId: 1,
          date: testDate,
          status: AttendanceStatus.present,
          checkInTime: DateTime(2024, 1, 15, 8, 30),
        ),
        Attendance(
          id: 2,
          studentId: 2,
          date: testDate,
          status: AttendanceStatus.late,
          checkInTime: DateTime(2024, 1, 15, 9, 15),
        ),
        Attendance(
          id: 3,
          studentId: 3,
          date: testDate,
          status: AttendanceStatus.absent,
        ),
      ];
    });

    tearDown(() {
      reset(mockDatabaseService);
    });

    test('should initialize with empty attendance list', () {
      expect(attendanceProvider.attendance, isEmpty);
      expect(attendanceProvider.isLoading, isFalse);
      expect(attendanceProvider.error, isNull);
    });

    test('should load attendance successfully', () async {
      when(mockDatabaseService.getAttendance(date: anyNamed('date')))
          .thenAnswer((_) async => testAttendance);

      await attendanceProvider.loadAttendance(date: testDate);

      expect(attendanceProvider.attendance, equals(testAttendance));
      expect(attendanceProvider.isLoading, isFalse);
      expect(attendanceProvider.error, isNull);
      verify(mockDatabaseService.getAttendance(date: testDate)).called(1);
    });

    test('should load all attendance when no date specified', () async {
      when(mockDatabaseService.getAttendance(date: anyNamed('date')))
          .thenAnswer((_) async => testAttendance);

      await attendanceProvider.loadAttendance();

      expect(attendanceProvider.attendance, equals(testAttendance));
      verify(mockDatabaseService.getAttendance(date: null)).called(1);
    });

    test('should handle loading error', () async {
      const errorMessage = 'Database connection failed';
      when(mockDatabaseService.getAttendance(date: anyNamed('date')))
          .thenThrow(Exception(errorMessage));

      await attendanceProvider.loadAttendance(date: testDate);

      expect(attendanceProvider.attendance, isEmpty);
      expect(attendanceProvider.isLoading, isFalse);
      expect(attendanceProvider.error, contains(errorMessage));
    });

    test('should mark attendance successfully', () async {
      final newAttendance = Attendance(
        studentId: 4,
        date: testDate,
        status: AttendanceStatus.present,
        checkInTime: DateTime(2024, 1, 15, 8, 25),
      );

      when(mockDatabaseService.insertAttendance(any)).thenAnswer((_) async => 4);

      await attendanceProvider.markAttendance(newAttendance);

      expect(attendanceProvider.attendance.length, equals(1));
      expect(attendanceProvider.attendance.first.id, equals(4));
      expect(attendanceProvider.attendance.first.studentId, equals(4));
      expect(attendanceProvider.isLoading, isFalse);
      expect(attendanceProvider.error, isNull);
      verify(mockDatabaseService.insertAttendance(any)).called(1);
    });

    test('should update attendance successfully', () async {
      when(mockDatabaseService.getAttendance(date: anyNamed('date')))
          .thenAnswer((_) async => testAttendance);
      await attendanceProvider.loadAttendance(date: testDate);

      final updatedAttendance = testAttendance.first.copyWith(
        status: AttendanceStatus.late,
        checkInTime: DateTime(2024, 1, 15, 9, 0),
      );
      when(mockDatabaseService.updateAttendance(any)).thenAnswer((_) async => 1);

      await attendanceProvider.updateAttendance(updatedAttendance);

      expect(attendanceProvider.attendance.first.status, equals(AttendanceStatus.late));
      expect(attendanceProvider.isLoading, isFalse);
      expect(attendanceProvider.error, isNull);
      verify(mockDatabaseService.updateAttendance(any)).called(1);
    });

    test('should get attendance for specific date', () async {
      final differentDateAttendance = [
        Attendance(
          id: 4,
          studentId: 1,
          date: DateTime(2024, 1, 16),
          status: AttendanceStatus.present,
        ),
      ];

      final allAttendance = [...testAttendance, ...differentDateAttendance];
      when(mockDatabaseService.getAttendance(date: anyNamed('date')))
          .thenAnswer((_) async => allAttendance);
      await attendanceProvider.loadAttendance();

      final todayAttendance = attendanceProvider.getAttendanceForDate(testDate);
      final tomorrowAttendance = attendanceProvider.getAttendanceForDate(DateTime(2024, 1, 16));

      expect(todayAttendance.length, equals(3));
      expect(tomorrowAttendance.length, equals(1));
    });

    test('should get attendance for specific student', () async {
      when(mockDatabaseService.getAttendance(date: anyNamed('date')))
          .thenAnswer((_) async => testAttendance);
      await attendanceProvider.loadAttendance(date: testDate);

      final studentAttendance = attendanceProvider.getAttendanceForStudent(1, testDate);
      final nonExistentStudentAttendance = attendanceProvider.getAttendanceForStudent(999, testDate);

      expect(studentAttendance, isNotNull);
      expect(studentAttendance!.studentId, equals(1));
      expect(studentAttendance.status, equals(AttendanceStatus.present));
      expect(nonExistentStudentAttendance, isNull);
    });

    test('should get attendance statistics correctly', () async {
      when(mockDatabaseService.getAttendance(date: anyNamed('date')))
          .thenAnswer((_) async => testAttendance);
      await attendanceProvider.loadAttendance(date: testDate);

      final stats = attendanceProvider.getAttendanceStats(testDate);

      expect(stats[AttendanceStatus.present], equals(1));
      expect(stats[AttendanceStatus.late], equals(1));
      expect(stats[AttendanceStatus.absent], equals(1));
      expect(stats[AttendanceStatus.excused], equals(0));
    });

    test('should handle empty attendance statistics', () async {
      when(mockDatabaseService.getAttendance(date: anyNamed('date')))
          .thenAnswer((_) async => []);
      await attendanceProvider.loadAttendance(date: testDate);

      final stats = attendanceProvider.getAttendanceStats(testDate);

      for (final status in AttendanceStatus.values) {
        expect(stats[status], equals(0));
      }
    });

    test('should clear error', () async {
      const errorMessage = 'Test error';
      when(mockDatabaseService.getAttendance(date: anyNamed('date')))
          .thenThrow(Exception(errorMessage));
      await attendanceProvider.loadAttendance(date: testDate);

      expect(attendanceProvider.error, isNotNull);

      attendanceProvider.clearError();

      expect(attendanceProvider.error, isNull);
    });

    test('should notify listeners during operations', () async {
      var notificationCount = 0;
      attendanceProvider.addListener(() {
        notificationCount++;
      });

      when(mockDatabaseService.getAttendance(date: anyNamed('date')))
          .thenAnswer((_) async => testAttendance);

      await attendanceProvider.loadAttendance(date: testDate);

      expect(notificationCount, greaterThanOrEqualTo(2));
    });
  });
}
