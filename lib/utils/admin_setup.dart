import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetup {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Setup admin account if it doesn't exist
  static Future<bool> setupAdminAccount() async {
    try {
      print('🔧 Setting up admin account...');
      
      // Check if admin already exists
      final adminExists = await _checkAdminExists();
      if (adminExists) {
        print('✅ Admin account already exists');
        return true;
      }

      // Create admin account
      print('👤 Creating admin account...');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: 'admin@gmail.com',
        password: 'admin123',
      );

      if (userCredential.user != null) {
        // Create admin document in Firestore
        await _createAdminDocument(userCredential.user!);
        print('✅ Admin account created successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error setting up admin: $e');
      return false;
    }
  }

  /// Check if admin account exists
  static Future<bool> _checkAdminExists() async {
    try {
      // Check in Firestore for admin role
      final adminQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'admin@gmail.com')
          .where('role', isEqualTo: 'Admin')
          .get();

      return adminQuery.docs.isNotEmpty;
    } catch (e) {
      print('Error checking admin existence: $e');
      return false;
    }
  }

  /// Create admin document in Firestore
  static Future<void> _createAdminDocument(User user) async {
    try {
      final adminData = {
        'uid': user.uid,
        'email': user.email,
        'role': 'Admin',
        'displayName': 'Admin',
        'username': 'Admin',
        'phoneNumber': null,
        'profileImageUrl': null,
        'addresses': [],
        'preferences': {
          'defaultServiceType': 'Self Service',
          'defaultPaymentMethod': 'QRIS',
          'notifications': true,
        },
        'totalOrders': 0,
        'totalSpent': 0,
        'memberSince': FieldValue.serverTimestamp(),
        'lastOrderDate': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(adminData);
      print('📄 Admin document created in Firestore');
    } catch (e) {
      print('Error creating admin document: $e');
      throw e;
    }
  }

  /// Convert existing user to admin
  static Future<bool> convertUserToAdmin(String email) async {
    try {
      print('🔄 Converting user to admin: $email');

      // Find user document
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        print('❌ User not found: $email');
        return false;
      }

      // Update role to Admin
      final userDoc = userQuery.docs.first;
      await userDoc.reference.update({
        'role': 'Admin',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ User converted to admin successfully');
      return true;
    } catch (e) {
      print('❌ Error converting user to admin: $e');
      return false;
    }
  }

  /// Create sample laundry services
  static Future<void> createSampleServices() async {
    try {
      print('🧽 Creating sample laundry services...');

      final services = [
        {
          'name': 'Shoe Wash',
          'description': 'Professional shoe cleaning service',
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
          'name': 'Bag Wash',
          'description': 'Complete bag cleaning and care',
          'price': 25000,
          'promoPrice': 20000,
          'promoDescription': 'Weekend special discount!',
          'isPromoActive': true,
          'category': 'Bags',
          'imageUrl': 'https://via.placeholder.com/150',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Shoe Repaint',
          'description': 'Restore your shoes with professional repainting',
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
      ];

      for (final service in services) {
        await _firestore.collection('laundry_services').add(service);
      }

      print('✅ Sample services created successfully');
    } catch (e) {
      print('❌ Error creating sample services: $e');
    }
  }

  /// Verify admin setup
  static Future<bool> verifyAdminSetup() async {
    try {
      print('🔍 Verifying admin setup...');

      // Check Firebase Auth
      final methods = await _auth.fetchSignInMethodsForEmail('admin@gmail.com');
      if (methods.isEmpty) {
        print('❌ Admin not found in Firebase Auth');
        return false;
      }

      // Check Firestore document
      final adminQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'admin@gmail.com')
          .where('role', isEqualTo: 'Admin')
          .get();

      if (adminQuery.docs.isEmpty) {
        print('❌ Admin document not found in Firestore');
        return false;
      }

      print('✅ Admin setup verified successfully');
      return true;
    } catch (e) {
      print('❌ Error verifying admin setup: $e');
      return false;
    }
  }

  /// Complete admin setup (run this once)
  static Future<void> completeSetup() async {
    print('🚀 Starting complete admin setup...');
    
    try {
      // Step 1: Setup admin account
      final adminCreated = await setupAdminAccount();
      if (!adminCreated) {
        print('❌ Failed to create admin account');
        return;
      }

      // Step 2: Create sample services
      await createSampleServices();

      // Step 3: Verify setup
      final verified = await verifyAdminSetup();
      if (verified) {
        print('🎉 Admin setup completed successfully!');
        print('📧 Email: admin@gmail.com');
        print('🔑 Password: admin123');
      } else {
        print('❌ Admin setup verification failed');
      }
    } catch (e) {
      print('❌ Error during complete setup: $e');
    }
  }
}
