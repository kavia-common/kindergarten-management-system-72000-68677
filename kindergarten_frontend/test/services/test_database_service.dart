import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:kindergarten_frontend/services/database_service.dart';
import 'package:kindergarten_frontend/models/student.dart';
import 'package:kindergarten_frontend/models/staff.dart';
import 'package:kindergarten_frontend/models/attendance.dart';
import 'package:kindergarten_frontend/models/schedule.dart';
import 'package:kindergarten_frontend/models/message.dart';
import 'package:kindergarten_frontend/models/notification.dart';

void main() {
  group('DatabaseService Tests', () {
    late DatabaseService databaseService;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      databaseService = DatabaseService.instance;
      // Use in-memory database for testing
      await databaseService.initDatabase();
    });

    group('Student Operations', () {
      test('should insert and retrieve student', () async {
        final student = Student(
          firstName: 'Test',
          lastName: 'Student',
          dateOfBirth: DateTime(2019, 1, 1),
          classId: 'Test Class',
          enrollmentDate: DateTime(2024, 1, 1),
        );

        final id = await databaseService.insertStudent(student);
        expect(id, isA<int>());
        expect(id, greaterThan(0));

        final retrievedStudent = await databaseService.getStudent(id);
        expect(retrievedStudent, isNotNull);
        expect(retrievedStudent!.firstName, equals('Test'));
        expect(retrievedStudent.lastName, equals('Student'));
      });

      test('should get all students', () async {
        final student1 = Student(
          firstName: 'Student',
          lastName: 'One',
          dateOfBirth: DateTime(2019, 1, 1),
          classId: 'Class A',
          enrollmentDate: DateTime(2024, 1, 1),
        );

        final student2 = Student(
          firstName: 'Student',
          lastName: 'Two',
          dateOfBirth: DateTime(2019, 2, 1),
          classId: 'Class B',
          enrollmentDate: DateTime(2024, 1, 1),
        );

        await databaseService.insertStudent(student1);
        await databaseService.insertStudent(student2);

        final students = await databaseService.getStudents();
        expect(students.length, greaterThanOrEqualTo(2));
      });

      test('should update student', () async {
        final student = Student(
          firstName: 'Original',
          lastName: 'Name',
          dateOfBirth: DateTime(2019, 1, 1),
          classId: 'Class A',
          enrollmentDate: DateTime(2024, 1, 1),
        );

        final id = await databaseService.insertStudent(student);
        final updatedStudent = student.copyWith(id: id, firstName: 'Updated');

        final result = await databaseService.updateStudent(updatedStudent);
        expect(result, equals(1));

        final retrievedStudent = await databaseService.getStudent(id);
        expect(retrievedStudent!.firstName, equals('Updated'));
      });

      test('should soft delete student', () async {
        final student = Student(
          firstName: 'To Delete',
          lastName: 'Student',
          dateOfBirth: DateTime(2019, 1, 1),
          classId: 'Class A',
          enrollmentDate: DateTime(2024, 1, 1),
        );

        final id = await databaseService.insertStudent(student);
        
        final result = await databaseService.deleteStudent(id);
        expect(result, equals(1));

        final students = await databaseService.getStudents();
        expect(students.where((s) => s.id == id), isEmpty);
      });
    });

    group('Staff Operations', () {
      test('should insert and retrieve staff', () async {
        final staff = Staff(
          firstName: 'Test',
          lastName: 'Teacher',
          email: 'test@teacher.com',
          phone: '123-456-7890',
          role: StaffRole.teacher,
          hireDate: DateTime(2024, 1, 1),
        );

        final id = await databaseService.insertStaff(staff);
        expect(id, isA<int>());
        expect(id, greaterThan(0));

        final retrievedStaff = await databaseService.getStaffMember(id);
        expect(retrievedStaff, isNotNull);
        expect(retrievedStaff!.firstName, equals('Test'));
        expect(retrievedStaff.email, equals('test@teacher.com'));
      });

      test('should get all staff', () async {
        final staff1 = Staff(
          firstName: 'Teacher',
          lastName: 'One',
          email: 'teacher1@test.com',
          phone: '123-456-7890',
          role: StaffRole.teacher,
          hireDate: DateTime(2024, 1, 1),
        );

        await databaseService.insertStaff(staff1);
        final staffList = await databaseService.getStaff();
        expect(staffList.length, greaterThanOrEqualTo(1));
      });
    });

    group('Attendance Operations', () {
      test('should insert and retrieve attendance', () async {
        // First create a student
        final student = Student(
          firstName: 'Test',
          lastName: 'Student',
          dateOfBirth: DateTime(2019, 1, 1),
          classId: 'Test Class',
          enrollmentDate: DateTime(2024, 1, 1),
        );
        final studentId = await databaseService.insertStudent(student);

        final attendance = Attendance(
          studentId: studentId,
          date: DateTime.now(),
          status: AttendanceStatus.present,
          checkInTime: DateTime.now(),
        );

        final id = await databaseService.insertAttendance(attendance);
        expect(id, isA<int>());
        expect(id, greaterThan(0));

        final attendanceList = await databaseService.getAttendance();
        expect(attendanceList.where((a) => a.id == id), isNotEmpty);
      });

      test('should get attendance for specific date', () async {
        final testDate = DateTime(2024, 1, 15);
        final attendanceList = await databaseService.getAttendance(date: testDate);
        expect(attendanceList, isA<List<Attendance>>());
      });
    });

    group('Schedule Operations', () {
      test('should insert and retrieve schedule', () async {
        final schedule = Schedule(
          className: 'Test Class',
          subject: 'Test Subject',
          startTime: DateTime(2024, 1, 15, 9, 0),
          endTime: DateTime(2024, 1, 15, 10, 0),
          dayOfWeek: 'Monday',
          teacherId: 1,
        );

        final id = await databaseService.insertSchedule(schedule);
        expect(id, isA<int>());
        expect(id, greaterThan(0));

        final schedules = await databaseService.getSchedules();
        expect(schedules.where((s) => s.id == id), isNotEmpty);
      });
    });

    group('Message Operations', () {
      test('should insert and retrieve message', () async {
        final message = Message(
          title: 'Test Message',
          content: 'Test content',
          type: MessageType.announcement,
          senderId: 1,
          createdAt: DateTime.now(),
        );

        final id = await databaseService.insertMessage(message);
        expect(id, isA<int>());
        expect(id, greaterThan(0));

        final messages = await databaseService.getMessages();
        expect(messages.where((m) => m.id == id), isNotEmpty);
      });
    });

    group('Notification Operations', () {
      test('should insert and retrieve notification', () async {
        final notification = AppNotification(
          title: 'Test Notification',
          message: 'Test message',
          type: NotificationType.info,
          createdAt: DateTime.now(),
        );

        final id = await databaseService.insertNotification(notification);
        expect(id, isA<int>());
        expect(id, greaterThan(0));

        final notifications = await databaseService.getNotifications();
        expect(notifications.where((n) => n.id == id), isNotEmpty);
      });
    });

    group('Database Initialization', () {
      test('should initialize database with sample data', () async {
        final students = await databaseService.getStudents();
        final staff = await databaseService.getStaff();
        final messages = await databaseService.getMessages();
        final notifications = await databaseService.getNotifications();

        expect(students, isNotEmpty);
        expect(staff, isNotEmpty);
        expect(messages, isNotEmpty);
        expect(notifications, isNotEmpty);
      });

      test('should handle database operations without errors', () async {
        // Test that basic operations don't throw exceptions
        expect(() async => await databaseService.getStudents(), returnsNormally);
        expect(() async => await databaseService.getStaff(), returnsNormally);
        expect(() async => await databaseService.getMessages(), returnsNormally);
        expect(() async => await databaseService.getNotifications(), returnsNormally);
      });
    });

    group('Error Handling', () {
      test('should handle invalid student ID gracefully', () async {
        final student = await databaseService.getStudent(-1);
        expect(student, isNull);
      });

      test('should handle invalid staff ID gracefully', () async {
        final staff = await databaseService.getStaffMember(-1);
        expect(staff, isNull);
      });
    });
  });
}
