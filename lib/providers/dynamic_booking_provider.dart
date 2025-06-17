import 'package:flutter/material.dart';
import '../models/laundry_service_model.dart';

class DynamicBookingProvider with ChangeNotifier {
  Map<String, int> _selectedItems = {}; // serviceId -> quantity
  List<LaundryServiceModel> _selectedServices = [];
  double _totalPrice = 0.0;
  int _totalItems = 0;

  // Getters
  Map<String, int> get selectedItems => _selectedItems;
  List<LaundryServiceModel> get selectedServices => _selectedServices;
  double get totalPrice => _totalPrice;
  int get totalItems => _totalItems;
  bool get hasItems => _selectedItems.isNotEmpty;

  // Add or update service quantity
  void updateServiceQuantity(LaundryServiceModel service, int quantity) {
    if (quantity <= 0) {
      _selectedItems.remove(service.id);
      _selectedServices.removeWhere((s) => s.id == service.id);
    } else {
      _selectedItems[service.id] = quantity;
      
      // Update or add service to list
      final existingIndex = _selectedServices.indexWhere((s) => s.id == service.id);
      if (existingIndex >= 0) {
        _selectedServices[existingIndex] = service;
      } else {
        _selectedServices.add(service);
      }
    }
    
    _calculateTotals();
    notifyListeners();
  }

  // Increment service quantity
  void incrementService(LaundryServiceModel service) {
    final currentQuantity = _selectedItems[service.id] ?? 0;
    updateServiceQuantity(service, currentQuantity + 1);
  }

  // Decrement service quantity
  void decrementService(LaundryServiceModel service) {
    final currentQuantity = _selectedItems[service.id] ?? 0;
    if (currentQuantity > 0) {
      updateServiceQuantity(service, currentQuantity - 1);
    }
  }

  // Get quantity for specific service
  int getServiceQuantity(String serviceId) {
    return _selectedItems[serviceId] ?? 0;
  }

  // Calculate totals
  void _calculateTotals() {
    _totalPrice = 0.0;
    _totalItems = 0;
    
    for (var service in _selectedServices) {
      final quantity = _selectedItems[service.id] ?? 0;
      _totalPrice += service.finalPrice * quantity;
      _totalItems += quantity;
    }
  }

  // Get selected services with quantities for checkout
  List<Map<String, dynamic>> getSelectedServicesForCheckout() {
    return _selectedServices.map((service) {
      final quantity = _selectedItems[service.id] ?? 0;
      return {
        'service': service,
        'quantity': quantity,
        'unitPrice': service.finalPrice,
        'totalPrice': service.finalPrice * quantity,
        'serviceName': service.name,
        'serviceDescription': service.description,
        'hasPromo': service.hasPromo,
        'originalPrice': service.price,
        'promoPrice': service.promoPrice,
      };
    }).toList();
  }

  // Reset all selections
  void resetAll() {
    _selectedItems.clear();
    _selectedServices.clear();
    _totalPrice = 0.0;
    _totalItems = 0;
    notifyListeners();
  }

  // Get booking summary for display
  String getBookingSummary() {
    if (_selectedServices.isEmpty) return 'No items selected';
    
    final itemsText = _totalItems == 1 ? 'item' : 'items';
    return '$_totalItems $itemsText - Rp ${_totalPrice.toStringAsFixed(0)}';
  }

  // Validate if booking is ready for next step
  bool isReadyForNext() {
    return _selectedItems.isNotEmpty && _totalItems > 0;
  }

  // Get detailed breakdown for receipt/confirmation
  Map<String, dynamic> getBookingDetails() {
    return {
      'selectedItems': _selectedItems,
      'selectedServices': _selectedServices,
      'totalPrice': _totalPrice,
      'totalItems': _totalItems,
      'servicesBreakdown': getSelectedServicesForCheckout(),
      'bookingSummary': getBookingSummary(),
      'timestamp': DateTime.now(),
    };
  }

  // Load from existing booking data (if needed for edit)
  void loadFromBookingData(Map<String, dynamic> bookingData) {
    resetAll();
    
    if (bookingData['selectedItems'] != null) {
      _selectedItems = Map<String, int>.from(bookingData['selectedItems']);
    }
    
    if (bookingData['selectedServices'] != null) {
      _selectedServices = List<LaundryServiceModel>.from(
        bookingData['selectedServices']
      );
    }
    
    _calculateTotals();
    notifyListeners();
  }

  // Debug info
  void printDebugInfo() {
    print('=== Dynamic Booking Debug ===');
    print('Selected Items: $_selectedItems');
    print('Total Items: $_totalItems');
    print('Total Price: $_totalPrice');
    print('Services Count: ${_selectedServices.length}');
    for (var service in _selectedServices) {
      final qty = _selectedItems[service.id] ?? 0;
      print('- ${service.name}: $qty x Rp${service.finalPrice} = Rp${service.finalPrice * qty}');
    }
    print('=============================');
  }
}
