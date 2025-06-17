import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/order_service.dart';

enum ServiceType { selfService, delivery }
enum PaymentMethod { qris, cash, bankTransfer }

class CheckoutProvider extends ChangeNotifier {
  ServiceType _selectedServiceType = ServiceType.selfService;
  PaymentMethod? _selectedPaymentMethod; // Tidak ada default selection
  String _deliveryAddress = 'Jl. Kalimantan No. 37, Jember, Jawa Timur';
  LatLng? _deliveryLocation;
  double _totalAmount = 0.0;
  bool _isProcessingPayment = false;
  List<String> _selectedItems = [];
  String? _lastOrderId;
  String? _laundryPhotoUrl;
  String? _paymentProofUrl;

  // Getters
  ServiceType get selectedServiceType => _selectedServiceType;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  String get deliveryAddress => _deliveryAddress;
  LatLng? get deliveryLocation => _deliveryLocation;
  double get totalAmount => _totalAmount;
  bool get isProcessingPayment => _isProcessingPayment;
  List<String> get selectedItems => _selectedItems;
  String? get lastOrderId => _lastOrderId;
  String? get laundryPhotoUrl => _laundryPhotoUrl;
  String? get paymentProofUrl => _paymentProofUrl;

  // Service type methods
  void setServiceType(ServiceType serviceType) {
    _selectedServiceType = serviceType;
    notifyListeners();
  }

  bool get isDeliveryService => _selectedServiceType == ServiceType.delivery;
  bool get isSelfService => _selectedServiceType == ServiceType.selfService;

  // Payment method methods
  void setPaymentMethod(PaymentMethod? paymentMethod) {
    // Toggle payment method - jika sama dengan yang sudah dipilih, unselect
    if (_selectedPaymentMethod == paymentMethod) {
      _selectedPaymentMethod = null;
    } else {
      _selectedPaymentMethod = paymentMethod;
    }
    notifyListeners();
  }

  String get paymentMethodName {
    switch (_selectedPaymentMethod) {
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case null:
        return 'No payment method selected';
    }
  }

  // Delivery address methods
  void setDeliveryAddress(String address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  void setDeliveryLocation(LatLng location) {
    _deliveryLocation = location;
    notifyListeners();
  }

  void setDeliveryAddressWithLocation(String address, LatLng? location) {
    _deliveryAddress = address;
    _deliveryLocation = location;
    notifyListeners();
  }

  // Total amount methods
  void setTotalAmount(double amount) {
    _totalAmount = amount;
    notifyListeners();
  }

  void addToTotal(double amount) {
    _totalAmount += amount;
    notifyListeners();
  }

  void subtractFromTotal(double amount) {
    _totalAmount = (_totalAmount - amount).clamp(0.0, double.infinity);
    notifyListeners();
  }

  // Items management
  void setSelectedItems(List<String> items) {
    _selectedItems = items;
    notifyListeners();
  }

  void addItem(String item) {
    if (!_selectedItems.contains(item)) {
      _selectedItems.add(item);
      notifyListeners();
    }
  }

  void removeItem(String item) {
    _selectedItems.remove(item);
    notifyListeners();
  }

  // Photo URL methods
  void setLaundryPhotoUrl(String? url) {
    _laundryPhotoUrl = url;
    notifyListeners();
  }

  void setPaymentProofUrl(String? url) {
    _paymentProofUrl = url;
    notifyListeners();
  }

  // Create order in Firebase
  Future<bool> createOrder() async {
    if (!isValidForCheckout) return false;

    _isProcessingPayment = true;
    notifyListeners();

    try {
      // Debug logging sebelum create order
      print('🔍 DEBUG CheckoutProvider.createOrder:');
      print('📷 Laundry Photo URL: $_laundryPhotoUrl');
      print('💳 Payment Proof URL: $_paymentProofUrl');
      print('💰 Total Price: $grandTotal');

      final orderId = await OrderService.createOrder(
        items: _selectedItems.isNotEmpty ? _selectedItems : ['Shoe Wash'], // Default item if empty
        totalPrice: grandTotal,
        serviceType: _selectedServiceType == ServiceType.selfService ? 'Self Service' : 'Delivery Service',
        paymentMethod: paymentMethodName,
        deliveryAddress: isDeliveryService ? _deliveryAddress : null,
        deliveryLat: _deliveryLocation?.latitude,
        deliveryLng: _deliveryLocation?.longitude,
        laundryPhotoUrl: _laundryPhotoUrl,
        paymentProofUrl: _paymentProofUrl,
      );

      if (orderId != null) {
        _lastOrderId = orderId;
        _isProcessingPayment = false;
        notifyListeners();
        return true;
      } else {
        _isProcessingPayment = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error creating order: $e');
      _isProcessingPayment = false;
      notifyListeners();
      return false;
    }
  }

  // Update proof image for last order
  Future<bool> updateProofImage(String imageUrl) async {
    if (_lastOrderId == null) return false;

    try {
      return await OrderService.updateProofImage(_lastOrderId!, imageUrl);
    } catch (e) {
      print('Error updating proof image: $e');
      return false;
    }
  }

  // Payment processing (legacy method - now calls createOrder)
  Future<bool> processPayment() async {
    return await createOrder();
  }

  // Validation
  bool get isValidForCheckout {
    if (_totalAmount <= 0) return false;
    if (isDeliveryService && _deliveryAddress.isEmpty) return false;
    if (_selectedPaymentMethod == null) return false;
    return true;
  }

  String? get validationError {
    if (_totalAmount <= 0) return 'Total amount must be greater than 0';
    if (isDeliveryService && _deliveryAddress.isEmpty) return 'Please select delivery address';
    if (_selectedPaymentMethod == null) return 'Please select payment method';
    return null;
  }

  // Reset checkout
  void resetCheckout() {
    _selectedServiceType = ServiceType.selfService;
    _selectedPaymentMethod = null;
    _deliveryAddress = 'Jl. Kalimantan No. 37, Jember, Jawa Timur';
    _deliveryLocation = null;
    _totalAmount = 0.0;
    _isProcessingPayment = false;
    _selectedItems.clear();
    _lastOrderId = null;
    _laundryPhotoUrl = null;
    _paymentProofUrl = null;
    notifyListeners();
  }

  // Calculate delivery fee (example logic)
  double get deliveryFee {
    if (isSelfService) return 0.0;
    
    // Base delivery fee
    double baseFee = 5000.0;
    
    // Add distance-based fee if location is available
    if (_deliveryLocation != null) {
      // This is a simplified calculation
      // In real app, you would calculate actual distance
      baseFee += 2000.0;
    }
    
    return baseFee;
  }

  double get grandTotal => _totalAmount + deliveryFee;
}
