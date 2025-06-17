import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/laundry_service_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static final CollectionReference _servicesCollection = _firestore.collection('laundry_services');
  static final CollectionReference _ordersCollection = _firestore.collection('orders');
  static final CollectionReference _usersCollection = _firestore.collection('users');

  // Check if current user is admin
  static Future<bool> isAdmin() async {
    try {
      final user = _auth.currentUser;
      print('🔍 Checking admin status for user: ${user?.email}');
      print('🆔 User UID: ${user?.uid}');

      if (user == null) {
        print('❌ No current user found');
        return false;
      }

      final userDoc = await _usersCollection.doc(user.uid).get();
      print('📄 User document exists: ${userDoc.exists}');

      if (!userDoc.exists) {
        print('❌ User document not found in Firestore');
        return false;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final role = userData['role'];
      print('👤 User role in Firestore: "$role"');
      print('✅ Is Admin: ${role == 'Admin'}');

      return userData['role'] == 'Admin';
    } catch (e) {
      print('❌ Error checking admin status: $e');
      return false;
    }
  }

  // LAUNDRY SERVICES MANAGEMENT

  // Get all laundry services
  static Future<List<LaundryServiceModel>> getAllServices() async {
    try {
      final snapshot = await _servicesCollection.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) {
        return LaundryServiceModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting services: $e');
      return [];
    }
  }

  // Add new laundry service
  static Future<bool> addService(LaundryServiceModel service) async {
    try {
      await _servicesCollection.add(service.toFirestore());
      return true;
    } catch (e) {
      print('Error adding service: $e');
      return false;
    }
  }

  // Update laundry service
  static Future<bool> updateService(LaundryServiceModel service) async {
    try {
      await _servicesCollection.doc(service.id).update(service.toFirestore());
      return true;
    } catch (e) {
      print('Error updating service: $e');
      return false;
    }
  }

  // Delete laundry service
  static Future<bool> deleteService(String serviceId) async {
    try {
      await _servicesCollection.doc(serviceId).delete();
      return true;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  // Toggle service active status
  static Future<bool> toggleServiceStatus(String serviceId, bool isActive) async {
    try {
      await _servicesCollection.doc(serviceId).update({
        'isActive': isActive,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error toggling service status: $e');
      return false;
    }
  }

  // PROMO MANAGEMENT

  // Add promo to service
  static Future<bool> addPromoToService(String serviceId, double promoPrice, String promoDescription) async {
    try {
      await _servicesCollection.doc(serviceId).update({
        'promoPrice': promoPrice,
        'promoDescription': promoDescription,
        'isPromoActive': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error adding promo: $e');
      return false;
    }
  }

  // Remove promo from service
  static Future<bool> removePromoFromService(String serviceId) async {
    try {
      await _servicesCollection.doc(serviceId).update({
        'promoPrice': null,
        'promoDescription': null,
        'isPromoActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error removing promo: $e');
      return false;
    }
  }

  // ORDERS MANAGEMENT

  // Get all orders for admin view
  static Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _ordersCollection.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to data
        return OrderModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      print('Error getting orders: $e');
      return [];
    }
  }

  // Update order status
  static Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': newStatus.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // CUSTOMERS MANAGEMENT

  // Get all customers
  static Future<List<UserModel>> getAllCustomers() async {
    try {
      final snapshot = await _usersCollection.where('role', isEqualTo: 'Customer').get();
      return snapshot.docs.map((doc) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error getting customers: $e');
      return [];
    }
  }

  // ANALYTICS

  // Get total revenue from all orders
  static Future<double> getTotalRevenue() async {
    try {
      // Get all orders regardless of status
      final snapshot = await _ordersCollection.get();
      double total = 0;

      print('📊 Calculating total revenue from ${snapshot.docs.length} orders');

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final orderPrice = (data['totalPrice'] ?? 0).toDouble();
        final orderId = data['id'] ?? 'unknown';
        final status = data['status'] ?? 'unknown';

        total += orderPrice;
        print('💰 Order $orderId ($status): Rp ${orderPrice.toStringAsFixed(0)}');
      }

      print('💵 Total Revenue: Rp ${total.toStringAsFixed(0)}');
      return total;
    } catch (e) {
      print('Error getting total revenue: $e');
      return 0;
    }
  }

  // Get total orders count
  static Future<int> getTotalOrdersCount() async {
    try {
      final snapshot = await _ordersCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting orders count: $e');
      return 0;
    }
  }

  // Get total customers count
  static Future<int> getTotalCustomersCount() async {
    try {
      final snapshot = await _usersCollection.where('role', isEqualTo: 'Customer').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting customers count: $e');
      return 0;
    }
  }

  // Get orders by status count
  static Future<Map<String, int>> getOrdersByStatus() async {
    try {
      final snapshot = await _ordersCollection.get();
      Map<String, int> statusCount = {
        'process': 0,
        'delivering': 0,
        'done': 0,
      };

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'process';
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }

      return statusCount;
    } catch (e) {
      print('Error getting orders by status: $e');
      return {'process': 0, 'delivering': 0, 'done': 0};
    }
  }
}
