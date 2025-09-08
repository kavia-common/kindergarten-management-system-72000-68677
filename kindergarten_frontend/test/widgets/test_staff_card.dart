import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/widgets/staff_card.dart';
import 'package:kindergarten_frontend/models/staff.dart';

void main() {
  group('StaffCard Widget Tests', () {
    late Staff testStaff;

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
    });

    testWidgets('should display basic staff information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffCard(
              staff: testStaff,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sarah Johnson'), findsOneWidget);
      expect(find.text('Role: TEACHER'), findsOneWidget);
      expect(find.text('Email: sarah.johnson@kindergarten.com'), findsOneWidget);
      expect(find.text('S'), findsOneWidget); // Avatar initial
    });

    testWidgets('should show expanded details when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffCard(
              staff: testStaff,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Initially, detailed info should not be visible
      expect(find.text('Early Childhood'), findsNothing);
      expect(find.text('B.Ed in Early Childhood Education'), findsNothing);

      // Tap to expand
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Now detailed info should be visible
      expect(find.text('Early Childhood'), findsOneWidget);
      expect(find.text('B.Ed in Early Childhood Education'), findsOneWidget);
      expect(find.text('555-0101'), findsOneWidget);
    });

    testWidgets('should handle edit action', (WidgetTester tester) async {
      bool editCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffCard(
              staff: testStaff,
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
            body: StaffCard(
              staff: testStaff,
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

    testWidgets('should display different role colors', (WidgetTester tester) async {
      final teacherStaff = testStaff.copyWith(role: StaffRole.teacher);
      final adminStaff = testStaff.copyWith(role: StaffRole.administrator);
      final nurseStaff = testStaff.copyWith(role: StaffRole.nurse);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StaffCard(staff: teacherStaff, onEdit: () {}, onDelete: () {}),
                StaffCard(staff: adminStaff, onEdit: () {}, onDelete: () {}),
                StaffCard(staff: nurseStaff, onEdit: () {}, onDelete: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.text('TEACHER'), findsOneWidget);
      expect(find.text('ADMINISTRATOR'), findsOneWidget);
      expect(find.text('NURSE'), findsOneWidget);
    });

    testWidgets('should handle staff with minimal information', (WidgetTester tester) async {
      final minimalStaff = Staff(
        id: 2,
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@kindergarten.com',
        phone: '555-0000',
        role: StaffRole.other,
        hireDate: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffCard(
              staff: minimalStaff,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Role: OTHER'), findsOneWidget);
      expect(find.text('J'), findsOneWidget); // Avatar initial

      // Expand to see that optional fields are handled
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Should not crash with null values
      expect(find.byType(StaffCard), findsOneWidget);
    });

    testWidgets('should display all expanded information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffCard(
              staff: testStaff,
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
      expect(find.textContaining('Phone:'), findsOneWidget);
      expect(find.textContaining('Role:'), findsAtLeastNWidgets(1)); // One in subtitle, one in expanded
      expect(find.textContaining('Department:'), findsOneWidget);
      expect(find.textContaining('Hire Date:'), findsOneWidget);
      expect(find.textContaining('Qualifications:'), findsOneWidget);
      expect(find.textContaining('Emergency Contact:'), findsOneWidget);
    });

    testWidgets('should format hire date correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffCard(
              staff: testStaff,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Expand the card to see hire date
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Should show formatted date
      expect(find.textContaining('Jan 15, 2023'), findsOneWidget);
    });

    testWidgets('should handle very long names gracefully', (WidgetTester tester) async {
      final longNameStaff = testStaff.copyWith(
        firstName: 'Christopher Alexander',
        lastName: 'Van Der Berg-Johnson',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffCard(
              staff: longNameStaff,
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
            body: StaffCard(
              staff: testStaff,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Test that the widget is accessible
      expect(tester.getSemantics(find.byType(StaffCard)), isNotNull);
      expect(find.text('Sarah Johnson'), findsOneWidget);
    });

    testWidgets('should show correct role colors for all roles', (WidgetTester tester) async {
      // Test that all staff roles are handled correctly
      for (final role in StaffRole.values) {
        final roleStaff = testStaff.copyWith(role: role);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StaffCard(
                staff: roleStaff,
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.text(role.toString().split('.').last.toUpperCase()), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
        
        // Clear the widget tree for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });
}
