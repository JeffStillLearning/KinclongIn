import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { process, delivering, done }

class OrderModel {
  final String id;
  final String customerName;
  final String? customerEmail;
  final List<String> items;
  final double totalPrice;
  final DateTime orderDate;
  final OrderStatus status;
  final String? deliveryAddress;
  final String serviceType; // "Self Service" or "Delivery Service"
  final String paymentMethod;
  final String? laundryPhotoUrl; // URL foto laundry dari customer
  final String? paymentProofUrl; // URL bukti pembayaran dari customer

  OrderModel({
    required this.id,
    required this.customerName,
    this.customerEmail,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
    this.deliveryAddress,
    required this.serviceType,
    required this.paymentMethod,
    this.laundryPhotoUrl,
    this.paymentProofUrl,
  });

  // Helper methods
  String get statusText {
    switch (status) {
      case OrderStatus.process:
        return 'Processing';
      case OrderStatus.delivering:
        return 'Delivering';
      case OrderStatus.done:
        return 'Completed';
    }
  }

  String get statusDescription {
    switch (status) {
      case OrderStatus.process:
        return 'Your order is being processed';
      case OrderStatus.delivering:
        return 'Your order is on the way';
      case OrderStatus.done:
        return 'Order completed successfully';
    }
  }

  String get formattedDate {
    return '${orderDate.day}/${orderDate.month}/${orderDate.year}';
  }

  String get formattedTime {
    return '${orderDate.hour.toString().padLeft(2, '0')}:${orderDate.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDateTime {
    return '$formattedDate at $formattedTime';
  }

  String get itemsText {
    if (items.length == 1) {
      return items.first;
    } else if (items.length == 2) {
      return '${items.first} & ${items.last}';
    } else {
      return '${items.first} & ${items.length - 1} more items';
    }
  }

  // Helper method to create OrderModel from Firebase data
  static OrderModel fromFirestore(Map<String, dynamic> data) {
    // Handle Timestamp conversion
    DateTime orderDate;
    if (data['orderDate'] is Timestamp) {
      orderDate = (data['orderDate'] as Timestamp).toDate();
    } else if (data['orderDate'] is String) {
      orderDate = DateTime.tryParse(data['orderDate']) ?? DateTime.now();
    } else {
      orderDate = DateTime.now();
    }

    // Parse status
    OrderStatus status;
    switch (data['status']?.toString().toLowerCase()) {
      case 'delivering':
        status = OrderStatus.delivering;
        break;
      case 'done':
      case 'completed':
        status = OrderStatus.done;
        break;
      default:
        status = OrderStatus.process;
    }

    // Debug logging untuk foto URLs
    print('🔍 DEBUG OrderModel.fromFirestore:');
    print('📋 Order ID: ${data['id']}');
    print('📷 Raw laundryPhotoUrl: ${data['laundryPhotoUrl']}');
    print('💳 Raw paymentProofUrl: ${data['paymentProofUrl']}');
    print('📊 All data keys: ${data.keys.toList()}');

    return OrderModel(
      id: data['id'] ?? '',
      customerName: data['customerName'] ?? 'Unknown Customer',
      customerEmail: data['customerEmail'],
      items: List<String>.from(data['items'] ?? []),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      orderDate: orderDate,
      status: status,
      deliveryAddress: data['deliveryAddress'],
      serviceType: data['serviceType'] ?? 'Self Service',
      paymentMethod: data['paymentMethod'] ?? 'QRIS',
      laundryPhotoUrl: data['laundryPhotoUrl'],
      paymentProofUrl: data['paymentProofUrl'],
    );
  }
}
