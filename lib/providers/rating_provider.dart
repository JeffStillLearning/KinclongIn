import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

class RatingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<RatingModel> _ratings = [];
  bool _isLoading = false;
  String? _error;

  List<RatingModel> get ratings => _ratings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get average rating for a service
  double getAverageRating(String serviceName) {
    final serviceRatings = _ratings.where((r) => r.serviceName == serviceName).toList();
    if (serviceRatings.isEmpty) return 0.0;
    
    final total = serviceRatings.fold(0, (sum, rating) => sum + rating.rating);
    return total / serviceRatings.length;
  }

  // Get total reviews count for a service
  int getReviewCount(String serviceName) {
    return _ratings.where((r) => r.serviceName == serviceName).length;
  }

  // Submit rating and review
  Future<bool> submitRating({
    required String orderId,
    required String userId,
    required String userName,
    required String serviceName,
    required int rating,
    required String review,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if rating already exists for this order
      final existingRating = await _firestore
          .collection('ratings')
          .where('orderId', isEqualTo: orderId)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // Update existing rating
        await _firestore
            .collection('ratings')
            .doc(existingRating.docs.first.id)
            .update({
          'rating': rating,
          'review': review,
          'updatedAt': Timestamp.now(),
        });
      } else {
        // Create new rating
        await _firestore.collection('ratings').add({
          'orderId': orderId,
          'userId': userId,
          'userName': userName,
          'serviceName': serviceName,
          'rating': rating,
          'review': review,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
      }

      await fetchRatings();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error submitting rating: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all ratings
  Future<void> fetchRatings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('ratings')
          .orderBy('createdAt', descending: true)
          .get();

      _ratings = snapshot.docs
          .map((doc) => RatingModel.fromFirestore(doc))
          .toList();

    } catch (e) {
      _error = e.toString();
      print('Error fetching ratings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get ratings for specific order
  Future<RatingModel?> getRatingForOrder(String orderId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('orderId', isEqualTo: orderId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return RatingModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting rating for order: $e');
      return null;
    }
  }

  // Get ratings by user
  List<RatingModel> getRatingsByUser(String userId) {
    return _ratings.where((rating) => rating.userId == userId).toList();
  }

  // Get ratings by service
  List<RatingModel> getRatingsByService(String serviceName) {
    return _ratings.where((rating) => rating.serviceName == serviceName).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
