import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kindergarten_frontend/providers/staff_provider.dart';
import 'package:kindergarten_frontend/models/staff.dart';
import 'package:kindergarten_frontend/services/database_service.dart';

import 'test_staff_provider.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  group('StaffProvider Tests', () {
    late StaffProvider staffProvider;
    late MockDatabaseService mockDatabaseService;
    late List<Staff> testStaff;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      staffProvider = StaffProvider();
      
      testStaff = [
        Staff(
          id: 1,
          firstName: 'Sarah',
          lastName: 'Johnson',
          email: 'sarah.johnson@kindergarten.com',
          phone: '555-0101',
          role: StaffRole.teacher,
          hireDate: DateTime(2023, 1, 15),
        ),
        Staff(
          id: 2,
          firstName: 'Michael',
          lastName: 'Chen',
          email: 'michael.chen@kindergarten.com',
          phone: '555-0201',
          role: StaffRole.administrator,
          hireDate: DateTime(2022, 8, 1),
        ),
      ];
    });

    tearDown(() {
      reset(mockDatabaseService);
    });

    test('should initialize with empty staff list', () {
      expect(staffProvider.staff, isEmpty);
      expect(staffProvider.isLoading, isFalse);
      expect(staffProvider.error, isNull);
    });

    test('should load staff successfully', () async {
      when(mockDatabaseService.getStaff()).thenAnswer((_) async => testStaff);

      await staffProvider.loadStaff();

      expect(staffProvider.staff, equals(testStaff));
      expect(staffProvider.isLoading, isFalse);
      expect(staffProvider.error, isNull);
      verify(mockDatabaseService.getStaff()).called(1);
    });

    test('should handle loading error', () async {
      const errorMessage = 'Database connection failed';
      when(mockDatabaseService.getStaff()).thenThrow(Exception(errorMessage));

      await staffProvider.loadStaff();

      expect(staffProvider.staff, isEmpty);
      expect(staffProvider.isLoading, isFalse);
      expect(staffProvider.error, contains(errorMessage));
      verify(mockDatabaseService.getStaff()).called(1);
    });

    test('should add staff successfully', () async {
      final newStaff = Staff(
        firstName: 'Alice',
        lastName: 'Wilson',
        email: 'alice.wilson@kindergarten.com',
        phone: '555-0301',
        role: StaffRole.nurse,
        hireDate: DateTime(2024, 1, 15),
      );

      when(mockDatabaseService.insertStaff(any)).thenAnswer((_) async => 3);

      await staffProvider.addStaff(newStaff);

      expect(staffProvider.staff.length, equals(1));
      expect(staffProvider.staff.first.id, equals(3));
      expect(staffProvider.staff.first.firstName, equals('Alice'));
      expect(staffProvider.isLoading, isFalse);
      expect(staffProvider.error, isNull);
      verify(mockDatabaseService.insertStaff(any)).called(1);
    });

    test('should handle add staff error', () async {
      final newStaff = Staff(
        firstName: 'Alice',
        lastName: 'Wilson',
        email: 'alice.wilson@kindergarten.com',
        phone: '555-0301',
        role: StaffRole.nurse,
        hireDate: DateTime(2024, 1, 15),
      );

      const errorMessage = 'Insert failed';
      when(mockDatabaseService.insertStaff(any)).thenThrow(Exception(errorMessage));

      await staffProvider.addStaff(newStaff);

      expect(staffProvider.staff, isEmpty);
      expect(staffProvider.isLoading, isFalse);
      expect(staffProvider.error, contains(errorMessage));
      verify(mockDatabaseService.insertStaff(any)).called(1);
    });

    test('should update staff successfully', () async {
      when(mockDatabaseService.getStaff()).thenAnswer((_) async => testStaff);
      await staffProvider.loadStaff();

      final updatedStaff = testStaff.first.copyWith(firstName: 'Sarah Jane');
      when(mockDatabaseService.updateStaff(any)).thenAnswer((_) async => 1);

      await staffProvider.updateStaff(updatedStaff);

      expect(staffProvider.staff.first.firstName, equals('Sarah Jane'));
      expect(staffProvider.isLoading, isFalse);
      expect(staffProvider.error, isNull);
      verify(mockDatabaseService.updateStaff(any)).called(1);
    });

    test('should delete staff successfully', () async {
      when(mockDatabaseService.getStaff()).thenAnswer((_) async => testStaff);
      await staffProvider.loadStaff();

      when(mockDatabaseService.deleteStaff(1)).thenAnswer((_) async => 1);

      await staffProvider.deleteStaff(1);

      expect(staffProvider.staff.length, equals(1));
      expect(staffProvider.staff.first.id, equals(2));
      expect(staffProvider.isLoading, isFalse);
      expect(staffProvider.error, isNull);
      verify(mockDatabaseService.deleteStaff(1)).called(1);
    });

    test('should get teachers correctly', () async {
      when(mockDatabaseService.getStaff()).thenAnswer((_) async => testStaff);
      await staffProvider.loadStaff();

      final teachers = staffProvider.getTeachers();

      expect(teachers.length, equals(1));
      expect(teachers.first.role, equals(StaffRole.teacher));
      expect(teachers.first.firstName, equals('Sarah'));
    });

    test('should get staff by id correctly', () async {
      when(mockDatabaseService.getStaff()).thenAnswer((_) async => testStaff);
      await staffProvider.loadStaff();

      final staff = staffProvider.getStaffById(1);
      final nonExistentStaff = staffProvider.getStaffById(999);

      expect(staff, isNotNull);
      expect(staff!.firstName, equals('Sarah'));
      expect(nonExistentStaff, isNull);
    });

    test('should clear error', () async {
      const errorMessage = 'Test error';
      when(mockDatabaseService.getStaff()).thenThrow(Exception(errorMessage));
      await staffProvider.loadStaff();

      expect(staffProvider.error, isNotNull);

      staffProvider.clearError();

      expect(staffProvider.error, isNull);
    });
  });
}
