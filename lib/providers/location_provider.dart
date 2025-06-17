import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLocationPermission = false;

  // Getters
  LatLng? get currentLocation => _currentLocation;
  LatLng? get selectedLocation => _selectedLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLocationPermission => _hasLocationPermission;

  // Default location (Jember, Indonesia)
  static const LatLng defaultLocation = LatLng(-8.1652, 113.7231);

  LocationProvider() {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await checkLocationPermission();
    if (_hasLocationPermission) {
      await getCurrentLocation();
    } else {
      _currentLocation = defaultLocation;
      _selectedLocation = defaultLocation;
      notifyListeners();
    }
  }

  Future<bool> checkLocationPermission() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled. Please enable location services.';
        _hasLocationPermission = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permissions are denied';
          _hasLocationPermission = false;
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permissions are permanently denied, we cannot request permissions.';
        _hasLocationPermission = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _hasLocationPermission = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error checking location permission: $e';
      _hasLocationPermission = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (!_hasLocationPermission) {
        bool hasPermission = await checkLocationPermission();
        if (!hasPermission) return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      
      // Set selected location to current location if not already set
      if (_selectedLocation == null) {
        _selectedLocation = _currentLocation;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error getting current location: $e';
      _currentLocation = defaultLocation;
      _selectedLocation = defaultLocation;
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedLocation(LatLng location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String getLocationString(LatLng? location) {
    if (location == null) return 'No location selected';
    return 'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}';
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
