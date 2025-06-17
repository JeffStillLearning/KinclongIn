import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  priceHighest,
  priceLowest,
}

enum FilterOption {
  all,
  process,
  delivering,
}

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  SortOption _currentSort = SortOption.dateNewest;
  FilterOption _currentFilter = FilterOption.all;
  bool _isLoading = false;

  // Getters
  List<OrderModel> get filteredOrders => _filteredOrders;
  List<OrderModel> get allOrders => _allOrders;
  SortOption get currentSort => _currentSort;
  FilterOption get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;

  // Initialize with sample data
  OrderProvider() {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load orders from Firebase only
      _allOrders = await OrderService.getUserOrders();

      // Sort by date descending (newest first) since we can't do it in query
      _allOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      _applyFilterAndSort();
    } catch (e) {
      print('Error loading orders from Firebase: $e');
      _allOrders = []; // Empty list if Firebase fails
      _applyFilterAndSort();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(FilterOption filter) {
    _currentFilter = filter;
    _applyFilterAndSort();
    notifyListeners();
  }

  void setSort(SortOption sort) {
    _currentSort = sort;
    _applyFilterAndSort();
    notifyListeners();
  }

  void _applyFilterAndSort() {
    // Filter out completed orders (only show active orders)
    List<OrderModel> activeOrders = _allOrders.where((order) => order.status != OrderStatus.done).toList();

    // Apply filter
    List<OrderModel> filtered = activeOrders;

    switch (_currentFilter) {
      case FilterOption.all:
        filtered = activeOrders;
        break;
      case FilterOption.process:
        filtered = activeOrders.where((order) => order.status == OrderStatus.process).toList();
        break;
      case FilterOption.delivering:
        filtered = activeOrders.where((order) => order.status == OrderStatus.delivering).toList();
        break;
    }

    // Apply sort
    switch (_currentSort) {
      case SortOption.dateNewest:
        filtered.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        break;
      case SortOption.dateOldest:
        filtered.sort((a, b) => a.orderDate.compareTo(b.orderDate));
        break;
      case SortOption.priceHighest:
        filtered.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
        break;
      case SortOption.priceLowest:
        filtered.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
        break;
    }

    _filteredOrders = filtered;
  }

  String get sortText {
    switch (_currentSort) {
      case SortOption.dateNewest:
        return 'Newest First';
      case SortOption.dateOldest:
        return 'Oldest First';
      case SortOption.priceHighest:
        return 'Highest Price';
      case SortOption.priceLowest:
        return 'Lowest Price';
    }
  }

  String get filterText {
    switch (_currentFilter) {
      case FilterOption.all:
        return 'All Orders';
      case FilterOption.process:
        return 'Processing';
      case FilterOption.delivering:
        return 'Delivering';
    }
  }

  // Only count active orders (not completed)
  List<OrderModel> get activeOrders => _allOrders.where((order) => order.status != OrderStatus.done).toList();
  int get processCount => activeOrders.where((order) => order.status == OrderStatus.process).length;
  int get deliveringCount => activeOrders.where((order) => order.status == OrderStatus.delivering).length;

  Future<void> refreshOrders() async {
    await _loadOrders();
  }

  Future<OrderModel?> getOrderById(String id) async {
    try {
      // First try to find in local cache
      final localOrder = _allOrders.where((order) => order.id == id).firstOrNull;
      if (localOrder != null) {
        return localOrder;
      }

      // If not found locally, fetch from Firebase
      return await OrderService.getOrderById(id);
    } catch (e) {
      return null;
    }
  }
}
