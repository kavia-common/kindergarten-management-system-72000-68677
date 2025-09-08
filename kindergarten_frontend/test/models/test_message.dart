import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/models/message.dart';

void main() {
  group('Message Model Tests', () {
    late Message testMessage;
    late Map<String, dynamic> testMessageMap;
    late DateTime testCreatedAt;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 15, 10, 30);

      testMessage = Message(
        id: 1,
        title: 'Welcome to Kindergarten!',
        content: 'We are excited to have your child join our kindergarten family.',
        type: MessageType.announcement,
        senderId: 2,
        recipientId: 1,
        createdAt: testCreatedAt,
        isRead: false,
        isImportant: true,
      );

      testMessageMap = {
        'id': 1,
        'title': 'Welcome to Kindergarten!',
        'content': 'We are excited to have your child join our kindergarten family.',
        'type': 'announcement',
        'senderId': 2,
        'recipientId': 1,
        'createdAt': testCreatedAt.millisecondsSinceEpoch,
        'isRead': 0,
        'isImportant': 1,
      };
    });

    test('should create a Message instance with all properties', () {
      expect(testMessage.id, equals(1));
      expect(testMessage.title, equals('Welcome to Kindergarten!'));
      expect(testMessage.content, equals('We are excited to have your child join our kindergarten family.'));
      expect(testMessage.type, equals(MessageType.announcement));
      expect(testMessage.senderId, equals(2));
      expect(testMessage.recipientId, equals(1));
      expect(testMessage.createdAt, equals(testCreatedAt));
      expect(testMessage.isRead, isFalse);
      expect(testMessage.isImportant, isTrue);
    });

    test('should return correct type display name', () {
      expect(testMessage.typeDisplayName, equals('ANNOUNCEMENT'));
      
      final personalMessage = testMessage.copyWith(type: MessageType.personal);
      expect(personalMessage.typeDisplayName, equals('PERSONAL'));
      
      final urgentMessage = testMessage.copyWith(type: MessageType.urgent);
      expect(urgentMessage.typeDisplayName, equals('URGENT'));
      
      final eventMessage = testMessage.copyWith(type: MessageType.event);
      expect(eventMessage.typeDisplayName, equals('EVENT'));
    });

    test('should identify broadcast messages correctly', () {
      expect(testMessage.isBroadcast, isFalse);
      
      final broadcastMessage = testMessage.copyWith(recipientId: null);
      expect(broadcastMessage.isBroadcast, isTrue);
    });

    test('should convert to map correctly', () {
      final map = testMessage.toMap();
      expect(map['id'], equals(1));
      expect(map['title'], equals('Welcome to Kindergarten!'));
      expect(map['type'], equals('announcement'));
      expect(map['senderId'], equals(2));
      expect(map['recipientId'], equals(1));
      expect(map['isRead'], equals(0));
      expect(map['isImportant'], equals(1));
      expect(map['createdAt'], equals(testCreatedAt.millisecondsSinceEpoch));
    });

    test('should create Message from map correctly', () {
      final message = Message.fromMap(testMessageMap);
      expect(message.id, equals(1));
      expect(message.title, equals('Welcome to Kindergarten!'));
      expect(message.type, equals(MessageType.announcement));
      expect(message.typeDisplayName, equals('ANNOUNCEMENT'));
      expect(message.senderId, equals(2));
      expect(message.recipientId, equals(1));
      expect(message.isRead, isFalse);
      expect(message.isImportant, isTrue);
      expect(message.isBroadcast, isFalse);
    });

    test('should handle different message types correctly', () {
      for (final type in MessageType.values) {
        final typeMap = {
          'title': 'Test Message',
          'content': 'Test content',
          'type': type.toString().split('.').last,
          'senderId': 1,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'isRead': 0,
          'isImportant': 0,
        };

        final message = Message.fromMap(typeMap);
        expect(message.type, equals(type));
        expect(message.typeDisplayName, equals(type.toString().split('.').last.toUpperCase()));
      }
    });

    test('should handle unknown type correctly', () {
      final unknownTypeMap = {
        'title': 'Test Message',
        'content': 'Test content',
        'type': 'unknown_type',
        'senderId': 1,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'isRead': 0,
        'isImportant': 0,
      };

      final message = Message.fromMap(unknownTypeMap);
      expect(message.type, equals(MessageType.personal));
    });

    test('should handle broadcast message correctly', () {
      final broadcastMap = {
        'title': 'School Announcement',
        'content': 'School will be closed tomorrow.',
        'type': 'announcement',
        'senderId': 1,
        'recipientId': null,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'isRead': 0,
        'isImportant': 1,
      };

      final message = Message.fromMap(broadcastMap);
      expect(message.recipientId, isNull);
      expect(message.isBroadcast, isTrue);
    });

    test('should copy with new values correctly', () {
      final updatedMessage = testMessage.copyWith(
        title: 'Updated Title',
        isRead: true,
        isImportant: false,
        type: MessageType.personal,
      );

      expect(updatedMessage.title, equals('Updated Title'));
      expect(updatedMessage.isRead, isTrue);
      expect(updatedMessage.isImportant, isFalse);
      expect(updatedMessage.type, equals(MessageType.personal));
      expect(updatedMessage.typeDisplayName, equals('PERSONAL'));
      
      // Original values should remain for unchanged fields
      expect(updatedMessage.id, equals(testMessage.id));
      expect(updatedMessage.content, equals(testMessage.content));
      expect(updatedMessage.senderId, equals(testMessage.senderId));
      expect(updatedMessage.recipientId, equals(testMessage.recipientId));
    });

    test('should handle read and unread states correctly', () {
      expect(testMessage.isRead, isFalse);
      
      final readMessage = testMessage.copyWith(isRead: true);
      expect(readMessage.isRead, isTrue);
      
      final readMap = readMessage.toMap();
      expect(readMap['isRead'], equals(1));
    });

    test('should handle important and non-important states correctly', () {
      expect(testMessage.isImportant, isTrue);
      
      final nonImportantMessage = testMessage.copyWith(isImportant: false);
      expect(nonImportantMessage.isImportant, isFalse);
      
      final nonImportantMap = nonImportantMessage.toMap();
      expect(nonImportantMap['isImportant'], equals(0));
    });

    test('should handle minimum required fields only', () {
      final minimalMessage = Message(
        title: 'Test',
        content: 'Test content',
        type: MessageType.personal,
        senderId: 1,
        createdAt: DateTime.now(),
      );

      expect(minimalMessage.title, equals('Test'));
      expect(minimalMessage.content, equals('Test content'));
      expect(minimalMessage.type, equals(MessageType.personal));
      expect(minimalMessage.senderId, equals(1));
      expect(minimalMessage.isRead, isFalse); // Default value
      expect(minimalMessage.isImportant, isFalse); // Default value
      expect(minimalMessage.id, isNull);
      expect(minimalMessage.recipientId, isNull);
      expect(minimalMessage.isBroadcast, isTrue); // No recipient = broadcast
    });
  });
}
