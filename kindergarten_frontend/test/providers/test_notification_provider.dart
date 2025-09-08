import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kindergarten_frontend/providers/notification_provider.dart';
import 'package:kindergarten_frontend/models/notification.dart';
import 'package:kindergarten_frontend/services/database_service.dart';

import 'test_notification_provider.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  group('NotificationProvider Tests', () {
    late NotificationProvider notificationProvider;
    late MockDatabaseService mockDatabaseService;
    late List<AppNotification> testNotifications;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      notificationProvider = NotificationProvider();
      
      testNotifications = [
        AppNotification(
          id: 1,
          title: 'Daily Reminder',
          message: 'Check attendance',
          type: NotificationType.reminder,
          createdAt: DateTime(2024, 1, 15, 9, 0),
          isRead: false,
          isActive: true,
        ),
        AppNotification(
          id: 2,
          title: 'Success Notification',
          message: 'Data saved successfully',
          type: NotificationType.success,
          createdAt: DateTime(2024, 1, 15, 10, 0),
          isRead: true,
          isActive: true,
        ),
        AppNotification(
          id: 3,
          title: 'Alert Message',
          message: 'System maintenance scheduled',
          type: NotificationType.alert,
          createdAt: DateTime(2024, 1, 15, 11, 0),
          isRead: false,
          isActive: false, // Dismissed
        ),
      ];
    });

    tearDown(() {
      reset(mockDatabaseService);
    });

    test('should initialize with empty notifications list', () {
      expect(notificationProvider.notifications, isEmpty);
      expect(notificationProvider.isLoading, isFalse);
      expect(notificationProvider.error, isNull);
    });

    test('should load notifications successfully', () async {
      when(mockDatabaseService.getNotifications()).thenAnswer((_) async => testNotifications);

      await notificationProvider.loadNotifications();

      expect(notificationProvider.notifications, equals(testNotifications));
      expect(notificationProvider.isLoading, isFalse);
      expect(notificationProvider.error, isNull);
      verify(mockDatabaseService.getNotifications()).called(1);
    });

    test('should handle loading error', () async {
      const errorMessage = 'Database connection failed';
      when(mockDatabaseService.getNotifications()).thenThrow(Exception(errorMessage));

      await notificationProvider.loadNotifications();

      expect(notificationProvider.notifications, isEmpty);
      expect(notificationProvider.isLoading, isFalse);
      expect(notificationProvider.error, contains(errorMessage));
      verify(mockDatabaseService.getNotifications()).called(1);
    });

    test('should add notification successfully', () async {
      final newNotification = AppNotification(
        title: 'New Notification',
        message: 'This is a new notification.',
        type: NotificationType.info,
        createdAt: DateTime.now(),
      );

      when(mockDatabaseService.insertNotification(any)).thenAnswer((_) async => 4);

      await notificationProvider.addNotification(newNotification);

      expect(notificationProvider.notifications.length, equals(1));
      expect(notificationProvider.notifications.first.id, equals(4));
      expect(notificationProvider.notifications.first.title, equals('New Notification'));
      expect(notificationProvider.isLoading, isFalse);
      expect(notificationProvider.error, isNull);
      verify(mockDatabaseService.insertNotification(any)).called(1);
    });

    test('should mark notification as read successfully', () async {
      when(mockDatabaseService.getNotifications()).thenAnswer((_) async => testNotifications);
      await notificationProvider.loadNotifications();

      when(mockDatabaseService.updateNotification(any)).thenAnswer((_) async => 1);

      await notificationProvider.markAsRead(1);

      final updatedNotification = notificationProvider.notifications.firstWhere((n) => n.id == 1);
      expect(updatedNotification.isRead, isTrue);
      verify(mockDatabaseService.updateNotification(any)).called(1);
    });

    test('should dismiss notification successfully', () async {
      when(mockDatabaseService.getNotifications()).thenAnswer((_) async => testNotifications);
      await notificationProvider.loadNotifications();

      when(mockDatabaseService.updateNotification(any)).thenAnswer((_) async => 1);

      await notificationProvider.dismissNotification(1);

      expect(notificationProvider.notifications.length, equals(2));
      expect(notificationProvider.notifications.every((n) => n.id != 1), isTrue);
      verify(mockDatabaseService.updateNotification(any)).called(1);
    });

    test('should get unread notifications correctly', () async {
      when(mockDatabaseService.getNotifications()).thenAnswer((_) async => testNotifications);
      await notificationProvider.loadNotifications();

      final unreadNotifications = notificationProvider.unreadNotifications;

      expect(unreadNotifications.length, equals(1));
      expect(unreadNotifications.first.id, equals(1));
      expect(unreadNotifications.every((n) => !n.isRead && n.isActive), isTrue);
    });

    test('should get notifications by type correctly', () async {
      when(mockDatabaseService.getNotifications()).thenAnswer((_) async => testNotifications);
      await notificationProvider.loadNotifications();

      final reminderNotifications = notificationProvider.getNotificationsByType(NotificationType.reminder);
      final successNotifications = notificationProvider.getNotificationsByType(NotificationType.success);
      final alertNotifications = notificationProvider.getNotificationsByType(NotificationType.alert);

      expect(reminderNotifications.length, equals(1));
      expect(successNotifications.length, equals(1));
      expect(alertNotifications.length, equals(0)); // Alert is inactive
    });

    test('should get correct unread count', () async {
      when(mockDatabaseService.getNotifications()).thenAnswer((_) async => testNotifications);
      await notificationProvider.loadNotifications();

      expect(notificationProvider.unreadCount, equals(1));
    });

    test('should handle mark as read error', () async {
      when(mockDatabaseService.getNotifications()).thenAnswer((_) async => testNotifications);
      await notificationProvider.loadNotifications();

      const errorMessage = 'Update failed';
      when(mockDatabaseService.updateNotification(any)).thenThrow(Exception(errorMessage));

      await notificationProvider.markAsRead(1);

      expect(notificationProvider.error, contains(errorMessage));
      final notification = notificationProvider.notifications.firstWhere((n) => n.id == 1);
      expect(notification.isRead, isFalse);
    });

    test('should handle dismiss notification error', () async {
      when(mockDatabaseService.getNotifications()).thenAnswer((_) async => testNotifications);
      await notificationProvider.loadNotifications();

      const errorMessage = 'Dismiss failed';
      when(mockDatabaseService.updateNotification(any)).thenThrow(Exception(errorMessage));

      await notificationProvider.dismissNotification(1);

      expect(notificationProvider.error, contains(errorMessage));
      expect(notificationProvider.notifications.length, equals(3)); // Unchanged
    });

    test('should clear error', () async {
      const errorMessage = 'Test error';
      when(mockDatabaseService.getNotifications()).thenThrow(Exception(errorMessage));
      await notificationProvider.loadNotifications();

      expect(notificationProvider.error, isNotNull);

      notificationProvider.clearError();

      expect(notificationProvider.error, isNull);
    });

    test('should notify listeners during operations', () async {
      var notificationCount = 0;
      notificationProvider.addListener(() {
        notificationCount++;
      });

      when(mockDatabaseService.getNotifications()).thenAnswer((_) async => testNotifications);

      await notificationProvider.loadNotifications();

      expect(notificationCount, greaterThanOrEqualTo(2));
    });
  });
}
