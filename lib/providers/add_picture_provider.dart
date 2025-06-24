import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';

class AddPictureProvider with ChangeNotifier {

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _uploadedImageUrl;
  bool _useTestMode = true; // Default to test mode until Firebase Storage is configured

  // Multiple images support
  List<File> _selectedImages = [];
  File? _paymentProofImage;
  final int _maxPhotos = 4;

  File? get imageFile => _imageFile;
  bool get isUploading => _isUploading;
  String? get uploadedImageUrl => _uploadedImageUrl;
  bool get useTestMode => _useTestMode;
  List<File> get selectedImages => _selectedImages;
  File? get paymentProofImage => _paymentProofImage;
  int get maxPhotos => _maxPhotos;

  // Toggle test mode
  void setTestMode(bool enabled) {
    _useTestMode = enabled;
    notifyListeners();
  }

  Future<void> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  // Upload image to Firestore as base64
  Future<String?> uploadLaundryPhoto() async {
    if (_imageFile == null) {
      print('❌ Upload failed: No image file selected');
      return null;
    }

    print('🔄 Starting laundry photo upload to Firestore...');
    print('📁 Image file path: ${_imageFile!.path}');

    _isUploading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Upload failed: User not authenticated');
        throw Exception('User not authenticated');
      }

      print('👤 User authenticated: ${user.uid}');

      // Compress image first
      print('🗜️ Compressing image...');
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        _imageFile!.absolute.path,
        minWidth: 800,
        minHeight: 600,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) {
        print('❌ Image compression failed');
        throw Exception('Image compression failed');
      }

      print('📏 Original size: ${await _imageFile!.length()} bytes');
      print('📏 Compressed size: ${compressedBytes.length} bytes');
      print('📊 Compression ratio: ${((compressedBytes.length / await _imageFile!.length()) * 100).toStringAsFixed(1)}%');

      // Determine final bytes to use
      Uint8List finalBytes = compressedBytes;

      // Check if compressed size is still too large (800KB limit for safety)
      if (compressedBytes.length > 800 * 1024) {
        print('⚠️ Image still too large after compression, applying more compression...');
        final extraCompressed = await FlutterImageCompress.compressWithList(
          compressedBytes,
          minWidth: 600,
          minHeight: 400,
          quality: 50,
          format: CompressFormat.jpeg,
        );

        if (extraCompressed.length > 800 * 1024) {
          print('❌ Image too large even after extra compression: ${extraCompressed.length} bytes');
          throw Exception('Image file too large. Please use a smaller image.');
        }

        print('📏 Extra compressed size: ${extraCompressed.length} bytes');
        finalBytes = extraCompressed;
      }

      // Convert to base64
      final base64String = base64Encode(finalBytes);
      print('📝 Base64 string length: ${base64String.length}');

      // Create unique document ID
      final docId = 'laundry_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
      print('📝 Generated document ID: $docId');

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('laundry_photos')
          .doc(docId)
          .set({
        'userId': user.uid,
        'base64Data': base64String,
        'uploadedAt': FieldValue.serverTimestamp(),
        'fileName': '${docId}.jpg',
      });

      print('✅ Image saved to Firestore successfully');

      // Return document ID as reference
      final photoRef = 'firestore://laundry_photos/$docId';

      _uploadedImageUrl = photoRef;
      _isUploading = false;
      notifyListeners();

      return photoRef;
    } catch (e) {
      print('❌ Upload error: $e');
      print('❌ Error type: ${e.runtimeType}');

      _isUploading = false;
      notifyListeners();
      return null;
    }
  }



  // Reset image when starting new order
  void resetImage() {
    _imageFile = null;
    _uploadedImageUrl = null;
    _isUploading = false;
    notifyListeners();
  }

  // Remove current image
  void removeImage() {
    _imageFile = null;
    _uploadedImageUrl = null;
    notifyListeners();
  }

  // Multiple images methods
  void removeImageAt(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> pickImageFromGalleryMultiple() async {
    if (_selectedImages.length >= _maxPhotos) return;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImages.add(File(pickedFile.path));
      notifyListeners();
    }
  }

  Future<void> pickImageFromCameraMultiple() async {
    if (_selectedImages.length >= _maxPhotos) return;

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _selectedImages.add(File(pickedFile.path));
      notifyListeners();
    }
  }

  // Payment proof methods
  Future<void> pickPaymentProof() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _paymentProofImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  // Upload payment proof to Firestore as base64
  Future<String?> uploadPaymentProof() async {
    if (_paymentProofImage == null) {
      print('❌ Upload failed: No payment proof image selected');
      return null;
    }

    print('🔄 Starting payment proof upload to Firestore...');
    print('📁 Payment proof file path: ${_paymentProofImage!.path}');

    _isUploading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Upload failed: User not authenticated');
        throw Exception('User not authenticated');
      }

      print('👤 User authenticated: ${user.uid}');

      // Compress image first
      print('🗜️ Compressing payment proof image...');
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        _paymentProofImage!.absolute.path,
        minWidth: 800,
        minHeight: 600,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) {
        print('❌ Payment proof compression failed');
        throw Exception('Payment proof compression failed');
      }

      print('✅ Payment proof compressed successfully');
      print('📊 Original size: ${await _paymentProofImage!.length()} bytes');
      print('📊 Compressed size: ${compressedBytes.length} bytes');

      // Additional compression if still too large (>1MB)
      Uint8List finalBytes = compressedBytes;
      if (compressedBytes.length > 1024 * 1024) {
        print('🗜️ Further compressing payment proof (still > 1MB)...');
        final furtherCompressed = await FlutterImageCompress.compressWithList(
          compressedBytes,
          minWidth: 600,
          minHeight: 400,
          quality: 50,
          format: CompressFormat.jpeg,
        );
        finalBytes = furtherCompressed;
        print('📊 Final compressed size: ${finalBytes.length} bytes');
      }

      // Convert to base64
      final base64String = base64Encode(finalBytes);
      print('📝 Payment proof base64 string length: ${base64String.length}');

      // Create unique document ID
      final docId = 'payment_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
      print('📝 Generated payment proof document ID: $docId');

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('payment_proofs')
          .doc(docId)
          .set({
        'userId': user.uid,
        'base64Data': base64String,
        'uploadedAt': FieldValue.serverTimestamp(),
        'fileName': '${docId}.jpg',
      });

      print('✅ Payment proof saved to Firestore successfully');

      // Return document ID as reference
      final paymentRef = 'firestore://payment_proofs/$docId';

      _isUploading = false;
      notifyListeners();

      return paymentRef;
    } catch (e) {
      print('❌ Payment proof upload error: $e');
      print('❌ Error type: ${e.runtimeType}');

      _isUploading = false;
      notifyListeners();
      return null;
    }
  }

  // Public setter for image file (for upload flow)
  void setImageFile(File file) {
    _imageFile = file;
  }

  // Clear all images
  void clearAllImages() {
    _selectedImages.clear();
    _paymentProofImage = null;
    _imageFile = null;
    _uploadedImageUrl = null;
    notifyListeners();
  }
}
