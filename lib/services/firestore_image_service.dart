import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreImageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get image data from Firestore as base64 string
  static Future<String?> getImageBase64(String imageRef) async {
    try {
      print('🔍 Getting image from Firestore: $imageRef');
      
      // Parse the reference
      if (!imageRef.startsWith('firestore://')) {
        print('❌ Invalid image reference format: $imageRef');
        return null;
      }
      
      // Extract collection and document ID
      final path = imageRef.substring('firestore://'.length);
      final parts = path.split('/');
      
      if (parts.length != 2) {
        print('❌ Invalid path format: $path');
        return null;
      }
      
      final collection = parts[0];
      final docId = parts[1];
      
      print('📂 Collection: $collection, Document: $docId');
      
      // Get document from Firestore
      final doc = await _firestore.collection(collection).doc(docId).get();
      
      if (!doc.exists) {
        print('❌ Document not found: $docId');
        return null;
      }
      
      final data = doc.data() as Map<String, dynamic>;
      final base64Data = data['base64Data'] as String?;
      
      if (base64Data == null) {
        print('❌ No base64Data found in document');
        return null;
      }
      
      print('✅ Image data retrieved successfully');
      return base64Data;
    } catch (e) {
      print('❌ Error getting image from Firestore: $e');
      return null;
    }
  }

  /// Get image bytes from Firestore
  static Future<Uint8List?> getImageBytes(String imageRef) async {
    try {
      final base64Data = await getImageBase64(imageRef);
      if (base64Data == null) return null;
      
      return base64Decode(base64Data);
    } catch (e) {
      print('❌ Error decoding image bytes: $e');
      return null;
    }
  }

  /// Check if image reference is a Firestore reference
  static bool isFirestoreReference(String? imageRef) {
    if (imageRef == null || imageRef.isEmpty) return false;
    return imageRef.startsWith('firestore://');
  }

  /// Check if image reference is a local placeholder
  static bool isLocalPlaceholder(String? imageRef) {
    if (imageRef == null || imageRef.isEmpty) return false;
    return imageRef.startsWith('local://');
  }

  /// Get image info from Firestore document
  static Future<Map<String, dynamic>?> getImageInfo(String imageRef) async {
    try {
      if (!imageRef.startsWith('firestore://')) return null;
      
      final path = imageRef.substring('firestore://'.length);
      final parts = path.split('/');
      
      if (parts.length != 2) return null;
      
      final collection = parts[0];
      final docId = parts[1];
      
      final doc = await _firestore.collection(collection).doc(docId).get();
      
      if (!doc.exists) return null;
      
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error getting image info: $e');
      return null;
    }
  }

  /// Delete image from Firestore
  static Future<bool> deleteImage(String imageRef) async {
    try {
      if (!imageRef.startsWith('firestore://')) return false;
      
      final path = imageRef.substring('firestore://'.length);
      final parts = path.split('/');
      
      if (parts.length != 2) return false;
      
      final collection = parts[0];
      final docId = parts[1];
      
      await _firestore.collection(collection).doc(docId).delete();
      
      print('✅ Image deleted successfully: $imageRef');
      return true;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Get all images for a user
  static Future<List<Map<String, dynamic>>> getUserImages(String userId, String collection) async {
    try {
      final querySnapshot = await _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .orderBy('uploadedAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['reference'] = 'firestore://$collection/${doc.id}';
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error getting user images: $e');
      return [];
    }
  }

  /// Clean up old images (older than specified days)
  static Future<int> cleanupOldImages(String collection, int daysOld) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);
      
      final querySnapshot = await _firestore
          .collection(collection)
          .where('uploadedAt', isLessThan: cutoffTimestamp)
          .get();
      
      int deletedCount = 0;
      
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }
      
      print('✅ Cleaned up $deletedCount old images from $collection');
      return deletedCount;
    } catch (e) {
      print('❌ Error cleaning up old images: $e');
      return 0;
    }
  }
}
