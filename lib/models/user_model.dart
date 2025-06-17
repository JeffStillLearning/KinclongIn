import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String? phoneNumber;
  final String? profileImageUrl;
  final List<UserAddress> addresses;
  final UserPreferences preferences;
  final int totalOrders;
  final double totalSpent;
  final DateTime memberSince;
  final DateTime? lastOrderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.username,
    this.phoneNumber,
    this.profileImageUrl,
    required this.addresses,
    required this.preferences,
    required this.totalOrders,
    required this.totalSpent,
    required this.memberSince,
    this.lastOrderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  String get firstName {
    final safeName = username.isNotEmpty ? username : 'User';
    return safeName.split(' ').first;
  }

  String get fullName {
    return username.isNotEmpty ? username : 'User'; // Full name is now based on username with fallback
  }

  String get initials {
    final safeName = username.isNotEmpty ? username : 'User';
    List<String> names = safeName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else {
      return safeName.length >= 2 ? safeName.substring(0, 2).toUpperCase() : safeName.toUpperCase();
    }
  }

  UserAddress? get defaultAddress {
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  String get memberSinceFormatted {
    // Use createdAt as the actual account creation date
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get updatedAtFormatted {
    return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
  }

  // Factory method untuk membuat dari Firestore
  static UserModel fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Unknown User',
      username: (data['username'] ?? data['displayName'] ?? 'User').toString(), // Ensure string and fallback
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      addresses: (data['addresses'] as List<dynamic>?)
          ?.map((addr) => UserAddress.fromMap(addr as Map<String, dynamic>))
          .toList() ?? [],
      preferences: UserPreferences.fromMap(data['preferences'] as Map<String, dynamic>? ?? {}),
      totalOrders: data['totalOrders'] ?? 0,
      totalSpent: (data['totalSpent'] ?? 0).toDouble(),
      memberSince: (data['memberSince'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastOrderDate: (data['lastOrderDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'addresses': addresses.map((addr) => addr.toMap()).toList(),
      'preferences': preferences.toMap(),
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'memberSince': Timestamp.fromDate(memberSince),
      'lastOrderDate': lastOrderDate != null ? Timestamp.fromDate(lastOrderDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class UserAddress {
  final String id;
  final String label;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.label,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  static UserAddress fromMap(Map<String, dynamic> data) {
    return UserAddress(
      id: data['id'] ?? '',
      label: data['label'] ?? 'Home',
      address: data['address'] ?? '',
      latitude: data['coordinates']?['latitude']?.toDouble(),
      longitude: data['coordinates']?['longitude']?.toDouble(),
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'isDefault': isDefault,
    };
  }
}

class UserPreferences {
  final String defaultServiceType;
  final String defaultPaymentMethod;
  final bool notifications;

  UserPreferences({
    required this.defaultServiceType,
    required this.defaultPaymentMethod,
    required this.notifications,
  });

  static UserPreferences fromMap(Map<String, dynamic> data) {
    return UserPreferences(
      defaultServiceType: data['defaultServiceType'] ?? 'Self Service',
      defaultPaymentMethod: data['defaultPaymentMethod'] ?? 'QRIS',
      notifications: data['notifications'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultServiceType': defaultServiceType,
      'defaultPaymentMethod': defaultPaymentMethod,
      'notifications': notifications,
    };
  }
}