import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // Additional getters for profile
  String? get username => _currentUser?.username;
  String? get email => _currentUser?.email;
  String? get role => 'Customer'; // Default role for customer app

  // Setter for username
  void setUsername(String newUsername) {
    if (_currentUser != null) {
      _currentUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: _currentUser!.displayName,
        username: newUsername,
        phoneNumber: _currentUser!.phoneNumber,
        profileImageUrl: _currentUser!.profileImageUrl,
        addresses: _currentUser!.addresses,
        preferences: _currentUser!.preferences,
        totalOrders: _currentUser!.totalOrders,
        totalSpent: _currentUser!.totalSpent,
        memberSince: _currentUser!.memberSince,
        lastOrderDate: _currentUser!.lastOrderDate,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Initialize user data
  Future<void> initializeUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Initializing user...');
      _currentUser = await UserService.getCurrentUser();

      if (_currentUser != null) {
        print('✅ User initialized: ${_currentUser!.uid}');
        print('📧 Email: ${_currentUser!.email}');
        print('👤 Username: ${_currentUser!.username}');
      } else {
        print('❌ Failed to initialize user - currentUser is null');
      }
    } catch (e) {
      _error = 'Failed to load user data: $e';
      print('Error initializing user: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      _currentUser = await UserService.getCurrentUser();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh user data: $e';
      print('Error refreshing user: $e');
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? username,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) {
      print('Error: Current user is null');
      return false;
    }

    if (_currentUser!.uid.isEmpty) {
      print('Error: Current user UID is empty');
      return false;
    }

    try {
      print('Updating profile for user: ${_currentUser!.uid}');

      final updatedUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: displayName ?? _currentUser!.displayName,
        username: username ?? _currentUser!.username,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        addresses: _currentUser!.addresses,
        preferences: _currentUser!.preferences,
        totalOrders: _currentUser!.totalOrders,
        totalSpent: _currentUser!.totalSpent,
        memberSince: _currentUser!.memberSince,
        lastOrderDate: _currentUser!.lastOrderDate,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await UserService.updateUserProfile(updatedUser);
      if (success) {
        _currentUser = updatedUser;
        _error = null;
        notifyListeners();
        print('Profile updated successfully in provider');
      } else {
        print('Failed to update profile in service');
      }
      return success;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      print('Error updating profile: $e');
      return false;
    }
  }

  // Add address
  Future<bool> addAddress(UserAddress address) async {
    if (_currentUser == null) return false;

    try {
      final success = await UserService.addAddress(_currentUser!.uid, address);
      if (success) {
        await refreshUser(); // Refresh to get updated addresses
      }
      return success;
    } catch (e) {
      _error = 'Failed to add address: $e';
      print('Error adding address: $e');
      return false;
    }
  }

  // Update preferences
  Future<bool> updatePreferences(UserPreferences preferences) async {
    if (_currentUser == null) return false;

    try {
      final success = await UserService.updatePreferences(_currentUser!.uid, preferences);
      if (success) {
        final updatedUser = UserModel(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          displayName: _currentUser!.displayName,
          username: _currentUser!.username,
          phoneNumber: _currentUser!.phoneNumber,
          profileImageUrl: _currentUser!.profileImageUrl,
          addresses: _currentUser!.addresses,
          preferences: preferences,
          totalOrders: _currentUser!.totalOrders,
          totalSpent: _currentUser!.totalSpent,
          memberSince: _currentUser!.memberSince,
          lastOrderDate: _currentUser!.lastOrderDate,
          createdAt: _currentUser!.createdAt,
          updatedAt: DateTime.now(),
        );
        _currentUser = updatedUser;
        _error = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to update preferences: $e';
      print('Error updating preferences: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await UserService.signOut();
      _currentUser = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sign out: $e';
      print('Error signing out: $e');
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      final success = await UserService.deleteUserAccount();
      if (success) {
        _currentUser = null;
        _error = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete account: $e';
      print('Error deleting account: $e');
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Listen to auth state changes
  void listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _currentUser = null;
        notifyListeners();
      } else {
        initializeUser();
      }
    });
  }
}
