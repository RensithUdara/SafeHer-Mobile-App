import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/safe_place_model.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';

class LocationController extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Position? _currentPosition;
  String _currentAddress = '';
  bool _isTracking = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<SafePlaceModel> _safePlaces = [];
  bool _locationPermissionGranted = false;
  bool _backgroundLocationEnabled = false;

  // Getters
  Position? get currentPosition => _currentPosition;
  String get currentAddress => _currentAddress;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SafePlaceModel> get safePlaces => _safePlaces;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get backgroundLocationEnabled => _backgroundLocationEnabled;
  double? get latitude => _currentPosition?.latitude;
  double? get longitude => _currentPosition?.longitude;

  LocationController() {
    _initializeLocation();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _initializeLocation() async {
    await _checkPermissions();
    await _loadSafePlaces();
    if (_locationPermissionGranted) {
      await getCurrentLocation();
    }
  }

  // Check and request location permissions
  Future<bool> _checkPermissions() async {
    try {
      final status = await Permission.location.status;

      if (status.isDenied) {
        final result = await Permission.location.request();
        _locationPermissionGranted = result.isGranted;
      } else {
        _locationPermissionGranted = status.isGranted;
      }

      // Check background location permission
      if (_locationPermissionGranted) {
        final backgroundStatus = await Permission.locationAlways.status;
        if (backgroundStatus.isDenied) {
          final backgroundResult = await Permission.locationAlways.request();
          _backgroundLocationEnabled = backgroundResult.isGranted;
        } else {
          _backgroundLocationEnabled = backgroundStatus.isGranted;
        }
      }

      notifyListeners();
      return _locationPermissionGranted;
    } catch (e) {
      _setError('Failed to check permissions: ${e.toString()}');
      return false;
    }
  }

  // Get current location
  Future<bool> getCurrentLocation() async {
    if (!_locationPermissionGranted) {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        _setError('Location permission not granted');
        return false;
      }
    }

    _setLoading(true);
    _setError(null);

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _currentPosition = position;
        await _getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        // Save last known location
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('last_latitude', position.latitude);
        await prefs.setDouble('last_longitude', position.longitude);

        notifyListeners();
        return true;
      }
    } catch (e) {
      _setError('Failed to get location: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // Get address from coordinates
  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _currentAddress =
            '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      _currentAddress = 'Address unavailable';
    }
  }

  // Start location tracking
  Future<bool> startLocationTracking() async {
    if (!_locationPermissionGranted) {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) return false;
    }

    try {
      _isTracking = true;
      notifyListeners();

      await _locationService.startLocationTracking(
        onLocationUpdate: (position) {
          _currentPosition = position;
          _getAddressFromCoordinates(position.latitude, position.longitude);
          notifyListeners();
        },
      );

      return true;
    } catch (e) {
      _setError('Failed to start location tracking: ${e.toString()}');
      _isTracking = false;
      notifyListeners();
      return false;
    }
  }

  // Stop location tracking
  Future<void> stopLocationTracking() async {
    try {
      await _locationService.stopLocationTracking();
      _isTracking = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to stop location tracking: ${e.toString()}');
    }
  }

  // Share location with emergency contacts
  Future<bool> shareLocationWithContacts(List<String> contactIds,
      {int? durationMinutes}) async {
    if (_currentPosition == null) {
      await getCurrentLocation();
      if (_currentPosition == null) {
        _setError('Unable to get current location');
        return false;
      }
    }

    _setLoading(true);
    try {
      final locationData = {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'address': _currentAddress,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'shared_with': contactIds,
        'duration_minutes': durationMinutes,
        'is_active': true,
      };

      await _firebaseService.shareLocation(locationData);

      // Set timer to stop sharing if duration is specified
      if (durationMinutes != null) {
        Future.delayed(Duration(minutes: durationMinutes), () {
          stopLocationSharing();
        });
      }

      return true;
    } catch (e) {
      _setError('Failed to share location: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Stop location sharing
  Future<void> stopLocationSharing() async {
    try {
      await _firebaseService.stopLocationSharingGeneric();
    } catch (e) {
      _setError('Failed to stop location sharing: ${e.toString()}');
    }
  }

  // Add safe place
  Future<bool> addSafePlace({
    required String name,
    required String address,
    double? latitude,
    double? longitude,
    String? placeType,
  }) async {
    _setLoading(true);
    try {
      final safePlace = SafePlaceModel(
        placeName: name,
        address: address,
        latitude: latitude ?? _currentPosition?.latitude ?? 0.0,
        longitude: longitude ?? _currentPosition?.longitude ?? 0.0,
        placeType: placeType != null 
          ? SafePlaceType.values.firstWhere(
              (e) => e.toString().split('.').last == placeType,
              orElse: () => SafePlaceType.other,
            )
          : SafePlaceType.other,
        savedAt: DateTime.now(),
      );

      // Save to local database
      await _databaseHelper.insertSafePlace(safePlace);

      // Save to Firebase
      await _firebaseService.saveSafePlace(safePlace);

      _safePlaces.add(safePlace);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add safe place: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load safe places
  Future<void> _loadSafePlaces() async {
    try {
      _safePlaces = await _databaseHelper.getSafePlaces();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading safe places: $e');
    }
  }

  // Remove safe place
  Future<bool> removeSafePlace(int placeId) async {
    try {
      await _databaseHelper.deleteSafePlace(placeId);
      await _firebaseService.deleteSafePlace(placeId.toString());

      _safePlaces.removeWhere((place) => place.placeId == placeId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove safe place: ${e.toString()}');
      return false;
    }
  }

  // Get distance to safe place
  double getDistanceToSafePlace(SafePlaceModel safePlace) {
    if (_currentPosition == null) return double.infinity;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      safePlace.latitude,
      safePlace.longitude,
    );
  }

  // Find nearest safe place
  SafePlaceModel? getNearestSafePlace() {
    if (_safePlaces.isEmpty || _currentPosition == null) return null;

    SafePlaceModel? nearest;
    double minDistance = double.infinity;

    for (final place in _safePlaces) {
      final distance = getDistanceToSafePlace(place);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = place;
      }
    }

    return nearest;
  }

  // Check if in safe zone
  bool isInSafeZone({double radiusMeters = 100}) {
    if (_currentPosition == null || _safePlaces.isEmpty) return false;

    for (final place in _safePlaces) {
      final distance = getDistanceToSafePlace(place);
      if (distance <= radiusMeters) return true;
    }

    return false;
  }

  // Get coordinates from address
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
    }
    return null;
  }

  // Request background location permission
  Future<bool> requestBackgroundLocationPermission() async {
    try {
      final status = await Permission.locationAlways.request();
      _backgroundLocationEnabled = status.isGranted;
      notifyListeners();
      return _backgroundLocationEnabled;
    } catch (e) {
      _setError(
          'Failed to request background location permission: ${e.toString()}');
      return false;
    }
  }

  // Enable high accuracy mode
  Future<void> enableHighAccuracyMode() async {
    await _locationService.enableHighAccuracyMode();
  }

  // Get last known location from preferences
  Future<Position?> getLastKnownLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble('last_latitude');
      final longitude = prefs.getDouble('last_longitude');

      if (latitude != null && longitude != null) {
        return Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (e) {
      debugPrint('Error getting last known location: $e');
    }
    return null;
  }

  void clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}
