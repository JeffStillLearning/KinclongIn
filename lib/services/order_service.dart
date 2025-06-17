import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import 'user_service.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  static CollectionReference get _ordersCollection => _firestore.collection('orders');

  // Create new order
  static Future<String?> createOrder({
    required List<String> items,
    required double totalPrice,
    required String serviceType,
    required String paymentMethod,
    String? deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    String? proofImageUrl,
    String? laundryPhotoUrl,
    String? paymentProofUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      print('🔍 Current user: ${user?.uid}');
      print('🔍 User email: ${user?.email}');

      if (user == null) {
        print('❌ User not authenticated');
        throw Exception('User not authenticated');
      }

      // Generate order ID
      final orderId = _generateOrderId();
      print('🆔 Generated order ID: $orderId');
      
      // Debug logging sebelum save ke Firestore
      print('🔍 DEBUG OrderService.createOrder:');
      print('📋 Order ID: $orderId');
      print('📷 Laundry Photo URL: $laundryPhotoUrl');
      print('💳 Payment Proof URL: $paymentProofUrl');

      // Create order data
      final orderData = {
        'id': orderId,
        'userId': user.uid,
        'customerName': user.displayName ?? user.email ?? 'Unknown',
        'customerEmail': user.email,
        'items': items,
        'totalPrice': totalPrice,
        'orderDate': FieldValue.serverTimestamp(),
        'status': 'process', // Default status
        'serviceType': serviceType,
        'paymentMethod': paymentMethod,
        'deliveryAddress': deliveryAddress,
        'deliveryLat': deliveryLat,
        'deliveryLng': deliveryLng,
        'proofImageUrl': proofImageUrl,
        'laundryPhotoUrl': laundryPhotoUrl,
        'paymentProofUrl': paymentProofUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('📊 Order data to save: $orderData');

      // Save to Firestore
      print('💾 Attempting to save order to Firestore...');
      print('📄 Order data: $orderData');

      await _ordersCollection.doc(orderId).set(orderData);

      // Update user stats
      await UserService.updateUserStats(user.uid, totalPrice);

      print('✅ Order saved successfully!');
      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Get orders for current user
  static Future<List<OrderModel>> getUserOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      final querySnapshot = await _ordersCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      print('Error getting user orders: $e');
      return [];
    }
  }

  // Get order by ID
  static Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromFirestore(data);
      }
      
      return null;
    } catch (e) {
      print('Error getting order by ID: $e');
      return null;
    }
  }

  // Update order status
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Update proof image URL
  static Future<bool> updateProofImage(String orderId, String imageUrl) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'proofImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating proof image: $e');
      return false;
    }
  }

  // Listen to user orders (real-time)
  static Stream<List<OrderModel>> getUserOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _ordersCollection
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromFirestore(data);
      }).toList();

      // Sort by date descending (newest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      return orders;
    });
  }

  // Helper method to generate order ID
  static String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORD${timestamp.toString().substring(7)}'; // ORD + last 6 digits
  }



  // Delete order (if needed)
  static Future<bool> deleteOrder(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).delete();
      return true;
    } catch (e) {
      print('Error deleting order: $e');
      return false;
    }
  }

  // Get orders count by status for current user
  static Future<Map<String, int>> getOrdersCountByStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'process': 0, 'delivering': 0, 'done': 0};
      }

      final querySnapshot = await _ordersCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      int processCount = 0;
      int deliveringCount = 0;
      int doneCount = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'process';
        
        switch (status) {
          case 'process':
            processCount++;
            break;
          case 'delivering':
            deliveringCount++;
            break;
          case 'done':
            doneCount++;
            break;
        }
      }

      return {
        'process': processCount,
        'delivering': deliveringCount,
        'done': doneCount,
      };
    } catch (e) {
      print('Error getting orders count: $e');
      return {'process': 0, 'delivering': 0, 'done': 0};
    }
  }
}
