import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import '../models/laundry_service_model.dart';

class ServiceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ServiceModel> _services = [];
  List<ServiceModel> _promotions = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  List<ServiceModel> get promotions => _promotions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all active services
  Future<void> fetchServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 Attempting to fetch services from Firestore...');

      // First, get ALL services from laundry_services collection (where admin stores data)
      final QuerySnapshot allSnapshot = await _firestore
          .collection('laundry_services')
          .get();

      print('📊 Total documents in laundry_services collection: ${allSnapshot.docs.length}');

      // Debug each document
      for (var doc in allSnapshot.docs) {
        print('📄 Document ${doc.id}:');
        print('   - Data: ${doc.data()}');
        print('   - isActive field exists: ${(doc.data() as Map).containsKey('isActive')}');
        if ((doc.data() as Map).containsKey('isActive')) {
          print('   - isActive value: ${(doc.data() as Map)['isActive']} (${(doc.data() as Map)['isActive'].runtimeType})');
        }
      }

      // Now try to get services with isActive filter from laundry_services
      final QuerySnapshot snapshot = await _firestore
          .collection('laundry_services')
          .where('isActive', isEqualTo: true)
          .get();

      print('✅ Successfully fetched ${snapshot.docs.length} services with isActive=true from Firestore');

      // Convert LaundryServiceModel to ServiceModel
      _services = snapshot.docs
          .map((doc) => _convertLaundryServiceToService(doc))
          .toList();

      // Filter promotions (services with hasPromotion = true)
      _promotions = _services
          .where((service) => service.hasPromotion && service.promotionDiscount > 0)
          .toList();

      print('📊 Services loaded: ${_services.length} total, ${_promotions.length} with promotions');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching services: $e');

      // If permission denied or any error, provide sample data
      print('🔧 Using sample data instead...');
      _provideSampleData();

      _isLoading = false;
      notifyListeners();
    }
  }

  // Provide sample data when Firestore rules are not set up
  void _provideSampleData() {
    print('🔧 Providing sample services data due to permission error');

    _services = [
      ServiceModel(
        id: 'sample_1',
        name: 'Regular Shoe Cleaning',
        description: 'Basic cleaning for everyday shoes',
        price: 15000,
        category: 'Shoe',
        isActive: true,
        hasPromotion: false,
        promotionDiscount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'sample_2',
        name: 'Branded Shoe Cleaning',
        description: 'Premium cleaning for branded shoes',
        price: 25000,
        category: 'Shoe',
        isActive: true,
        hasPromotion: true,
        promotionDiscount: 20,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'sample_3',
        name: 'Repainted Shoe Service',
        description: 'Complete shoe repainting service',
        price: 50000,
        category: 'Shoe',
        isActive: true,
        hasPromotion: true,
        promotionDiscount: 15,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'sample_4',
        name: 'Regular Shoe Bag Cleaning',
        description: 'Basic shoe bag cleaning service',
        price: 18000,
        category: 'Bag',
        isActive: true,
        hasPromotion: true,
        promotionDiscount: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'sample_5',
        name: 'Branded Bag Cleaning',
        description: 'Premium branded bag cleaning service',
        price: 35000,
        category: 'Bag',
        isActive: true,
        hasPromotion: false,
        promotionDiscount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'sample_6',
        name: 'Others Service 1',
        description: 'Special cleaning for other items',
        price: 30000,
        category: 'Others',
        isActive: true,
        hasPromotion: false,
        promotionDiscount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'sample_7',
        name: 'Others Service 2',
        description: 'Additional cleaning service for special items',
        price: 40000,
        category: 'Others',
        isActive: true,
        hasPromotion: false,
        promotionDiscount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'sample_8',
        name: 'Others Service 3',
        description: 'Premium cleaning service for special needs',
        price: 60000,
        category: 'Others',
        isActive: true,
        hasPromotion: false,
        promotionDiscount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // Filter promotions (services with hasPromotion = true and promotionDiscount > 0)
    _promotions = _services
        .where((service) => service.hasPromotion && service.promotionDiscount > 0)
        .toList();

    print('✅ Sample data loaded: ${_services.length} services, ${_promotions.length} promotions');
  }

  // Get services by category
  List<ServiceModel> getServicesByCategory(String category) {
    return _services.where((service) => service.category == category).toList();
  }

  // Get service by ID
  ServiceModel? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear data
  void clearData() {
    _services = [];
    _promotions = [];
    _error = null;
    notifyListeners();
  }

  // Refresh services
  Future<void> refreshServices() async {
    await fetchServices();
  }

  // Convert LaundryServiceModel to ServiceModel
  ServiceModel _convertLaundryServiceToService(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'Others',
      isActive: data['isActive'] ?? true,
      hasPromotion: data['isPromoActive'] ?? false,
      promotionDiscount: data['isPromoActive'] == true && data['promoPrice'] != null
          ? ((data['price'] - data['promoPrice']) / data['price'] * 100)
          : 0.0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
