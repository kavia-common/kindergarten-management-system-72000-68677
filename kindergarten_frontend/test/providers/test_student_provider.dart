import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kindergarten_frontend/providers/student_provider.dart';
import 'package:kindergarten_frontend/models/student.dart';
import 'package:kindergarten_frontend/services/database_service.dart';

import 'test_student_provider.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  group('StudentProvider Tests', () {
    late StudentProvider studentProvider;
    late MockDatabaseService mockDatabaseService;
    late List<Student> testStudents;

    setUpAll(() {
      // Initialize Flutter test bindings to fix WidgetsBinding.instance error
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      studentProvider = StudentProvider();
      
      // Override the database service instance for testing
      DatabaseService.instance = mockDatabaseService;

      testStudents = [
        Student(
          id: 1,
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: DateTime(2019, 5, 15),
          classId: 'Rainbow Class',
          enrollmentDate: DateTime(2024, 9, 1),
        ),
        Student(
          id: 2,
          firstName: 'Jane',
          lastName: 'Smith',
          dateOfBirth: DateTime(2019, 8, 20),
          classId: 'Sunshine Class',
          enrollmentDate: DateTime(2024, 9, 1),
        ),
      ];
    });

    tearDown(() {
      reset(mockDatabaseService);
    });

    test('should initialize with empty students list', () {
      expect(studentProvider.students, isEmpty);
      expect(studentProvider.isLoading, isFalse);
      expect(studentProvider.error, isNull);
    });

    test('should load students successfully', () async {
      when(mockDatabaseService.getStudents()).thenAnswer((_) async => testStudents);

      await studentProvider.loadStudents();

      expect(studentProvider.students, equals(testStudents));
      expect(studentProvider.isLoading, isFalse);
      expect(studentProvider.error, isNull);
      verify(mockDatabaseService.getStudents()).called(1);
    });

    test('should handle loading error', () async {
      const errorMessage = 'Database connection failed';
      when(mockDatabaseService.getStudents()).thenThrow(Exception(errorMessage));

      await studentProvider.loadStudents();

      expect(studentProvider.students, isEmpty);
      expect(studentProvider.isLoading, isFalse);
      expect(studentProvider.error, contains(errorMessage));
      verify(mockDatabaseService.getStudents()).called(1);
    });

    test('should add student successfully', () async {
      final newStudent = Student(
        firstName: 'Alice',
        lastName: 'Johnson',
        dateOfBirth: DateTime(2020, 1, 10),
        classId: 'Rainbow Class',
        enrollmentDate: DateTime(2024, 9, 1),
      );

      when(mockDatabaseService.insertStudent(any)).thenAnswer((_) async => 3);

      await studentProvider.addStudent(newStudent);

      expect(studentProvider.students.length, equals(1));
      expect(studentProvider.students.first.id, equals(3));
      expect(studentProvider.students.first.firstName, equals('Alice'));
      expect(studentProvider.isLoading, isFalse);
      expect(studentProvider.error, isNull);
      verify(mockDatabaseService.insertStudent(any)).called(1);
    });

    test('should handle add student error', () async {
      final newStudent = Student(
        firstName: 'Alice',
        lastName: 'Johnson',
        dateOfBirth: DateTime(2020, 1, 10),
        classId: 'Rainbow Class',
        enrollmentDate: DateTime(2024, 9, 1),
      );

      const errorMessage = 'Insert failed';
      when(mockDatabaseService.insertStudent(any)).thenThrow(Exception(errorMessage));

      await studentProvider.addStudent(newStudent);

      expect(studentProvider.students, isEmpty);
      expect(studentProvider.isLoading, isFalse);
      expect(studentProvider.error, contains(errorMessage));
      verify(mockDatabaseService.insertStudent(any)).called(1);
    });

    test('should update student successfully', () async {
      // First load students
      when(mockDatabaseService.getStudents()).thenAnswer((_) async => testStudents);
      await studentProvider.loadStudents();

      final updatedStudent = testStudents.first.copyWith(firstName: 'Johnny');
      when(mockDatabaseService.updateStudent(any)).thenAnswer((_) async => 1);

      await studentProvider.updateStudent(updatedStudent);

      expect(studentProvider.students.first.firstName, equals('Johnny'));
      expect(studentProvider.isLoading, isFalse);
      expect(studentProvider.error, isNull);
      verify(mockDatabaseService.updateStudent(any)).called(1);
    });

    test('should handle update student error', () async {
      // First load students
      when(mockDatabaseService.getStudents()).thenAnswer((_) async => testStudents);
      await studentProvider.loadStudents();

      final updatedStudent = testStudents.first.copyWith(firstName: 'Johnny');
      const errorMessage = 'Update failed';
      when(mockDatabaseService.updateStudent(any)).thenThrow(Exception(errorMessage));

      await studentProvider.updateStudent(updatedStudent);

      expect(studentProvider.students.first.firstName, equals('John')); // Unchanged
      expect(studentProvider.isLoading, isFalse);
      expect(studentProvider.error, contains(errorMessage));
      verify(mockDatabaseService.updateStudent(any)).called(1);
    });

    test('should delete student successfully', () async {
      // First load students
      when(mockDatabaseService.getStudents()).thenAnswer((_) async => testStudents);
      await studentProvider.loadStudents();

      when(mockDatabaseService.deleteStudent(1)).thenAnswer((_) async => 1);

      await studentProvider.deleteStudent(1);

      expect(studentProvider.students.length, equals(1));
      expect(studentProvider.students.first.id, equals(2));
      expect(studentProvider.isLoading, isFalse);
      expect(studentProvider.error, isNull);
      verify(mockDatabaseService.deleteStudent(1)).called(1);
    });

    test('should handle delete student error', () async {
      // First load students
      when(mockDatabaseService.getStudents()).thenAnswer((_) async => testStudents);
      await studentProvider.loadStudents();

      const errorMessage = 'Delete failed';
      when(mockDatabaseService.deleteStudent(1)).thenThrow(Exception(errorMessage));

      await studentProvider.deleteStudent(1);

      expect(studentProvider.students.length, equals(2)); // Unchanged
      expect(studentProvider.isLoading, isFalse);
      expect(studentProvider.error, contains(errorMessage));
      verify(mockDatabaseService.deleteStudent(1)).called(1);
    });

    test('should get students by class correctly', () async {
      when(mockDatabaseService.getStudents()).thenAnswer((_) async => testStudents);
      await studentProvider.loadStudents();

      final rainbowClassStudents = studentProvider.getStudentsByClass('Rainbow Class');
      final sunshineClassStudents = studentProvider.getStudentsByClass('Sunshine Class');

      expect(rainbowClassStudents.length, equals(1));
      expect(rainbowClassStudents.first.firstName, equals('John'));
      expect(sunshineClassStudents.length, equals(1));
      expect(sunshineClassStudents.first.firstName, equals('Jane'));
    });

    test('should get student by id correctly', () async {
      when(mockDatabaseService.getStudents()).thenAnswer((_) async => testStudents);
      await studentProvider.loadStudents();

      final student = studentProvider.getStudentById(1);
      final nonExistentStudent = studentProvider.getStudentById(999);

      expect(student, isNotNull);
      expect(student!.firstName, equals('John'));
      expect(nonExistentStudent, isNull);
    });

    test('should clear error', () async {
      const errorMessage = 'Test error';
      when(mockDatabaseService.getStudents()).thenThrow(Exception(errorMessage));
      await studentProvider.loadStudents();

      expect(studentProvider.error, isNotNull);

      studentProvider.clearError();

      expect(studentProvider.error, isNull);
    });

    test('should notify listeners during operations', () async {
      var notificationCount = 0;
      studentProvider.addListener(() {
        notificationCount++;
      });

      when(mockDatabaseService.getStudents()).thenAnswer((_) async => testStudents);

      await studentProvider.loadStudents();

      // Should notify at least twice: once for loading start, once for completion
      expect(notificationCount, greaterThanOrEqualTo(2));
    });

    test('should handle concurrent operations', () async {
      when(mockDatabaseService.getStudents()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return testStudents;
      });

      final futures = [
        studentProvider.loadStudents(),
        studentProvider.loadStudents(),
        studentProvider.loadStudents(),
      ];

      await Future.wait(futures);

      expect(studentProvider.students, equals(testStudents));
      expect(studentProvider.isLoading, isFalse);
      expect(studentProvider.error, isNull);
    });
  });
}
