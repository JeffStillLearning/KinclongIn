import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _currentChatRoomId;

  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentChatRoomId => _currentChatRoomId;

  // Get or create chat room for customer
  Future<String?> getOrCreateChatRoom({
    required String customerId,
    required String customerName,
    required String customerEmail,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if chat room already exists
      final existingRoom = await _firestore
          .collection('chatRooms')
          .where('customerId', isEqualTo: customerId)
          .get();

      if (existingRoom.docs.isNotEmpty) {
        final chatRoomId = existingRoom.docs.first.id;
        _currentChatRoomId = chatRoomId;
        return chatRoomId;
      }

      // Create new chat room
      final now = DateTime.now();
      final chatRoomData = ChatRoom(
        id: '',
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        createdAt: now,
        lastMessageAt: now,
        lastMessage: 'Chat started',
        lastMessageSender: 'system',
        unreadCount: 0,
        isActive: true,
      );

      final docRef = await _firestore
          .collection('chatRooms')
          .add(chatRoomData.toMap());

      _currentChatRoomId = docRef.id;

      // Send welcome message
      await sendMessage(
        chatRoomId: docRef.id,
        senderId: 'system',
        senderName: 'System',
        senderRole: 'system',
        message: 'Halo! Selamat datang di layanan chat Kinclong.In. Admin akan segera membantu Anda.',
        type: MessageType.system,
      );

      return docRef.id;
    } catch (e) {
      _error = e.toString();
      print('Error creating chat room: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message
  Future<bool> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
    MessageType type = MessageType.text,
  }) async {
    try {
      final now = DateTime.now();

      print('Sending message: $message from $senderName ($senderRole) in room $chatRoomId');

      // Add message to messages collection
      final messageData = ChatMessage(
        id: '',
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message,
        timestamp: now,
        isRead: false,
        type: type,
      );

      final docRef = await _firestore
          .collection('messages')
          .add(messageData.toMap());

      print('Message saved with ID: ${docRef.id}');

      // Update chat room with last message
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .update({
        'lastMessage': message,
        'lastMessageSender': senderName,
        'lastMessageAt': Timestamp.fromDate(now),
      });

      print('Chat room updated successfully');
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error sending message: $e');
      return false;
    }
  }

  // Get messages stream for a chat room
  Stream<List<ChatMessage>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('messages')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }

  // Get chat rooms stream for admin with unread count
  Stream<List<ChatRoom>> getChatRoomsStream() {
    return _firestore
        .collection('chatRooms')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<ChatRoom> chatRooms = [];

      for (var doc in snapshot.docs) {
        final chatRoom = ChatRoom.fromFirestore(doc);

        // Get unread count for this chat room
        final unreadSnapshot = await _firestore
            .collection('messages')
            .where('chatRoomId', isEqualTo: chatRoom.id)
            .where('senderRole', isEqualTo: 'customer')
            .where('isRead', isEqualTo: false)
            .get();

        final unreadCount = unreadSnapshot.docs.length;

        // Update chat room with unread count
        final updatedChatRoom = chatRoom.copyWith(unreadCount: unreadCount);
        chatRooms.add(updatedChatRoom);
      }

      return chatRooms;
    });
  }

  // Get customer's chat room
  Future<String?> getCustomerChatRoom(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('chatRooms')
          .where('customerId', isEqualTo: customerId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error getting customer chat room: $e');
      return null;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId, String currentUserId) async {
    try {
      print('Marking messages as read for chat room: $chatRoomId, user: $currentUserId');

      // Get all unread messages in this chat room that are NOT sent by current user
      final snapshot = await _firestore
          .collection('messages')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .where('isRead', isEqualTo: false)
          .get();

      print('Found ${snapshot.docs.length} unread messages');

      final batch = _firestore.batch();
      int updatedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId'] ?? '';
        final senderRole = data['senderRole'] ?? '';

        print('Message from: $senderId ($senderRole), current user: $currentUserId');

        // For admin: mark customer messages as read
        // For customer: mark admin messages as read
        bool shouldMarkAsRead = false;

        if (currentUserId == 'admin') {
          // Admin reading customer messages
          shouldMarkAsRead = (senderRole == 'customer');
        } else {
          // Customer reading admin messages
          shouldMarkAsRead = (senderRole == 'admin');
        }

        if (shouldMarkAsRead) {
          batch.update(doc.reference, {'isRead': true});
          updatedCount++;
          print('Marking message ${doc.id} as read');
        }
      }

      if (updatedCount > 0) {
        await batch.commit();
        print('Successfully marked $updatedCount messages as read in chat room $chatRoomId');
        notifyListeners(); // Notify listeners to update UI
      } else {
        print('No messages to mark as read');
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Get unread messages count
  Future<int> getUnreadMessagesCount(String userId, String userRole) async {
    try {
      if (userRole == 'customer') {
        // For customer, count unread messages from admin in their chat room
        final chatRoomId = await getCustomerChatRoom(userId);
        if (chatRoomId == null) return 0;

        final snapshot = await _firestore
            .collection('messages')
            .where('chatRoomId', isEqualTo: chatRoomId)
            .where('senderRole', isEqualTo: 'admin')
            .where('isRead', isEqualTo: false)
            .get();

        return snapshot.docs.length;
      } else {
        // For admin, count unread messages from all customers
        final snapshot = await _firestore
            .collection('messages')
            .where('senderRole', isEqualTo: 'customer')
            .where('isRead', isEqualTo: false)
            .get();

        return snapshot.docs.length;
      }
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Set current chat room
  void setCurrentChatRoom(String? chatRoomId) {
    _currentChatRoomId = chatRoomId;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // Delete chat room (admin only)
  Future<bool> deleteChatRoom(String chatRoomId) async {
    try {
      // Delete all messages in the chat room
      final messagesSnapshot = await _firestore
          .collection('messages')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat room
      batch.delete(_firestore.collection('chatRooms').doc(chatRoomId));

      await batch.commit();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error deleting chat room: $e');
      return false;
    }
  }
}
