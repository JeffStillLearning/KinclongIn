import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/laundry_service_model.dart';

class LaundryServicesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<LaundryServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<LaundryServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get services by category
  List<LaundryServiceModel> getServicesByCategory(String category) {
    return _services.where((service) => 
      service.category.toLowerCase() == category.toLowerCase() && 
      service.isActive
    ).toList();
  }

  // Get all active services
  List<LaundryServiceModel> get activeServices {
    return _services.where((service) => service.isActive).toList();
  }

  // Get services with promo
  List<LaundryServiceModel> get promoServices {
    return _services.where((service) => service.hasPromo && service.isActive).toList();
  }

  // Load services from Firebase
  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Debug authentication state
      final user = FirebaseAuth.instance.currentUser;
      print('🔍 Loading services - Auth state:');
      print('👤 User: ${user?.uid}');
      print('📧 Email: ${user?.email}');
      print('✅ Authenticated: ${user != null}');

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get all services first, then filter and sort in memory
      print('📋 Fetching services from Firestore...');
      final snapshot = await _firestore
          .collection('laundry_services')
          .get();

      // Filter active services and sort in memory
      _services = snapshot.docs
          .map((doc) {
            return LaundryServiceModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id
            );
          })
          .where((service) => service.isActive)
          .toList();

      // Sort by createdAt
      _services.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      print('✅ Loaded ${_services.length} active services');

    } catch (e) {
      _error = 'Failed to load services: $e';
      print('❌ Error loading services: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Listen to real-time updates
  void listenToServices() {
    _firestore
        .collection('laundry_services')
        .snapshots()
        .listen(
      (snapshot) {
        // Filter active services and sort in memory
        _services = snapshot.docs
            .map((doc) {
              return LaundryServiceModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id
              );
            })
            .where((service) => service.isActive)
            .toList();

        // Sort by createdAt
        _services.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        print('🔄 Services updated: ${_services.length} active services');
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to listen to services: $error';
        print('❌ Error listening to services: $error');
        notifyListeners();
      },
    );
  }

  // Refresh services
  Future<void> refreshServices() async {
    await loadServices();
  }

  // Get service by ID
  LaundryServiceModel? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search services
  List<LaundryServiceModel> searchServices(String query) {
    if (query.isEmpty) return activeServices;
    
    return _services.where((service) =>
      service.isActive &&
      (service.name.toLowerCase().contains(query.toLowerCase()) ||
       service.description.toLowerCase().contains(query.toLowerCase()) ||
       service.category.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  // Get categories
  List<String> get categories {
    final categorySet = <String>{};
    for (var service in _services) {
      if (service.isActive) {
        categorySet.add(service.category);
      }
    }
    return categorySet.toList()..sort();
  }

  // Clear data
  void clearData() {
    _services = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
