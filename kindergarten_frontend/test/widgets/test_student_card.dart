import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/widgets/student_card.dart';
import 'package:kindergarten_frontend/models/student.dart';

void main() {
  group('StudentCard Widget Tests', () {
    late Student testStudent;

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
        medicalInfo: 'No known allergies',
        allergies: 'None',
        classId: 'Rainbow Class',
        enrollmentDate: DateTime(2024, 9, 1),
        isActive: true,
      );
    });

    testWidgets('should display basic student information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentCard(
              student: testStudent,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Class: Rainbow Class'), findsOneWidget);
      expect(find.textContaining('Age:'), findsOneWidget);
      expect(find.text('J'), findsOneWidget); // Avatar initial
    });

    testWidgets('should show expanded details when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentCard(
              student: testStudent,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Initially, detailed info should not be visible
      expect(find.text('jane.doe@email.com'), findsNothing);
      expect(find.text('123 Main St'), findsNothing);

      // Tap to expand
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Now detailed info should be visible
      expect(find.text('jane.doe@email.com'), findsOneWidget);
      expect(find.text('123 Main St'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('555-1234'), findsOneWidget);
    });

    testWidgets('should handle edit action', (WidgetTester tester) async {
      bool editCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentCard(
              student: testStudent,
              onEdit: () => editCalled = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      // Tap the popup menu button
      await tester.tap(find.byType(PopupMenuButton));
      await tester.pumpAndSettle();

      // Tap edit option
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });

    testWidgets('should handle delete action', (WidgetTester tester) async {
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentCard(
              student: testStudent,
              onEdit: () {},
              onDelete: () => deleteCalled = true,
            ),
          ),
        ),
      );

      // Tap the popup menu button
      await tester.tap(find.byType(PopupMenuButton));
      await tester.pumpAndSettle();

      // Tap delete option
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });

    testWidgets('should display correct age calculation', (WidgetTester tester) async {
      final youngStudent = testStudent.copyWith(
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 4 + 100)), // About 4 years old
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentCard(
              student: youngStudent,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Age: 4 years'), findsOneWidget);
    });

    testWidgets('should handle student with minimal information', (WidgetTester tester) async {
      final minimalStudent = Student(
        id: 2,
        firstName: 'Jane',
        lastName: 'Smith',
        dateOfBirth: DateTime(2020, 1, 1),
        classId: 'Blue Class',
        enrollmentDate: DateTime(2024, 9, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentCard(
              student: minimalStudent,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Class: Blue Class'), findsOneWidget);
      expect(find.text('J'), findsOneWidget); // Avatar initial

      // Expand to see that optional fields are handled
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Should not crash with null values
      expect(find.byType(StudentCard), findsOneWidget);
    });

    testWidgets('should display all expanded information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentCard(
              student: testStudent,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Expand the card
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Check all the detailed information
      expect(find.textContaining('Date of Birth:'), findsOneWidget);
      expect(find.textContaining('Parent:'), findsOneWidget);
      expect(find.textContaining('Phone:'), findsOneWidget);
      expect(find.textContaining('Email:'), findsOneWidget);
      expect(find.textContaining('Address:'), findsOneWidget);
      expect(find.textContaining('Emergency Contact:'), findsOneWidget);
      expect(find.textContaining('Medical Info:'), findsOneWidget);
      expect(find.textContaining('Allergies:'), findsOneWidget);
      expect(find.textContaining('Enrollment Date:'), findsOneWidget);
    });

    testWidgets('should handle very long names gracefully', (WidgetTester tester) async {
      final longNameStudent = testStudent.copyWith(
        firstName: 'Christopher Alexander',
        lastName: 'Van Der Berg-Johnson',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentCard(
              student: longNameStudent,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Christopher Alexander Van Der Berg-Johnson'), findsOneWidget);
      expect(find.text('C'), findsOneWidget); // Avatar should show first initial
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentCard(
              student: testStudent,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Test that the widget is accessible
      expect(tester.getSemantics(find.byType(StudentCard)), isNotNull);
      expect(find.text('John Doe'), findsOneWidget);
    });
  });
}
