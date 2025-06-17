import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String orderId;
  final String userId;
  final String userName;
  final String serviceName;
  final int rating; // 1-5 stars
  final String review;
  final DateTime createdAt;
  final DateTime updatedAt;

  RatingModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.serviceName,
    required this.rating,
    required this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'serviceName': serviceName,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore Document
  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      serviceName: data['serviceName'] ?? '',
      rating: data['rating'] ?? 0,
      review: data['review'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create copy with updated fields
  RatingModel copyWith({
    String? id,
    String? orderId,
    String? userId,
    String? userName,
    String? serviceName,
    int? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RatingModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      serviceName: serviceName ?? this.serviceName,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get formatted date
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // Get star display
  String get starDisplay {
    return '★' * rating + '☆' * (5 - rating);
  }
}
