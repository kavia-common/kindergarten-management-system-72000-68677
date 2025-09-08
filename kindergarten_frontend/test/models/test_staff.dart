import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/models/staff.dart';

void main() {
  group('Staff Model Tests', () {
    late Staff testStaff;
    late Map<String, dynamic> testStaffMap;

    setUp(() {
      testStaff = Staff(
        id: 1,
        firstName: 'Sarah',
        lastName: 'Johnson',
        email: 'sarah.johnson@kindergarten.com',
        phone: '555-0101',
        role: StaffRole.teacher,
        department: 'Early Childhood',
        hireDate: DateTime(2023, 1, 15),
        qualifications: 'B.Ed in Early Childhood Education',
        emergencyContact: '555-0102',
        isActive: true,
      );

      testStaffMap = {
        'id': 1,
        'firstName': 'Sarah',
        'lastName': 'Johnson',
        'email': 'sarah.johnson@kindergarten.com',
        'phone': '555-0101',
        'role': 'teacher',
        'department': 'Early Childhood',
        'hireDate': DateTime(2023, 1, 15).millisecondsSinceEpoch,
        'qualifications': 'B.Ed in Early Childhood Education',
        'emergencyContact': '555-0102',
        'isActive': 1,
      };
    });

    test('should create a Staff instance with all properties', () {
      expect(testStaff.id, equals(1));
      expect(testStaff.firstName, equals('Sarah'));
      expect(testStaff.lastName, equals('Johnson'));
      expect(testStaff.email, equals('sarah.johnson@kindergarten.com'));
      expect(testStaff.role, equals(StaffRole.teacher));
      expect(testStaff.isActive, isTrue);
    });

    test('should return correct full name', () {
      expect(testStaff.fullName, equals('Sarah Johnson'));
    });

    test('should return correct role display name', () {
      expect(testStaff.roleDisplayName, equals('TEACHER'));
      
      final admin = testStaff.copyWith(role: StaffRole.administrator);
      expect(admin.roleDisplayName, equals('ADMINISTRATOR'));
      
      final nurse = testStaff.copyWith(role: StaffRole.nurse);
      expect(nurse.roleDisplayName, equals('NURSE'));
    });

    test('should convert to map correctly', () {
      final map = testStaff.toMap();
      expect(map['id'], equals(1));
      expect(map['firstName'], equals('Sarah'));
      expect(map['lastName'], equals('Johnson'));
      expect(map['role'], equals('teacher'));
      expect(map['isActive'], equals(1));
      expect(map['hireDate'], equals(DateTime(2023, 1, 15).millisecondsSinceEpoch));
    });

    test('should create Staff from map correctly', () {
      final staff = Staff.fromMap(testStaffMap);
      expect(staff.id, equals(1));
      expect(staff.firstName, equals('Sarah'));
      expect(staff.lastName, equals('Johnson'));
      expect(staff.fullName, equals('Sarah Johnson'));
      expect(staff.role, equals(StaffRole.teacher));
      expect(staff.roleDisplayName, equals('TEACHER'));
      expect(staff.isActive, isTrue);
    });

    test('should handle different staff roles correctly', () {
      for (final role in StaffRole.values) {
        final roleMap = {
          'firstName': 'Test',
          'lastName': 'Staff',
          'email': 'test@test.com',
          'phone': '555-0000',
          'role': role.toString().split('.').last,
          'hireDate': DateTime.now().millisecondsSinceEpoch,
          'isActive': 1,
        };

        final staff = Staff.fromMap(roleMap);
        expect(staff.role, equals(role));
        expect(staff.roleDisplayName, equals(role.toString().split('.').last.toUpperCase()));
      }
    });

    test('should handle unknown role correctly', () {
      final unknownRoleMap = {
        'firstName': 'Test',
        'lastName': 'Staff',
        'email': 'test@test.com',
        'phone': '555-0000',
        'role': 'unknown_role',
        'hireDate': DateTime.now().millisecondsSinceEpoch,
        'isActive': 1,
      };

      final staff = Staff.fromMap(unknownRoleMap);
      expect(staff.role, equals(StaffRole.other));
    });

    test('should handle null optional fields correctly', () {
      final minimalMap = {
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@test.com',
        'phone': '555-0000',
        'role': 'teacher',
        'hireDate': DateTime.now().millisecondsSinceEpoch,
        'isActive': 1,
      };

      final staff = Staff.fromMap(minimalMap);
      expect(staff.department, isNull);
      expect(staff.qualifications, isNull);
      expect(staff.emergencyContact, isNull);
    });

    test('should copy with new values correctly', () {
      final updatedStaff = testStaff.copyWith(
        firstName: 'Michael',
        role: StaffRole.administrator,
        department: 'Administration',
      );

      expect(updatedStaff.firstName, equals('Michael'));
      expect(updatedStaff.role, equals(StaffRole.administrator));
      expect(updatedStaff.roleDisplayName, equals('ADMINISTRATOR'));
      expect(updatedStaff.department, equals('Administration'));
      expect(updatedStaff.fullName, equals('Michael Johnson'));
      
      // Original values should remain for unchanged fields
      expect(updatedStaff.id, equals(testStaff.id));
      expect(updatedStaff.lastName, equals(testStaff.lastName));
      expect(updatedStaff.email, equals(testStaff.email));
    });

    test('should handle inactive staff correctly', () {
      final inactiveStaff = testStaff.copyWith(isActive: false);
      expect(inactiveStaff.isActive, isFalse);
      
      final map = inactiveStaff.toMap();
      expect(map['isActive'], equals(0));
    });

    test('should handle minimum required fields only', () {
      final minimalStaff = Staff(
        firstName: 'Test',
        lastName: 'Staff',
        email: 'test@test.com',
        phone: '555-0000',
        role: StaffRole.other,
        hireDate: DateTime.now(),
      );

      expect(minimalStaff.firstName, equals('Test'));
      expect(minimalStaff.lastName, equals('Staff'));
      expect(minimalStaff.fullName, equals('Test Staff'));
      expect(minimalStaff.role, equals(StaffRole.other));
      expect(minimalStaff.isActive, isTrue); // Default value
      expect(minimalStaff.id, isNull);
      expect(minimalStaff.department, isNull);
    });
  });
}
