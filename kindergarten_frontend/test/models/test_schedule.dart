import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/models/schedule.dart';

void main() {
  group('Schedule Model Tests', () {
    late Schedule testSchedule;
    late Map<String, dynamic> testScheduleMap;
    late DateTime testStartTime;
    late DateTime testEndTime;

    setUp(() {
      testStartTime = DateTime(2024, 1, 15, 9, 0);
      testEndTime = DateTime(2024, 1, 15, 10, 30);

      testSchedule = Schedule(
        id: 1,
        className: 'Rainbow Class',
        subject: 'Circle Time',
        startTime: testStartTime,
        endTime: testEndTime,
        dayOfWeek: 'Monday',
        teacherId: 1,
        room: 'Room A',
        description: 'Morning circle time with songs and stories',
        isActive: true,
      );

      testScheduleMap = {
        'id': 1,
        'className': 'Rainbow Class',
        'subject': 'Circle Time',
        'startTime': testStartTime.millisecondsSinceEpoch,
        'endTime': testEndTime.millisecondsSinceEpoch,
        'dayOfWeek': 'Monday',
        'teacherId': 1,
        'room': 'Room A',
        'description': 'Morning circle time with songs and stories',
        'isActive': 1,
      };
    });

    test('should create a Schedule instance with all properties', () {
      expect(testSchedule.id, equals(1));
      expect(testSchedule.className, equals('Rainbow Class'));
      expect(testSchedule.subject, equals('Circle Time'));
      expect(testSchedule.startTime, equals(testStartTime));
      expect(testSchedule.endTime, equals(testEndTime));
      expect(testSchedule.dayOfWeek, equals('Monday'));
      expect(testSchedule.teacherId, equals(1));
      expect(testSchedule.room, equals('Room A'));
      expect(testSchedule.description, equals('Morning circle time with songs and stories'));
      expect(testSchedule.isActive, isTrue);
    });

    test('should return correct time range', () {
      expect(testSchedule.timeRange, equals('09:00 - 10:30'));
      
      // Test with different times
      final afternoonSchedule = testSchedule.copyWith(
        startTime: DateTime(2024, 1, 15, 14, 15),
        endTime: DateTime(2024, 1, 15, 15, 45),
      );
      expect(afternoonSchedule.timeRange, equals('14:15 - 15:45'));
    });

    test('should handle single digit hours and minutes in time range', () {
      final earlySchedule = testSchedule.copyWith(
        startTime: DateTime(2024, 1, 15, 8, 5),
        endTime: DateTime(2024, 1, 15, 9, 0),
      );
      expect(earlySchedule.timeRange, equals('08:05 - 09:00'));
    });

    test('should convert to map correctly', () {
      final map = testSchedule.toMap();
      expect(map['id'], equals(1));
      expect(map['className'], equals('Rainbow Class'));
      expect(map['subject'], equals('Circle Time'));
      expect(map['dayOfWeek'], equals('Monday'));
      expect(map['teacherId'], equals(1));
      expect(map['isActive'], equals(1));
      expect(map['startTime'], equals(testStartTime.millisecondsSinceEpoch));
      expect(map['endTime'], equals(testEndTime.millisecondsSinceEpoch));
    });

    test('should create Schedule from map correctly', () {
      final schedule = Schedule.fromMap(testScheduleMap);
      expect(schedule.id, equals(1));
      expect(schedule.className, equals('Rainbow Class'));
      expect(schedule.subject, equals('Circle Time'));
      expect(schedule.startTime, equals(testStartTime));
      expect(schedule.endTime, equals(testEndTime));
      expect(schedule.dayOfWeek, equals('Monday'));
      expect(schedule.teacherId, equals(1));
      expect(schedule.timeRange, equals('09:00 - 10:30'));
      expect(schedule.isActive, isTrue);
    });

    test('should handle null optional fields correctly', () {
      final minimalMap = {
        'className': 'Test Class',
        'subject': 'Test Subject',
        'startTime': testStartTime.millisecondsSinceEpoch,
        'endTime': testEndTime.millisecondsSinceEpoch,
        'dayOfWeek': 'Tuesday',
        'teacherId': 1,
        'isActive': 1,
      };

      final schedule = Schedule.fromMap(minimalMap);
      expect(schedule.room, isNull);
      expect(schedule.description, isNull);
      expect(schedule.className, equals('Test Class'));
      expect(schedule.subject, equals('Test Subject'));
    });

    test('should copy with new values correctly', () {
      final updatedSchedule = testSchedule.copyWith(
        subject: 'Math Time',
        room: 'Room B',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
      );

      expect(updatedSchedule.subject, equals('Math Time'));
      expect(updatedSchedule.room, equals('Room B'));
      expect(updatedSchedule.timeRange, equals('10:00 - 11:00'));
      
      // Original values should remain for unchanged fields
      expect(updatedSchedule.id, equals(testSchedule.id));
      expect(updatedSchedule.className, equals(testSchedule.className));
      expect(updatedSchedule.dayOfWeek, equals(testSchedule.dayOfWeek));
      expect(updatedSchedule.teacherId, equals(testSchedule.teacherId));
    });

    test('should handle inactive schedule correctly', () {
      final inactiveSchedule = testSchedule.copyWith(isActive: false);
      expect(inactiveSchedule.isActive, isFalse);
      
      final map = inactiveSchedule.toMap();
      expect(map['isActive'], equals(0));
    });

    test('should handle different days of week', () {
      final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      
      for (final day in daysOfWeek) {
        final daySchedule = testSchedule.copyWith(dayOfWeek: day);
        expect(daySchedule.dayOfWeek, equals(day));
        
        final map = daySchedule.toMap();
        expect(map['dayOfWeek'], equals(day));
      }
    });

    test('should handle minimum required fields only', () {
      final minimalSchedule = Schedule(
        className: 'Test Class',
        subject: 'Test Subject',
        startTime: testStartTime,
        endTime: testEndTime,
        dayOfWeek: 'Monday',
        teacherId: 1,
      );

      expect(minimalSchedule.className, equals('Test Class'));
      expect(minimalSchedule.subject, equals('Test Subject'));
      expect(minimalSchedule.dayOfWeek, equals('Monday'));
      expect(minimalSchedule.teacherId, equals(1));
      expect(minimalSchedule.isActive, isTrue); // Default value
      expect(minimalSchedule.id, isNull);
      expect(minimalSchedule.room, isNull);
      expect(minimalSchedule.description, isNull);
    });

    test('should handle cross-day schedules', () {
      final lateSchedule = Schedule(
        className: 'Test Class',
        subject: 'Evening Activity',
        startTime: DateTime(2024, 1, 15, 23, 30),
        endTime: DateTime(2024, 1, 16, 0, 30),
        dayOfWeek: 'Monday',
        teacherId: 1,
      );

      expect(lateSchedule.timeRange, equals('23:30 - 00:30'));
    });
  });
}
