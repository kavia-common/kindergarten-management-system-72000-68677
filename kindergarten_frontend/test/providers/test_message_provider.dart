import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kindergarten_frontend/providers/message_provider.dart';
import 'package:kindergarten_frontend/models/message.dart';
import 'package:kindergarten_frontend/services/database_service.dart';

import 'test_message_provider.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  group('MessageProvider Tests', () {
    late MessageProvider messageProvider;
    late MockDatabaseService mockDatabaseService;
    late List<Message> testMessages;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      messageProvider = MessageProvider();
      
      testMessages = [
        Message(
          id: 1,
          title: 'Welcome Message',
          content: 'Welcome to kindergarten!',
          type: MessageType.announcement,
          senderId: 1,
          recipientId: null, // Broadcast
          createdAt: DateTime(2024, 1, 15, 10, 0),
          isRead: false,
          isImportant: true,
        ),
        Message(
          id: 2,
          title: 'Personal Note',
          content: 'Your child did great today!',
          type: MessageType.personal,
          senderId: 1,
          recipientId: 1,
          createdAt: DateTime(2024, 1, 15, 11, 0),
          isRead: true,
          isImportant: false,
        ),
        Message(
          id: 3,
          title: 'Urgent Notice',
          content: 'Please pick up early today.',
          type: MessageType.urgent,
          senderId: 1,
          recipientId: 2,
          createdAt: DateTime(2024, 1, 15, 12, 0),
          isRead: false,
          isImportant: true,
        ),
      ];
    });

    tearDown(() {
      reset(mockDatabaseService);
    });

    test('should initialize with empty messages list', () {
      expect(messageProvider.messages, isEmpty);
      expect(messageProvider.isLoading, isFalse);
      expect(messageProvider.error, isNull);
    });

    test('should load messages successfully', () async {
      when(mockDatabaseService.getMessages()).thenAnswer((_) async => testMessages);

      await messageProvider.loadMessages();

      expect(messageProvider.messages, equals(testMessages));
      expect(messageProvider.isLoading, isFalse);
      expect(messageProvider.error, isNull);
      verify(mockDatabaseService.getMessages()).called(1);
    });

    test('should handle loading error', () async {
      const errorMessage = 'Database connection failed';
      when(mockDatabaseService.getMessages()).thenThrow(Exception(errorMessage));

      await messageProvider.loadMessages();

      expect(messageProvider.messages, isEmpty);
      expect(messageProvider.isLoading, isFalse);
      expect(messageProvider.error, contains(errorMessage));
      verify(mockDatabaseService.getMessages()).called(1);
    });

    test('should send message successfully', () async {
      final newMessage = Message(
        title: 'New Message',
        content: 'This is a new message.',
        type: MessageType.personal,
        senderId: 1,
        recipientId: 3,
        createdAt: DateTime.now(),
      );

      when(mockDatabaseService.insertMessage(any)).thenAnswer((_) async => 4);

      await messageProvider.sendMessage(newMessage);

      expect(messageProvider.messages.length, equals(1));
      expect(messageProvider.messages.first.id, equals(4));
      expect(messageProvider.messages.first.title, equals('New Message'));
      expect(messageProvider.isLoading, isFalse);
      expect(messageProvider.error, isNull);
      verify(mockDatabaseService.insertMessage(any)).called(1);
    });

    test('should mark message as read successfully', () async {
      when(mockDatabaseService.getMessages()).thenAnswer((_) async => testMessages);
      await messageProvider.loadMessages();

      when(mockDatabaseService.updateMessage(any)).thenAnswer((_) async => 1);

      await messageProvider.markAsRead(1);

      final updatedMessage = messageProvider.messages.firstWhere((m) => m.id == 1);
      expect(updatedMessage.isRead, isTrue);
      verify(mockDatabaseService.updateMessage(any)).called(1);
    });

    test('should get unread messages correctly', () async {
      when(mockDatabaseService.getMessages()).thenAnswer((_) async => testMessages);
      await messageProvider.loadMessages();

      final unreadMessages = messageProvider.unreadMessages;

      expect(unreadMessages.length, equals(2));
      expect(unreadMessages.every((m) => !m.isRead), isTrue);
    });

    test('should get important messages correctly', () async {
      when(mockDatabaseService.getMessages()).thenAnswer((_) async => testMessages);
      await messageProvider.loadMessages();

      final importantMessages = messageProvider.importantMessages;

      expect(importantMessages.length, equals(2));
      expect(importantMessages.every((m) => m.isImportant), isTrue);
    });

    test('should get messages by type correctly', () async {
      when(mockDatabaseService.getMessages()).thenAnswer((_) async => testMessages);
      await messageProvider.loadMessages();

      final announcementMessages = messageProvider.getMessagesByType(MessageType.announcement);
      final personalMessages = messageProvider.getMessagesByType(MessageType.personal);
      final urgentMessages = messageProvider.getMessagesByType(MessageType.urgent);

      expect(announcementMessages.length, equals(1));
      expect(personalMessages.length, equals(1));
      expect(urgentMessages.length, equals(1));
    });

    test('should get correct unread count', () async {
      when(mockDatabaseService.getMessages()).thenAnswer((_) async => testMessages);
      await messageProvider.loadMessages();

      expect(messageProvider.unreadCount, equals(2));
    });

    test('should handle mark as read error', () async {
      when(mockDatabaseService.getMessages()).thenAnswer((_) async => testMessages);
      await messageProvider.loadMessages();

      const errorMessage = 'Update failed';
      when(mockDatabaseService.updateMessage(any)).thenThrow(Exception(errorMessage));

      await messageProvider.markAsRead(1);

      expect(messageProvider.error, contains(errorMessage));
      // Message should remain unchanged on error
      final message = messageProvider.messages.firstWhere((m) => m.id == 1);
      expect(message.isRead, isFalse);
    });

    test('should clear error', () async {
      const errorMessage = 'Test error';
      when(mockDatabaseService.getMessages()).thenThrow(Exception(errorMessage));
      await messageProvider.loadMessages();

      expect(messageProvider.error, isNotNull);

      messageProvider.clearError();

      expect(messageProvider.error, isNull);
    });

    test('should notify listeners during operations', () async {
      var notificationCount = 0;
      messageProvider.addListener(() {
        notificationCount++;
      });

      when(mockDatabaseService.getMessages()).thenAnswer((_) async => testMessages);

      await messageProvider.loadMessages();

      expect(notificationCount, greaterThanOrEqualTo(2));
    });
  });
}
