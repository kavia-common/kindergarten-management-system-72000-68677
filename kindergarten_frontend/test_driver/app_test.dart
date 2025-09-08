import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Kindergarten App Integration Tests', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('should load splash screen and navigate to main app', () async {
      // Wait for splash screen
      await driver.waitFor(find.text('Kindergarten Management'));
      await driver.waitFor(find.text('Loading...'));

      // Wait for navigation to main screen
      await Future.delayed(const Duration(seconds: 4));
      
      // Should now be on main navigation
      await driver.waitFor(find.text('Dashboard'));
    });

    test('should navigate between tabs', () async {
      // Navigate to Students tab
      await driver.tap(find.text('Students'));
      await driver.waitFor(find.text('Students'));

      // Navigate to Staff tab
      await driver.tap(find.text('Staff'));
      await driver.waitFor(find.text('Staff'));

      // Navigate back to Dashboard
      await driver.tap(find.text('Dashboard'));
      await driver.waitFor(find.text('Welcome back!'));
    });
  });
}
