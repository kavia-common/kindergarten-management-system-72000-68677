import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kindergarten_frontend/screens/students_screen.dart';
import 'package:kindergarten_frontend/providers/student_provider.dart';
import 'package:kindergarten_frontend/models/student.dart';

import 'test_students_screen.mocks.dart';

@GenerateMocks([StudentProvider])
void main() {
  group('StudentsScreen Tests', () {
    late MockStudentProvider mockStudentProvider;
    late List<Student> testStudents;

    setUp(() {
      mockStudentProvider = MockStudentProvider();
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

      when(mockStudentProvider.students).thenReturn(testStudents);
      when(mockStudentProvider.isLoading).thenReturn(false);
      when(mockStudentProvider.error).thenReturn(null);
      when(mockStudentProvider.loadStudents()).thenAnswer((_) async {});
      when(mockStudentProvider.deleteStudent(any)).thenAnswer((_) async {});
    });

    Widget buildStudentsScreen() {
      return MaterialApp(
        home: ChangeNotifierProvider<StudentProvider>.value(
          value: mockStudentProvider,
          child: const StudentsScreen(),
        ),
      );
    }

    testWidgets('should display app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      expect(find.text('Students'), findsOneWidget);
    });

    testWidgets('should display search field and class filter', (WidgetTester tester) async {
      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search students...'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('should display students list', (WidgetTester tester) async {
      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Class: Rainbow Class'), findsOneWidget);
      expect(find.text('Class: Sunshine Class'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      when(mockStudentProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when error occurs', (WidgetTester tester) async {
      when(mockStudentProvider.error).thenReturn('Failed to load students');

      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      expect(find.text('Error: Failed to load students'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show empty state when no students', (WidgetTester tester) async {
      when(mockStudentProvider.students).thenReturn([]);

      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      expect(find.text('No students found'), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('should filter students by search query', (WidgetTester tester) async {
      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      // Initially both students should be visible
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump();

      // Only John should be visible after filtering
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsNothing);
    });

    testWidgets('should filter students by class', (WidgetTester tester) async {
      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      // Tap dropdown to open class filter
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select specific class
      await tester.tap(find.text('Rainbow Class').last);
      await tester.pumpAndSettle();

      // Only students from Rainbow Class should be visible
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsNothing);
    });

    testWidgets('should show floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should handle retry button tap', (WidgetTester tester) async {
      when(mockStudentProvider.error).thenReturn('Network error');

      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(mockStudentProvider.loadStudents()).called(1);
    });

    testWidgets('should show student cards with popup menu', (WidgetTester tester) async {
      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      // Find student cards
      expect(find.byType(Card), findsAtLeastNWidgets(2));
      expect(find.byType(PopupMenuButton), findsAtLeastNWidgets(2));
    });

    testWidgets('should handle search with different queries', (WidgetTester tester) async {
      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      // Test class search
      await tester.enterText(find.byType(TextField), 'Rainbow');
      await tester.pump();
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsNothing);

      // Clear and test name search
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Smith');
      await tester.pump();
      expect(find.text('John Doe'), findsNothing);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('should update class filter options based on students', (WidgetTester tester) async {
      await tester.pumpWidget(buildStudentsScreen());
      await tester.pump();

      // Tap dropdown to see available options
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Should show All and the unique classes
      expect(find.text('All'), findsWidgets);
      expect(find.text('Rainbow Class'), findsWidgets);
      expect(find.text('Sunshine Class'), findsWidgets);
    });
  });
}
