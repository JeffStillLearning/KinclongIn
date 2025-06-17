import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'customer' or 'admin'
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type.toString().split('.').last,
    };
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      chatRoomId: data['chatRoomId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? 'customer',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == (data['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get timeOnly {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatRoom {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String lastMessage;
  final String lastMessageSender;
  final int unreadCount;
  final bool isActive;

  ChatRoom({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.createdAt,
    required this.lastMessageAt,
    required this.lastMessage,
    required this.lastMessageSender,
    this.unreadCount = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'unreadCount': unreadCount,
      'isActive': isActive,
    };
  }

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageSender: data['lastMessageSender'] ?? '',
      unreadCount: data['unreadCount'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  String get formattedLastMessageTime {
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt);

    if (difference.inDays > 0) {
      return '${lastMessageAt.day}/${lastMessageAt.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  ChatRoom copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessage,
    String? lastMessageSender,
    int? unreadCount,
    bool? isActive,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
    );
  }
}

enum MessageType {
  text,
  image,
  system,
}
