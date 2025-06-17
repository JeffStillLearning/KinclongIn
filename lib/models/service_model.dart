import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isActive;
  final bool hasPromotion;
  final double promotionDiscount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isActive,
    required this.hasPromotion,
    required this.promotionDiscount,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor untuk membuat ServiceModel dari Firestore document
  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      isActive: data['isActive'] ?? true,
      hasPromotion: data['hasPromotion'] ?? false,
      promotionDiscount: (data['promotionDiscount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Factory constructor untuk membuat ServiceModel dari Map
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      isActive: map['isActive'] ?? true,
      hasPromotion: map['hasPromotion'] ?? false,
      promotionDiscount: (map['promotionDiscount'] ?? 0).toDouble(),
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert ServiceModel ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'isActive': isActive,
      'hasPromotion': hasPromotion,
      'promotionDiscount': promotionDiscount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Convert ServiceModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'isActive': isActive,
      'hasPromotion': hasPromotion,
      'promotionDiscount': promotionDiscount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // CopyWith method untuk membuat copy dengan perubahan
  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    bool? isActive,
    bool? hasPromotion,
    double? promotionDiscount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      hasPromotion: hasPromotion ?? this.hasPromotion,
      promotionDiscount: promotionDiscount ?? this.promotionDiscount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getter untuk harga setelah diskon
  double get discountedPrice {
    if (hasPromotion && promotionDiscount > 0) {
      return price * (1 - promotionDiscount / 100);
    }
    return price;
  }

  // Getter untuk status text
  String get statusText {
    return isActive ? 'Active' : 'Inactive';
  }

  // Getter untuk formatted price
  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  // Getter untuk formatted discounted price
  String get formattedDiscountedPrice {
    return 'Rp ${discountedPrice.toStringAsFixed(0)}';
  }

  @override
  String toString() {
    return 'ServiceModel(id: $id, name: $name, price: $price, category: $category, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ServiceModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.category == category &&
        other.isActive == isActive &&
        other.hasPromotion == hasPromotion &&
        other.promotionDiscount == promotionDiscount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        price.hashCode ^
        category.hashCode ^
        isActive.hashCode ^
        hasPromotion.hashCode ^
        promotionDiscount.hashCode;
  }
}
