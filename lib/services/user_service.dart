import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final CollectionReference _usersCollection = _firestore.collection('users');

  // Get current user data
  static Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      print('🔍 Firebase Auth user: ${user?.uid}');

      if (user == null) {
        print('❌ No authenticated user found');
        return null;
      }

      print('📄 Fetching user document for UID: ${user.uid}');
      final doc = await _usersCollection.doc(user.uid).get();

      if (doc.exists) {
        print('✅ User document found');
        final data = doc.data() as Map<String, dynamic>;
        final userModel = UserModel.fromFirestore(data);
        print('👤 User loaded: ${userModel.username} (${userModel.uid})');
        return userModel;
      } else {
        print('📝 User document not found, creating new profile...');
        // Create user profile if doesn't exist
        return await createUserProfile(user);
      }
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Create user profile
  static Future<UserModel?> createUserProfile(User firebaseUser) async {
    try {
      final now = DateTime.now();
      
      final userData = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'User',
        username: (firebaseUser.displayName?.isNotEmpty == true) ? firebaseUser.displayName! : 'User', // Initialize username with displayName
        phoneNumber: firebaseUser.phoneNumber,
        profileImageUrl: firebaseUser.photoURL,
        addresses: [],
        preferences: UserPreferences(
          defaultServiceType: 'Self Service',
          defaultPaymentMethod: 'QRIS',
          notifications: true,
        ),
        totalOrders: 0,
        totalSpent: 0.0,
        memberSince: now,
        lastOrderDate: null,
        createdAt: now,
        updatedAt: now,
      );

      print('Creating user profile with UID: ${firebaseUser.uid}');
      print('User data to save: ${userData.toFirestore()}');

      await _usersCollection.doc(firebaseUser.uid).set(userData.toFirestore());

      print('User profile created successfully with UID: ${firebaseUser.uid}');
      return userData;
    } catch (e) {
      print('Error creating user profile: $e');
      return null;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(UserModel user) async {
    try {
      // Validate user ID
      if (user.uid.isEmpty) {
        print('Error: User ID is empty');
        return false;
      }

      final updatedUser = UserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        username: user.username,
        phoneNumber: user.phoneNumber,
        profileImageUrl: user.profileImageUrl,
        addresses: user.addresses,
        preferences: user.preferences,
        totalOrders: user.totalOrders,
        totalSpent: user.totalSpent,
        memberSince: user.memberSince,
        lastOrderDate: user.lastOrderDate,
        createdAt: user.createdAt,
        updatedAt: DateTime.now(),
      );

      print('Updating user profile for UID: ${user.uid}');
      await _usersCollection.doc(user.uid).update(updatedUser.toFirestore());
      print('User profile updated successfully');
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Update user stats after order
  static Future<bool> updateUserStats(String userId, double orderAmount) async {
    try {
      // Get all user orders to calculate accurate stats
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      final totalOrders = ordersSnapshot.docs.length;
      final totalSpent = ordersSnapshot.docs.fold<double>(0.0, (total, doc) {
        final data = doc.data();
        return total + (data['totalPrice'] ?? 0).toDouble();
      });

      await _usersCollection.doc(userId).update({
        'totalOrders': totalOrders,
        'totalSpent': totalSpent,
        'lastOrderDate': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error updating user stats: $e');
      return false;
    }
  }

  // Add address
  static Future<bool> addAddress(String userId, UserAddress address) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      final addresses = (userData['addresses'] as List<dynamic>?)
          ?.map((addr) => UserAddress.fromMap(addr as Map<String, dynamic>))
          .toList() ?? [];

      // If this is the first address or marked as default, make it default
      if (addresses.isEmpty || address.isDefault) {
        // Remove default from other addresses
        for (int i = 0; i < addresses.length; i++) {
          addresses[i] = UserAddress(
            id: addresses[i].id,
            label: addresses[i].label,
            address: addresses[i].address,
            latitude: addresses[i].latitude,
            longitude: addresses[i].longitude,
            isDefault: false,
          );
        }
      }

      addresses.add(address);

      await _usersCollection.doc(userId).update({
        'addresses': addresses.map((addr) => addr.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error adding address: $e');
      return false;
    }
  }

  // Update preferences
  static Future<bool> updatePreferences(String userId, UserPreferences preferences) async {
    try {
      await _usersCollection.doc(userId).update({
        'preferences': preferences.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error updating preferences: $e');
      return false;
    }
  }

  // Get user stream for real-time updates
  static Stream<UserModel?> getUserStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromFirestore(data);
      }
      return null;
    });
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Delete user account
  static Future<bool> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Delete user document from Firestore
      await _usersCollection.doc(user.uid).delete();
      
      // Delete Firebase Auth account
      await user.delete();
      
      return true;
    } catch (e) {
      print('Error deleting user account: $e');
      return false;
    }
  }
}
