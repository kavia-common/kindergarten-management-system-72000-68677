import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kindergarten_frontend/screens/staff_screen.dart';
import 'package:kindergarten_frontend/providers/staff_provider.dart';
import 'package:kindergarten_frontend/models/staff.dart';

import 'test_staff_screen.mocks.dart';

@GenerateMocks([StaffProvider])
void main() {
  group('StaffScreen Tests', () {
    late MockStaffProvider mockStaffProvider;
    late List<Staff> testStaff;

    setUp(() {
      mockStaffProvider = MockStaffProvider();
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

      when(mockStaffProvider.staff).thenReturn(testStaff);
      when(mockStaffProvider.isLoading).thenReturn(false);
      when(mockStaffProvider.error).thenReturn(null);
      when(mockStaffProvider.loadStaff()).thenAnswer((_) async {});
      when(mockStaffProvider.deleteStaff(any)).thenAnswer((_) async {});
    });

    Widget buildStaffScreen() {
      return MaterialApp(
        home: ChangeNotifierProvider<StaffProvider>.value(
          value: mockStaffProvider,
          child: const StaffScreen(),
        ),
      );
    }

    testWidgets('should display app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      expect(find.text('Staff'), findsOneWidget);
    });

    testWidgets('should display search field and role filter', (WidgetTester tester) async {
      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search staff...'), findsOneWidget);
      expect(find.byType(DropdownButton<StaffRole?>), findsOneWidget);
    });

    testWidgets('should display staff list', (WidgetTester tester) async {
      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      expect(find.text('Sarah Johnson'), findsOneWidget);
      expect(find.text('Michael Chen'), findsOneWidget);
      expect(find.text('sarah.johnson@kindergarten.com'), findsOneWidget);
      expect(find.text('michael.chen@kindergarten.com'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      when(mockStaffProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when error occurs', (WidgetTester tester) async {
      when(mockStaffProvider.error).thenReturn('Failed to load staff');

      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      expect(find.text('Error: Failed to load staff'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show empty state when no staff', (WidgetTester tester) async {
      when(mockStaffProvider.staff).thenReturn([]);

      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      expect(find.text('No staff members found'), findsOneWidget);
      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
    });

    testWidgets('should filter staff by search query', (WidgetTester tester) async {
      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      // Initially both staff should be visible
      expect(find.text('Sarah Johnson'), findsOneWidget);
      expect(find.text('Michael Chen'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Sarah');
      await tester.pump();

      // Only Sarah should be visible after filtering
      expect(find.text('Sarah Johnson'), findsOneWidget);
      expect(find.text('Michael Chen'), findsNothing);
    });

    testWidgets('should filter staff by role', (WidgetTester tester) async {
      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      // Tap dropdown to open role filter
      await tester.tap(find.byType(DropdownButton<StaffRole?>));
      await tester.pumpAndSettle();

      // Select teacher role
      await tester.tap(find.text('TEACHER').last);
      await tester.pumpAndSettle();

      // Only teachers should be visible
      expect(find.text('Sarah Johnson'), findsOneWidget);
      expect(find.text('Michael Chen'), findsNothing);
    });

    testWidgets('should show floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should handle retry button tap', (WidgetTester tester) async {
      when(mockStaffProvider.error).thenReturn('Network error');

      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(mockStaffProvider.loadStaff()).called(1);
    });

    testWidgets('should show staff cards with popup menu', (WidgetTester tester) async {
      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      // Find staff cards
      expect(find.byType(Card), findsAtLeastNWidgets(2));
      expect(find.byType(PopupMenuButton), findsAtLeastNWidgets(2));
    });

    testWidgets('should handle search with email', (WidgetTester tester) async {
      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      // Test email search
      await tester.enterText(find.byType(TextField), 'sarah.johnson');
      await tester.pump();
      expect(find.text('Sarah Johnson'), findsOneWidget);
      expect(find.text('Michael Chen'), findsNothing);
    });

    testWidgets('should show all roles in dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      // Tap dropdown to see available options
      await tester.tap(find.byType(DropdownButton<StaffRole?>));
      await tester.pumpAndSettle();

      // Should show All Roles and individual roles
      expect(find.text('All Roles'), findsWidgets);
      expect(find.text('TEACHER'), findsWidgets);
      expect(find.text('ADMINISTRATOR'), findsWidgets);
    });

    testWidgets('should handle combined search and filter', (WidgetTester tester) async {
      await tester.pumpWidget(buildStaffScreen());
      await tester.pump();

      // First filter by role
      await tester.tap(find.byType(DropdownButton<StaffRole?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TEACHER').last);
      await tester.pumpAndSettle();

      // Then search within filtered results
      await tester.enterText(find.byType(TextField), 'Johnson');
      await tester.pump();

      expect(find.text('Sarah Johnson'), findsOneWidget);
      expect(find.text('Michael Chen'), findsNothing);
    });
  });
}
