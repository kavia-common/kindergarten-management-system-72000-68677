import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kindergarten_frontend/providers/schedule_provider.dart';
import 'package:kindergarten_frontend/models/schedule.dart';
import 'package:kindergarten_frontend/services/database_service.dart';

import 'test_schedule_provider.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  group('ScheduleProvider Tests', () {
    late ScheduleProvider scheduleProvider;
    late MockDatabaseService mockDatabaseService;
    late List<Schedule> testSchedules;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      scheduleProvider = ScheduleProvider();
      
      testSchedules = [
        Schedule(
          id: 1,
          className: 'Rainbow Class',
          subject: 'Circle Time',
          startTime: DateTime(2024, 1, 15, 9, 0),
          endTime: DateTime(2024, 1, 15, 9, 30),
          dayOfWeek: 'Monday',
          teacherId: 1,
          room: 'Room A',
        ),
        Schedule(
          id: 2,
          className: 'Sunshine Class',
          subject: 'Math Time',
          startTime: DateTime(2024, 1, 15, 10, 0),
          endTime: DateTime(2024, 1, 15, 10, 45),
          dayOfWeek: 'Monday',
          teacherId: 2,
          room: 'Room B',
        ),
        Schedule(
          id: 3,
          className: 'Rainbow Class',
          subject: 'Art Class',
          startTime: DateTime(2024, 1, 16, 14, 0),
          endTime: DateTime(2024, 1, 16, 15, 0),
          dayOfWeek: 'Tuesday',
          teacherId: 1,
          room: 'Art Room',
        ),
      ];
    });

    tearDown(() {
      reset(mockDatabaseService);
    });

    test('should initialize with empty schedules list', () {
      expect(scheduleProvider.schedules, isEmpty);
      expect(scheduleProvider.isLoading, isFalse);
      expect(scheduleProvider.error, isNull);
    });

    test('should load schedules successfully', () async {
      when(mockDatabaseService.getSchedules()).thenAnswer((_) async => testSchedules);

      await scheduleProvider.loadSchedules();

      expect(scheduleProvider.schedules, equals(testSchedules));
      expect(scheduleProvider.isLoading, isFalse);
      expect(scheduleProvider.error, isNull);
      verify(mockDatabaseService.getSchedules()).called(1);
    });

    test('should handle loading error', () async {
      const errorMessage = 'Database connection failed';
      when(mockDatabaseService.getSchedules()).thenThrow(Exception(errorMessage));

      await scheduleProvider.loadSchedules();

      expect(scheduleProvider.schedules, isEmpty);
      expect(scheduleProvider.isLoading, isFalse);
      expect(scheduleProvider.error, contains(errorMessage));
      verify(mockDatabaseService.getSchedules()).called(1);
    });

    test('should add schedule successfully', () async {
      final newSchedule = Schedule(
        className: 'New Class',
        subject: 'Reading Time',
        startTime: DateTime(2024, 1, 15, 11, 0),
        endTime: DateTime(2024, 1, 15, 11, 30),
        dayOfWeek: 'Wednesday',
        teacherId: 3,
      );

      when(mockDatabaseService.insertSchedule(any)).thenAnswer((_) async => 4);

      await scheduleProvider.addSchedule(newSchedule);

      expect(scheduleProvider.schedules.length, equals(1));
      expect(scheduleProvider.schedules.first.id, equals(4));
      expect(scheduleProvider.schedules.first.subject, equals('Reading Time'));
      expect(scheduleProvider.isLoading, isFalse);
      expect(scheduleProvider.error, isNull);
      verify(mockDatabaseService.insertSchedule(any)).called(1);
    });

    test('should update schedule successfully', () async {
      when(mockDatabaseService.getSchedules()).thenAnswer((_) async => testSchedules);
      await scheduleProvider.loadSchedules();

      final updatedSchedule = testSchedules.first.copyWith(subject: 'Updated Circle Time');
      when(mockDatabaseService.updateSchedule(any)).thenAnswer((_) async => 1);

      await scheduleProvider.updateSchedule(updatedSchedule);

      expect(scheduleProvider.schedules.first.subject, equals('Updated Circle Time'));
      expect(scheduleProvider.isLoading, isFalse);
      expect(scheduleProvider.error, isNull);
      verify(mockDatabaseService.updateSchedule(any)).called(1);
    });

    test('should delete schedule successfully', () async {
      when(mockDatabaseService.getSchedules()).thenAnswer((_) async => testSchedules);
      await scheduleProvider.loadSchedules();

      when(mockDatabaseService.deleteSchedule(1)).thenAnswer((_) async => 1);

      await scheduleProvider.deleteSchedule(1);

      expect(scheduleProvider.schedules.length, equals(2));
      expect(scheduleProvider.schedules.every((s) => s.id != 1), isTrue);
      expect(scheduleProvider.isLoading, isFalse);
      expect(scheduleProvider.error, isNull);
      verify(mockDatabaseService.deleteSchedule(1)).called(1);
    });

    test('should get schedules for specific day', () async {
      when(mockDatabaseService.getSchedules()).thenAnswer((_) async => testSchedules);
      await scheduleProvider.loadSchedules();

      final mondaySchedules = scheduleProvider.getSchedulesForDay('Monday');
      final tuesdaySchedules = scheduleProvider.getSchedulesForDay('Tuesday');

      expect(mondaySchedules.length, equals(2));
      expect(tuesdaySchedules.length, equals(1));
      expect(tuesdaySchedules.first.subject, equals('Art Class'));
    });

    test('should sort schedules for day by start time', () async {
      when(mockDatabaseService.getSchedules()).thenAnswer((_) async => testSchedules);
      await scheduleProvider.loadSchedules();

      final mondaySchedules = scheduleProvider.getSchedulesForDay('Monday');

      expect(mondaySchedules.first.startTime.hour, equals(9));
      expect(mondaySchedules.last.startTime.hour, equals(10));
    });

    test('should get schedules for specific class', () async {
      when(mockDatabaseService.getSchedules()).thenAnswer((_) async => testSchedules);
      await scheduleProvider.loadSchedules();

      final rainbowClassSchedules = scheduleProvider.getSchedulesForClass('Rainbow Class');
      final sunshineClassSchedules = scheduleProvider.getSchedulesForClass('Sunshine Class');

      expect(rainbowClassSchedules.length, equals(2));
      expect(sunshineClassSchedules.length, equals(1));
      expect(sunshineClassSchedules.first.subject, equals('Math Time'));
    });

    test('should get unique classes correctly', () async {
      when(mockDatabaseService.getSchedules()).thenAnswer((_) async => testSchedules);
      await scheduleProvider.loadSchedules();

      final uniqueClasses = scheduleProvider.uniqueClasses;

      expect(uniqueClasses.length, equals(2));
      expect(uniqueClasses.contains('Rainbow Class'), isTrue);
      expect(uniqueClasses.contains('Sunshine Class'), isTrue);
    });

    test('should clear error', () async {
      const errorMessage = 'Test error';
      when(mockDatabaseService.getSchedules()).thenThrow(Exception(errorMessage));
      await scheduleProvider.loadSchedules();

      expect(scheduleProvider.error, isNotNull);

      scheduleProvider.clearError();

      expect(scheduleProvider.error, isNull);
    });

    test('should notify listeners during operations', () async {
      var notificationCount = 0;
      scheduleProvider.addListener(() {
        notificationCount++;
      });

      when(mockDatabaseService.getSchedules()).thenAnswer((_) async => testSchedules);

      await scheduleProvider.loadSchedules();

      expect(notificationCount, greaterThanOrEqualTo(2));
    });
  });
}
