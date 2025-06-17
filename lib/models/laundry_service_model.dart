import 'package:cloud_firestore/cloud_firestore.dart';

class LaundryServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? promoPrice;
  final String? promoDescription;
  final bool isPromoActive;
  final String category;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  LaundryServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.promoPrice,
    this.promoDescription,
    required this.isPromoActive,
    required this.category,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  double get finalPrice => isPromoActive && promoPrice != null ? promoPrice! : price;
  bool get hasPromo => isPromoActive && promoPrice != null;
  double get discountPercentage => hasPromo ? ((price - promoPrice!) / price * 100) : 0;

  // Factory method untuk membuat dari Firestore
  static LaundryServiceModel fromFirestore(Map<String, dynamic> data, String id) {
    return LaundryServiceModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      promoPrice: data['promoPrice']?.toDouble(),
      promoDescription: data['promoDescription'],
      isPromoActive: data['isPromoActive'] ?? false,
      category: data['category'] ?? 'General',
      imageUrl: data['imageUrl'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'promoPrice': promoPrice,
      'promoDescription': promoDescription,
      'isPromoActive': isPromoActive,
      'category': category,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method untuk update
  LaundryServiceModel copyWith({
    String? name,
    String? description,
    double? price,
    double? promoPrice,
    String? promoDescription,
    bool? isPromoActive,
    String? category,
    String? imageUrl,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return LaundryServiceModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      promoPrice: promoPrice ?? this.promoPrice,
      promoDescription: promoDescription ?? this.promoDescription,
      isPromoActive: isPromoActive ?? this.isPromoActive,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// Enum untuk kategori service
enum ServiceCategory {
  shoes('Shoes', 'Shoe cleaning services'),
  bags('Bags', 'Bag cleaning services'),
  repair('Repair', 'Repair and maintenance services'),
  others('Others', 'Other services');

  const ServiceCategory(this.displayName, this.description);
  final String displayName;
  final String description;
}
