import 'package:cloud_firestore/cloud_firestore.dart';

class SetupCorrectServices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Clear all existing services and create the correct 5 services
  static Future<void> setupCorrectServices() async {
    try {
      print('🧹 Clearing existing services...');
      
      // Delete all existing services
      await _clearAllServices();
      
      print('✨ Creating correct 5 services...');
      
      // Create the correct 5 services
      await _createCorrectServices();
      
      print('✅ Setup completed! 5 services created successfully.');
      
    } catch (e) {
      print('❌ Error setting up services: $e');
    }
  }

  /// Delete all existing services
  static Future<void> _clearAllServices() async {
    try {
      final snapshot = await _firestore.collection('laundry_services').get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      print('🗑️ Deleted ${snapshot.docs.length} existing services');
    } catch (e) {
      print('❌ Error clearing services: $e');
    }
  }

  /// Create the correct 5 services
  static Future<void> _createCorrectServices() async {
    final services = [
      {
        'name': 'Regular Shoe',
        'description': 'Basic shoe cleaning service for regular footwear',
        'price': 15000,
        'promoPrice': null,
        'promoDescription': null,
        'isPromoActive': false,
        'category': 'Shoes',
        'imageUrl': 'https://via.placeholder.com/150',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Branded Shoe',
        'description': 'Premium cleaning service for branded shoes',
        'price': 25000,
        'promoPrice': 20000,
        'promoDescription': 'Special discount for branded shoes!',
        'isPromoActive': true,
        'category': 'Shoes',
        'imageUrl': 'https://via.placeholder.com/150',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Repainted Shoe',
        'description': 'Professional shoe repainting and restoration service',
        'price': 35000,
        'promoPrice': null,
        'promoDescription': null,
        'isPromoActive': false,
        'category': 'Repair',
        'imageUrl': 'https://via.placeholder.com/150',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Regular Bag',
        'description': 'Standard bag cleaning service',
        'price': 20000,
        'promoPrice': null,
        'promoDescription': null,
        'isPromoActive': false,
        'category': 'Bags',
        'imageUrl': 'https://via.placeholder.com/150',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Branded Bag',
        'description': 'Premium cleaning service for branded bags',
        'price': 30000,
        'promoPrice': 25000,
        'promoDescription': 'Weekend special for branded bags!',
        'isPromoActive': true,
        'category': 'Bags',
        'imageUrl': 'https://via.placeholder.com/150',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (int i = 0; i < services.length; i++) {
      await _firestore.collection('laundry_services').add(services[i]);
      print('✅ Created service ${i + 1}/5: ${services[i]['name']}');
    }
  }

  /// Count current services
  static Future<int> countServices() async {
    try {
      final snapshot = await _firestore.collection('laundry_services').get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error counting services: $e');
      return 0;
    }
  }

  /// List all services
  static Future<void> listAllServices() async {
    try {
      print('📋 === CURRENT SERVICES ===');
      
      final snapshot = await _firestore
          .collection('laundry_services')
          .orderBy('createdAt')
          .get();
      
      if (snapshot.docs.isEmpty) {
        print('❌ No services found');
        return;
      }
      
      for (int i = 0; i < snapshot.docs.length; i++) {
        final data = snapshot.docs[i].data() as Map<String, dynamic>;
        print('${i + 1}. ${data['name']} - Rp ${data['price']}');
        if (data['isPromoActive'] == true) {
          print('   🏷️ Promo: Rp ${data['promoPrice']} - ${data['promoDescription']}');
        }
      }
      
      print('📋 === TOTAL: ${snapshot.docs.length} services ===\n');
      
    } catch (e) {
      print('❌ Error listing services: $e');
    }
  }

  /// Check if services need setup
  static Future<bool> needsSetup() async {
    try {
      final count = await countServices();
      return count != 5; // Should have exactly 5 services
    } catch (e) {
      return true; // If error, assume needs setup
    }
  }

  /// Quick setup check and fix
  static Future<void> checkAndSetup() async {
    try {
      final count = await countServices();
      print('🔍 Current services count: $count');
      
      if (count == 5) {
        print('✅ Services already correctly set up (5 services)');
        await listAllServices();
        return;
      }
      
      if (count == 0) {
        print('📝 No services found. Creating 5 services...');
        await _createCorrectServices();
      } else {
        print('⚠️ Found $count services (should be 5). Fixing...');
        await setupCorrectServices();
      }
      
      await listAllServices();
      
    } catch (e) {
      print('❌ Error in checkAndSetup: $e');
    }
  }
}
