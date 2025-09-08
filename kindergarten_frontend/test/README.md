# Kindergarten Frontend Test Suite

This directory contains comprehensive tests for the Kindergarten Management Flutter application.

## Test Structure

### Models Tests (`test/models/`)
- `test_student.dart` - Student model serialization, validation, and business logic
- `test_staff.dart` - Staff model with role handling and validation
- `test_attendance.dart` - Attendance model with status and time tracking
- `test_schedule.dart` - Schedule model with time formatting and validation
- `test_message.dart` - Message model with types and broadcast functionality
- `test_notification.dart` - Notification model with scheduling and state management

### Provider Tests (`test/providers/`)
- `test_student_provider.dart` - Student state management with mocked database
- `test_staff_provider.dart` - Staff CRUD operations and filtering
- `test_attendance_provider.dart` - Attendance tracking with statistics
- `test_schedule_provider.dart` - Schedule management with class/day filtering
- `test_message_provider.dart` - Messaging with read status and type filtering
- `test_notification_provider.dart` - Notification management with dismissal

### Widget Tests (`test/widgets/`)
- `test_dashboard_card.dart` - Dashboard summary cards display and styling
- `test_quick_action_card.dart` - Quick action cards interaction and taps
- `test_recent_activity_card.dart` - Recent activity display with read/unread states
- `test_student_card.dart` - Student information cards with expansion and actions
- `test_staff_card.dart` - Staff information cards with role colors and actions

### Screen Tests (`test/screens/`)
- `test_dashboard_screen.dart` - Dashboard layout, stats, and quick actions
- `test_students_screen.dart` - Student list, search, filtering, and CRUD operations
- `test_staff_screen.dart` - Staff list, search, role filtering, and management
- `test_splash_screen.dart` - App initialization and provider data loading

### Service Tests (`test/services/`)
- `test_database_service.dart` - Database CRUD operations, initialization, and error handling

### Integration Tests (`test/integration/`)
- `test_app_integration.dart` - Full app flow, navigation, and user interactions

## Running Tests

### All Tests
```bash
flutter test
```

### Specific Test File
```bash
flutter test test/models/test_student.dart
```

### With Coverage
```bash
flutter test --coverage
```

### Generate Mock Files
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Test Features

### Comprehensive Coverage
- **Unit Tests**: All models and providers with full CRUD operations
- **Widget Tests**: UI components with interaction testing
- **Integration Tests**: Complete app flow and navigation
- **Mock Testing**: Database service mocking for isolated provider tests

### Testing Best Practices
- **Mocking**: Using Mockito for database and provider dependencies
- **Isolation**: Each test is independent with proper setup/teardown
- **Error Handling**: Tests cover both success and failure scenarios
- **Edge Cases**: Null values, empty data, and boundary conditions
- **Async Operations**: Proper testing of async provider methods

### Provider Lifecycle Management
- **Disposal Safety**: Providers check disposal state before notifying listeners
- **Build Safety**: Notifications are deferred using `addPostFrameCallback`
- **Memory Management**: Proper cleanup to prevent memory leaks

## Dependencies

### Testing Dependencies
- `flutter_test` - Flutter testing framework
- `mockito` - Mock generation for dependencies
- `build_runner` - Code generation for mocks
- `sqflite_common_ffi` - SQLite testing support
- `integration_test` - Integration testing framework

### Mock Files
Mock files are auto-generated in `*.mocks.dart` files using the `@GenerateMocks` annotation.

## Notes

- Tests use in-memory SQLite database for isolation
- Provider notifications are safely deferred to avoid build-time issues
- All tests follow Flutter testing best practices
- Error scenarios are thoroughly tested alongside success paths
