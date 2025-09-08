import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/models/attendance.dart';

void main() {
  group('Attendance Model Tests', () {
    late Attendance testAttendance;
    late Map<String, dynamic> testAttendanceMap;
    late DateTime testDate;
    late DateTime testCheckInTime;
    late DateTime testCheckOutTime;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 8, 0);
      testCheckInTime = DateTime(2024, 1, 15, 8, 30);
      testCheckOutTime = DateTime(2024, 1, 15, 15, 30);

      testAttendance = Attendance(
        id: 1,
        studentId: 1,
        date: testDate,
        status: AttendanceStatus.present,
        checkInTime: testCheckInTime,
        checkOutTime: testCheckOutTime,
        notes: 'On time',
        recordedBy: 1,
      );

      testAttendanceMap = {
        'id': 1,
        'studentId': 1,
        'date': testDate.millisecondsSinceEpoch,
        'status': 'present',
        'checkInTime': testCheckInTime.millisecondsSinceEpoch,
        'checkOutTime': testCheckOutTime.millisecondsSinceEpoch,
        'notes': 'On time',
        'recordedBy': 1,
      };
    });

    test('should create an Attendance instance with all properties', () {
      expect(testAttendance.id, equals(1));
      expect(testAttendance.studentId, equals(1));
      expect(testAttendance.date, equals(testDate));
      expect(testAttendance.status, equals(AttendanceStatus.present));
      expect(testAttendance.checkInTime, equals(testCheckInTime));
      expect(testAttendance.checkOutTime, equals(testCheckOutTime));
      expect(testAttendance.notes, equals('On time'));
      expect(testAttendance.recordedBy, equals(1));
    });

    test('should return correct status display name', () {
      expect(testAttendance.statusDisplayName, equals('PRESENT'));
      
      final absentAttendance = testAttendance.copyWith(status: AttendanceStatus.absent);
      expect(absentAttendance.statusDisplayName, equals('ABSENT'));
      
      final lateAttendance = testAttendance.copyWith(status: AttendanceStatus.late);
      expect(lateAttendance.statusDisplayName, equals('LATE'));
      
      final excusedAttendance = testAttendance.copyWith(status: AttendanceStatus.excused);
      expect(excusedAttendance.statusDisplayName, equals('EXCUSED'));
    });

    test('should convert to map correctly', () {
      final map = testAttendance.toMap();
      expect(map['id'], equals(1));
      expect(map['studentId'], equals(1));
      expect(map['status'], equals('present'));
      expect(map['date'], equals(testDate.millisecondsSinceEpoch));
      expect(map['checkInTime'], equals(testCheckInTime.millisecondsSinceEpoch));
      expect(map['checkOutTime'], equals(testCheckOutTime.millisecondsSinceEpoch));
    });

    test('should create Attendance from map correctly', () {
      final attendance = Attendance.fromMap(testAttendanceMap);
      expect(attendance.id, equals(1));
      expect(attendance.studentId, equals(1));
      expect(attendance.status, equals(AttendanceStatus.present));
      expect(attendance.statusDisplayName, equals('PRESENT'));
      expect(attendance.date, equals(testDate));
      expect(attendance.checkInTime, equals(testCheckInTime));
      expect(attendance.checkOutTime, equals(testCheckOutTime));
    });

    test('should handle different attendance statuses correctly', () {
      for (final status in AttendanceStatus.values) {
        final statusMap = {
          'studentId': 1,
          'date': DateTime.now().millisecondsSinceEpoch,
          'status': status.toString().split('.').last,
        };

        final attendance = Attendance.fromMap(statusMap);
        expect(attendance.status, equals(status));
        expect(attendance.statusDisplayName, equals(status.toString().split('.').last.toUpperCase()));
      }
    });

    test('should handle unknown status correctly', () {
      final unknownStatusMap = {
        'studentId': 1,
        'date': DateTime.now().millisecondsSinceEpoch,
        'status': 'unknown_status',
      };

      final attendance = Attendance.fromMap(unknownStatusMap);
      expect(attendance.status, equals(AttendanceStatus.absent));
    });

    test('should handle null optional fields correctly', () {
      final minimalMap = {
        'studentId': 1,
        'date': testDate.millisecondsSinceEpoch,
        'status': 'present',
      };

      final attendance = Attendance.fromMap(minimalMap);
      expect(attendance.checkInTime, isNull);
      expect(attendance.checkOutTime, isNull);
      expect(attendance.notes, isNull);
      expect(attendance.recordedBy, isNull);
    });

    test('should copy with new values correctly', () {
      final updatedAttendance = testAttendance.copyWith(
        status: AttendanceStatus.late,
        notes: 'Arrived 15 minutes late',
        checkInTime: DateTime(2024, 1, 15, 8, 45),
      );

      expect(updatedAttendance.status, equals(AttendanceStatus.late));
      expect(updatedAttendance.statusDisplayName, equals('LATE'));
      expect(updatedAttendance.notes, equals('Arrived 15 minutes late'));
      expect(updatedAttendance.checkInTime, equals(DateTime(2024, 1, 15, 8, 45)));
      
      // Original values should remain for unchanged fields
      expect(updatedAttendance.id, equals(testAttendance.id));
      expect(updatedAttendance.studentId, equals(testAttendance.studentId));
      expect(updatedAttendance.date, equals(testAttendance.date));
      expect(updatedAttendance.checkOutTime, equals(testAttendance.checkOutTime));
    });

    test('should handle attendance without times', () {
      final attendanceWithoutTimes = Attendance(
        studentId: 1,
        date: testDate,
        status: AttendanceStatus.absent,
      );

      expect(attendanceWithoutTimes.checkInTime, isNull);
      expect(attendanceWithoutTimes.checkOutTime, isNull);
      expect(attendanceWithoutTimes.status, equals(AttendanceStatus.absent));
    });

    test('should handle minimum required fields only', () {
      final minimalAttendance = Attendance(
        studentId: 1,
        date: testDate,
        status: AttendanceStatus.present,
      );

      expect(minimalAttendance.studentId, equals(1));
      expect(minimalAttendance.date, equals(testDate));
      expect(minimalAttendance.status, equals(AttendanceStatus.present));
      expect(minimalAttendance.id, isNull);
      expect(minimalAttendance.checkInTime, isNull);
      expect(minimalAttendance.checkOutTime, isNull);
      expect(minimalAttendance.notes, isNull);
      expect(minimalAttendance.recordedBy, isNull);
    });
  });
}
