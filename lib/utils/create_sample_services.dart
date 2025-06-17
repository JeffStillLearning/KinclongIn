import 'package:cloud_firestore/cloud_firestore.dart';

class CreateSampleServices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> createAllServices() async {
    try {
      print('🔧 Creating sample services...');

      // Check if services already exist
      final existingServices = await _firestore.collection('services').get();
      if (existingServices.docs.isNotEmpty) {
        print('✅ Services already exist (${existingServices.docs.length} services)');
        return;
      }

      // Create 8 services
      final services = [
        {
          'name': 'Regular Shoe Cleaning',
          'description': 'Basic cleaning for everyday shoes',
          'price': 15000,
          'category': 'Shoe',
          'isActive': true,
          'hasPromotion': false,
          'promotionDiscount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Branded Shoe Cleaning',
          'description': 'Premium cleaning for branded shoes',
          'price': 25000,
          'category': 'Shoe',
          'isActive': true,
          'hasPromotion': true,
          'promotionDiscount': 20,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Repainted Shoe Service',
          'description': 'Complete shoe repainting service',
          'price': 50000,
          'category': 'Shoe',
          'isActive': true,
          'hasPromotion': true,
          'promotionDiscount': 15,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Regular Shoe Bag',
          'description': 'Basic shoe bag cleaning service',
          'price': 18000,
          'category': 'Bag',
          'isActive': true,
          'hasPromotion': true,
          'promotionDiscount': 10,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Branded Bag Cleaning',
          'description': 'Premium branded bag cleaning service',
          'price': 35000,
          'category': 'Bag',
          'isActive': true,
          'hasPromotion': false,
          'promotionDiscount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Others Service 1',
          'description': 'Special cleaning for other items',
          'price': 30000,
          'category': 'Others',
          'isActive': true,
          'hasPromotion': false,
          'promotionDiscount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Others Service 2',
          'description': 'Additional cleaning service for special items',
          'price': 40000,
          'category': 'Others',
          'isActive': true,
          'hasPromotion': false,
          'promotionDiscount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Others Service 3',
          'description': 'Premium cleaning service for special needs',
          'price': 60000,
          'category': 'Others',
          'isActive': true,
          'hasPromotion': false,
          'promotionDiscount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      // Add each service to Firestore
      for (int i = 0; i < services.length; i++) {
        await _firestore
            .collection('services')
            .doc('service_${i + 1}')
            .set(services[i]);
        
        print('✅ Created service: ${services[i]['name']}');
      }

      print('🎉 All 8 services created successfully!');
      print('📊 Services with promotions: 3');
      print('📊 Services without promotions: 5');

    } catch (e) {
      print('❌ Error creating services: $e');
    }
  }

  static Future<void> deleteAllServices() async {
    try {
      print('🗑️ Deleting all services...');
      
      final services = await _firestore.collection('services').get();
      for (var doc in services.docs) {
        await doc.reference.delete();
      }
      
      print('✅ All services deleted');
    } catch (e) {
      print('❌ Error deleting services: $e');
    }
  }
}
