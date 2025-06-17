import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugAdmin {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Debug current user and admin status
  static Future<void> debugCurrentUser() async {
    print('🔍 === DEBUG ADMIN STATUS ===');
    
    try {
      // Check Firebase Auth
      final user = _auth.currentUser;
      print('👤 Current User:');
      print('   - Email: ${user?.email}');
      print('   - UID: ${user?.uid}');
      print('   - Verified: ${user?.emailVerified}');
      
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      // Check Firestore document
      print('\n📄 Checking Firestore document...');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      print('   - Document exists: ${userDoc.exists}');
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        print('   - Document data:');
        userData.forEach((key, value) {
          print('     $key: $value');
        });
        
        final role = userData['role'];
        print('\n🎭 Role Analysis:');
        print('   - Role value: "$role"');
        print('   - Role type: ${role.runtimeType}');
        print('   - Is exactly "Admin": ${role == 'Admin'}');
        print('   - Is case-insensitive admin: ${role?.toString().toLowerCase() == 'admin'}');
      } else {
        print('❌ User document not found in Firestore');
        print('💡 Creating admin document...');
        await _createAdminDocument(user);
      }
      
    } catch (e) {
      print('❌ Error during debug: $e');
    }
    
    print('🔍 === END DEBUG ===\n');
  }

  /// Create admin document for current user
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
      print('✅ Admin document created successfully');
    } catch (e) {
      print('❌ Error creating admin document: $e');
    }
  }

  /// Force convert current user to admin
  static Future<void> forceConvertToAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      print('🔄 Force converting ${user.email} to admin...');

      // Check if document already exists
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document exists, only update essential admin fields without overwriting username
        final existingData = docSnapshot.data() as Map<String, dynamic>;
        final existingUsername = existingData['username'];

        print('📄 Document exists, preserving username: $existingUsername');

        await docRef.update({
          'role': 'Admin',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('✅ Admin role updated, username preserved');
      } else {
        // Document doesn't exist, create new one with default values
        print('📄 Creating new admin document...');

        await docRef.set({
          'uid': user.uid,
          'email': user.email,
          'role': 'Admin',
          'displayName': 'Administrator',
          'username': 'Administrator',
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
        });

        print('✅ New admin document created');
      }

      // Verify conversion
      await debugCurrentUser();

    } catch (e) {
      print('❌ Error converting to admin: $e');
    }
  }

  /// List all users in Firestore
  static Future<void> listAllUsers() async {
    try {
      print('👥 === ALL USERS IN FIRESTORE ===');
      
      final snapshot = await _firestore.collection('users').get();
      
      if (snapshot.docs.isEmpty) {
        print('❌ No users found in Firestore');
        return;
      }
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('\n📄 User Document: ${doc.id}');
        print('   - Email: ${data['email']}');
        print('   - Role: "${data['role']}"');
        print('   - Username: ${data['username']}');
        print('   - Display Name: ${data['displayName']}');
      }
      
      print('\n👥 === END USER LIST ===\n');
      
    } catch (e) {
      print('❌ Error listing users: $e');
    }
  }

  /// Check if admin@gmail.com exists
  static Future<void> checkAdminEmail() async {
    try {
      print('📧 === CHECKING admin@gmail.com ===');
      
      // Check in Firebase Auth
      try {
        final methods = await _auth.fetchSignInMethodsForEmail('admin@gmail.com');
        print('🔐 Firebase Auth:');
        print('   - Email exists: ${methods.isNotEmpty}');
        print('   - Sign-in methods: $methods');
      } catch (e) {
        print('❌ Error checking Firebase Auth: $e');
      }
      
      // Check in Firestore
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'admin@gmail.com')
          .get();
      
      print('\n📄 Firestore:');
      print('   - Documents found: ${snapshot.docs.length}');
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('   - Document ID: ${doc.id}');
        print('   - Role: "${data['role']}"');
        print('   - Is Admin: ${data['role'] == 'Admin'}');
      }
      
      print('📧 === END ADMIN CHECK ===\n');
      
    } catch (e) {
      print('❌ Error checking admin email: $e');
    }
  }
}
