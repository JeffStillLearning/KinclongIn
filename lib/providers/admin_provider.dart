import 'package:flutter/material.dart';
import '../models/laundry_service_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  // Services
  List<LaundryServiceModel> _services = [];
  bool _servicesLoading = false;
  String? _servicesError;

  // Orders
  List<OrderModel> _orders = [];
  bool _ordersLoading = false;
  String? _ordersError;

  // Customers
  List<UserModel> _customers = [];
  bool _customersLoading = false;
  String? _customersError;

  // Analytics
  double _totalRevenue = 0;
  int _totalOrders = 0;
  int _totalCustomers = 0;
  Map<String, int> _ordersByStatus = {};
  bool _analyticsLoading = false;

  // Admin status
  bool _isAdmin = false;
  bool _checkingAdminStatus = false;

  // Getters
  List<LaundryServiceModel> get services => _services;
  bool get servicesLoading => _servicesLoading;
  String? get servicesError => _servicesError;

  List<OrderModel> get orders => _orders;
  bool get ordersLoading => _ordersLoading;
  String? get ordersError => _ordersError;

  List<UserModel> get customers => _customers;
  bool get customersLoading => _customersLoading;
  String? get customersError => _customersError;

  double get totalRevenue => _totalRevenue;
  int get totalOrders => _totalOrders;
  int get totalCustomers => _totalCustomers;
  Map<String, int> get ordersByStatus => _ordersByStatus;
  bool get analyticsLoading => _analyticsLoading;

  bool get isAdmin => _isAdmin;
  bool get checkingAdminStatus => _checkingAdminStatus;

  // General loading state
  bool get isLoading => _servicesLoading || _ordersLoading || _customersLoading || _analyticsLoading;

  // Check admin status
  Future<void> checkAdminStatus() async {
    _checkingAdminStatus = true;
    notifyListeners();

    try {
      _isAdmin = await AdminService.isAdmin();
    } catch (e) {
      _isAdmin = false;
      print('Error checking admin status: $e');
    }

    _checkingAdminStatus = false;
    notifyListeners();
  }

  // SERVICES MANAGEMENT

  Future<void> loadServices() async {
    _servicesLoading = true;
    _servicesError = null;
    notifyListeners();

    try {
      _services = await AdminService.getAllServices();
    } catch (e) {
      _servicesError = 'Failed to load services: $e';
      print('Error loading services: $e');
    }

    _servicesLoading = false;
    notifyListeners();
  }

  Future<bool> addService(LaundryServiceModel service) async {
    try {
      final success = await AdminService.addService(service);
      if (success) {
        await loadServices(); // Refresh list
      }
      return success;
    } catch (e) {
      print('Error adding service: $e');
      return false;
    }
  }

  Future<bool> updateService(LaundryServiceModel service) async {
    try {
      final success = await AdminService.updateService(service);
      if (success) {
        await loadServices(); // Refresh list
      }
      return success;
    } catch (e) {
      print('Error updating service: $e');
      return false;
    }
  }



  Future<bool> deleteService(String serviceId) async {
    try {
      final success = await AdminService.deleteService(serviceId);
      if (success) {
        await loadServices(); // Refresh list
      }
      return success;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  Future<bool> toggleServiceStatus(String serviceId, bool isActive) async {
    try {
      final success = await AdminService.toggleServiceStatus(serviceId, isActive);
      if (success) {
        await loadServices(); // Refresh list
      }
      return success;
    } catch (e) {
      print('Error toggling service status: $e');
      return false;
    }
  }

  // PROMO MANAGEMENT

  Future<bool> addPromo(String serviceId, double promoPrice, String promoDescription) async {
    try {
      final success = await AdminService.addPromoToService(serviceId, promoPrice, promoDescription);
      if (success) {
        await loadServices(); // Refresh list
      }
      return success;
    } catch (e) {
      print('Error adding promo: $e');
      return false;
    }
  }

  Future<bool> removePromo(String serviceId) async {
    try {
      final success = await AdminService.removePromoFromService(serviceId);
      if (success) {
        await loadServices(); // Refresh list
      }
      return success;
    } catch (e) {
      print('Error removing promo: $e');
      return false;
    }
  }

  // ORDERS MANAGEMENT

  Future<void> loadOrders() async {
    _ordersLoading = true;
    _ordersError = null;
    notifyListeners();

    try {
      _orders = await AdminService.getAllOrders();
    } catch (e) {
      _ordersError = 'Failed to load orders: $e';
      print('Error loading orders: $e');
    }

    _ordersLoading = false;
    notifyListeners();
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final success = await AdminService.updateOrderStatus(orderId, newStatus);
      if (success) {
        await loadOrders(); // Refresh list
        await loadAnalytics(); // Refresh analytics
      }
      return success;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // CUSTOMERS MANAGEMENT

  Future<void> loadCustomers() async {
    _customersLoading = true;
    _customersError = null;
    notifyListeners();

    try {
      _customers = await AdminService.getAllCustomers();
    } catch (e) {
      _customersError = 'Failed to load customers: $e';
      print('Error loading customers: $e');
    }

    _customersLoading = false;
    notifyListeners();
  }

  // ANALYTICS

  Future<void> loadAnalytics() async {
    _analyticsLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        AdminService.getTotalRevenue(),
        AdminService.getTotalOrdersCount(),
        AdminService.getTotalCustomersCount(),
        AdminService.getOrdersByStatus(),
      ]);

      _totalRevenue = results[0] as double;
      _totalOrders = results[1] as int;
      _totalCustomers = results[2] as int;
      _ordersByStatus = results[3] as Map<String, int>;
    } catch (e) {
      print('Error loading analytics: $e');
    }

    _analyticsLoading = false;
    notifyListeners();
  }

  // REFRESH ALL DATA

  Future<void> refreshAllData() async {
    await Future.wait([
      loadServices(),
      loadOrders(),
      loadCustomers(),
      loadAnalytics(),
    ]);
  }

  // Clear data on logout
  void clearData() {
    _services = [];
    _orders = [];
    _customers = [];
    _totalRevenue = 0;
    _totalOrders = 0;
    _totalCustomers = 0;
    _ordersByStatus = {};
    _isAdmin = false;
    notifyListeners();
  }
}
