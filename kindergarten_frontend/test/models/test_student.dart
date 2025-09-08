import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/models/student.dart';

void main() {
  group('Student Model Tests', () {
    late Student testStudent;
    late Map<String, dynamic> testStudentMap;

    setUp(() {
      testStudent = Student(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        dateOfBirth: DateTime(2019, 5, 15),
        parentName: 'Jane Doe',
        parentPhone: '555-1234',
        parentEmail: 'jane.doe@email.com',
        address: '123 Main St',
        emergencyContact: '555-5678',
        medicalInfo: 'No allergies',
        allergies: 'None',
        classId: 'Rainbow Class',
        enrollmentDate: DateTime(2024, 9, 1),
        isActive: true,
      );

      testStudentMap = {
        'id': 1,
        'firstName': 'John',
        'lastName': 'Doe',
        'dateOfBirth': DateTime(2019, 5, 15).millisecondsSinceEpoch,
        'parentName': 'Jane Doe',
        'parentPhone': '555-1234',
        'parentEmail': 'jane.doe@email.com',
        'address': '123 Main St',
        'emergencyContact': '555-5678',
        'medicalInfo': 'No allergies',
        'allergies': 'None',
        'classId': 'Rainbow Class',
        'enrollmentDate': DateTime(2024, 9, 1).millisecondsSinceEpoch,
        'isActive': 1,
      };
    });

    test('should create a Student instance with all properties', () {
      expect(testStudent.id, equals(1));
      expect(testStudent.firstName, equals('John'));
      expect(testStudent.lastName, equals('Doe'));
      expect(testStudent.parentName, equals('Jane Doe'));
      expect(testStudent.classId, equals('Rainbow Class'));
      expect(testStudent.isActive, isTrue);
    });

    test('should return correct full name', () {
      expect(testStudent.fullName, equals('John Doe'));
    });

    test('should convert to map correctly', () {
      final map = testStudent.toMap();
      expect(map['id'], equals(1));
      expect(map['firstName'], equals('John'));
      expect(map['lastName'], equals('Doe'));
      expect(map['isActive'], equals(1));
      expect(map['dateOfBirth'], equals(DateTime(2019, 5, 15).millisecondsSinceEpoch));
    });

    test('should create Student from map correctly', () {
      final student = Student.fromMap(testStudentMap);
      expect(student.id, equals(1));
      expect(student.firstName, equals('John'));
      expect(student.lastName, equals('Doe'));
      expect(student.fullName, equals('John Doe'));
      expect(student.isActive, isTrue);
    });

    test('should handle null optional fields correctly', () {
      final minimalMap = {
        'firstName': 'John',
        'lastName': 'Doe',
        'dateOfBirth': DateTime(2019, 5, 15).millisecondsSinceEpoch,
        'classId': 'Rainbow Class',
        'enrollmentDate': DateTime(2024, 9, 1).millisecondsSinceEpoch,
        'isActive': 1,
      };

      final student = Student.fromMap(minimalMap);
      expect(student.parentName, isNull);
      expect(student.parentPhone, isNull);
      expect(student.parentEmail, isNull);
      expect(student.address, isNull);
      expect(student.emergencyContact, isNull);
      expect(student.medicalInfo, isNull);
      expect(student.allergies, isNull);
    });

    test('should copy with new values correctly', () {
      final updatedStudent = testStudent.copyWith(
        firstName: 'Jane',
        lastName: 'Smith',
        classId: 'Sunshine Class',
      );

      expect(updatedStudent.firstName, equals('Jane'));
      expect(updatedStudent.lastName, equals('Smith'));
      expect(updatedStudent.classId, equals('Sunshine Class'));
      expect(updatedStudent.fullName, equals('Jane Smith'));
      
      // Original values should remain for unchanged fields
      expect(updatedStudent.id, equals(testStudent.id));
      expect(updatedStudent.parentName, equals(testStudent.parentName));
      expect(updatedStudent.dateOfBirth, equals(testStudent.dateOfBirth));
    });

    test('should handle inactive student correctly', () {
      final inactiveStudent = testStudent.copyWith(isActive: false);
      expect(inactiveStudent.isActive, isFalse);
      
      final map = inactiveStudent.toMap();
      expect(map['isActive'], equals(0));
    });

    test('should handle minimum required fields only', () {
      final minimalStudent = Student(
        firstName: 'Test',
        lastName: 'Student',
        dateOfBirth: DateTime(2020, 1, 1),
        classId: 'Test Class',
        enrollmentDate: DateTime(2024, 1, 1),
      );

      expect(minimalStudent.firstName, equals('Test'));
      expect(minimalStudent.lastName, equals('Student'));
      expect(minimalStudent.fullName, equals('Test Student'));
      expect(minimalStudent.isActive, isTrue); // Default value
      expect(minimalStudent.id, isNull);
      expect(minimalStudent.parentName, isNull);
    });
  });
}
