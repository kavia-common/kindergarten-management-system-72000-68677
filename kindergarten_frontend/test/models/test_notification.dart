import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/models/notification.dart';

void main() {
  group('AppNotification Model Tests', () {
    late AppNotification testNotification;
    late Map<String, dynamic> testNotificationMap;
    late DateTime testCreatedAt;
    late DateTime testScheduledFor;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 15, 10, 30);
      testScheduledFor = DateTime(2024, 1, 15, 11, 30);

      testNotification = AppNotification(
        id: 1,
        title: 'Daily Reminder',
        message: 'Remember to check attendance for all students',
        type: NotificationType.reminder,
        createdAt: testCreatedAt,
        scheduledFor: testScheduledFor,
        isRead: false,
        isActive: true,
        data: {'priority': 'high', 'category': 'attendance'},
      );

      testNotificationMap = {
        'id': 1,
        'title': 'Daily Reminder',
        'message': 'Remember to check attendance for all students',
        'type': 'reminder',
        'createdAt': testCreatedAt.millisecondsSinceEpoch,
        'scheduledFor': testScheduledFor.millisecondsSinceEpoch,
        'isRead': 0,
        'isActive': 1,
        'data': '{priority: high, category: attendance}',
      };
    });

    test('should create an AppNotification instance with all properties', () {
      expect(testNotification.id, equals(1));
      expect(testNotification.title, equals('Daily Reminder'));
      expect(testNotification.message, equals('Remember to check attendance for all students'));
      expect(testNotification.type, equals(NotificationType.reminder));
      expect(testNotification.createdAt, equals(testCreatedAt));
      expect(testNotification.scheduledFor, equals(testScheduledFor));
      expect(testNotification.isRead, isFalse);
      expect(testNotification.isActive, isTrue);
      expect(testNotification.data, isNotNull);
    });

    test('should return correct type display name', () {
      expect(testNotification.typeDisplayName, equals('REMINDER'));
      
      final alertNotification = testNotification.copyWith(type: NotificationType.alert);
      expect(alertNotification.typeDisplayName, equals('ALERT'));
      
      final infoNotification = testNotification.copyWith(type: NotificationType.info);
      expect(infoNotification.typeDisplayName, equals('INFO'));
      
      final successNotification = testNotification.copyWith(type: NotificationType.success);
      expect(successNotification.typeDisplayName, equals('SUCCESS'));
      
      final warningNotification = testNotification.copyWith(type: NotificationType.warning);
      expect(warningNotification.typeDisplayName, equals('WARNING'));
    });

    test('should convert to map correctly', () {
      final map = testNotification.toMap();
      expect(map['id'], equals(1));
      expect(map['title'], equals('Daily Reminder'));
      expect(map['message'], equals('Remember to check attendance for all students'));
      expect(map['type'], equals('reminder'));
      expect(map['isRead'], equals(0));
      expect(map['isActive'], equals(1));
      expect(map['createdAt'], equals(testCreatedAt.millisecondsSinceEpoch));
      expect(map['scheduledFor'], equals(testScheduledFor.millisecondsSinceEpoch));
      expect(map['data'], contains('priority'));
    });

    test('should create AppNotification from map correctly', () {
      final notification = AppNotification.fromMap(testNotificationMap);
      expect(notification.id, equals(1));
      expect(notification.title, equals('Daily Reminder'));
      expect(notification.message, equals('Remember to check attendance for all students'));
      expect(notification.type, equals(NotificationType.reminder));
      expect(notification.typeDisplayName, equals('REMINDER'));
      expect(notification.createdAt, equals(testCreatedAt));
      expect(notification.scheduledFor, equals(testScheduledFor));
      expect(notification.isRead, isFalse);
      expect(notification.isActive, isTrue);
    });

    test('should handle different notification types correctly', () {
      for (final type in NotificationType.values) {
        final typeMap = {
          'title': 'Test Notification',
          'message': 'Test message',
          'type': type.toString().split('.').last,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'isRead': 0,
          'isActive': 1,
        };

        final notification = AppNotification.fromMap(typeMap);
        expect(notification.type, equals(type));
        expect(notification.typeDisplayName, equals(type.toString().split('.').last.toUpperCase()));
      }
    });

    test('should handle unknown type correctly', () {
      final unknownTypeMap = {
        'title': 'Test Notification',
        'message': 'Test message',
        'type': 'unknown_type',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'isRead': 0,
        'isActive': 1,
      };

      final notification = AppNotification.fromMap(unknownTypeMap);
      expect(notification.type, equals(NotificationType.info));
    });

    test('should handle null optional fields correctly', () {
      final minimalMap = {
        'title': 'Test Notification',
        'message': 'Test message',
        'type': 'info',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'isRead': 0,
        'isActive': 1,
      };

      final notification = AppNotification.fromMap(minimalMap);
      expect(notification.scheduledFor, isNull);
      expect(notification.data, isNull);
    });

    test('should copy with new values correctly', () {
      final updatedNotification = testNotification.copyWith(
        title: 'Updated Reminder',
        isRead: true,
        isActive: false,
        type: NotificationType.alert,
      );

      expect(updatedNotification.title, equals('Updated Reminder'));
      expect(updatedNotification.isRead, isTrue);
      expect(updatedNotification.isActive, isFalse);
      expect(updatedNotification.type, equals(NotificationType.alert));
      expect(updatedNotification.typeDisplayName, equals('ALERT'));
      
      // Original values should remain for unchanged fields
      expect(updatedNotification.id, equals(testNotification.id));
      expect(updatedNotification.message, equals(testNotification.message));
      expect(updatedNotification.createdAt, equals(testNotification.createdAt));
      expect(updatedNotification.scheduledFor, equals(testNotification.scheduledFor));
    });

    test('should handle read and unread states correctly', () {
      expect(testNotification.isRead, isFalse);
      
      final readNotification = testNotification.copyWith(isRead: true);
      expect(readNotification.isRead, isTrue);
      
      final readMap = readNotification.toMap();
      expect(readMap['isRead'], equals(1));
    });

    test('should handle active and inactive states correctly', () {
      expect(testNotification.isActive, isTrue);
      
      final inactiveNotification = testNotification.copyWith(isActive: false);
      expect(inactiveNotification.isActive, isFalse);
      
      final inactiveMap = inactiveNotification.toMap();
      expect(inactiveMap['isActive'], equals(0));
    });

    test('should handle scheduled notifications correctly', () {
      expect(testNotification.scheduledFor, equals(testScheduledFor));
      
      final immediateNotification = testNotification.copyWith(scheduledFor: null);
      expect(immediateNotification.scheduledFor, isNull);
      
      final map = immediateNotification.toMap();
      expect(map['scheduledFor'], isNull);
    });

    test('should handle data field correctly', () {
      expect(testNotification.data, isNotNull);
      expect(testNotification.data!['priority'], equals('high'));
      
      final noDataNotification = testNotification.copyWith(data: null);
      expect(noDataNotification.data, isNull);
      
      final map = noDataNotification.toMap();
      expect(map['data'], isNull);
    });

    test('should handle minimum required fields only', () {
      final minimalNotification = AppNotification(
        title: 'Test',
        message: 'Test message',
        type: NotificationType.info,
        createdAt: DateTime.now(),
      );

      expect(minimalNotification.title, equals('Test'));
      expect(minimalNotification.message, equals('Test message'));
      expect(minimalNotification.type, equals(NotificationType.info));
      expect(minimalNotification.isRead, isFalse); // Default value
      expect(minimalNotification.isActive, isTrue); // Default value
      expect(minimalNotification.id, isNull);
      expect(minimalNotification.scheduledFor, isNull);
      expect(minimalNotification.data, isNull);
    });
  });
}
