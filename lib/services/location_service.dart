import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationAccuracy {
  lowest,
  low,
  medium,
  high,
  best,
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastKnownPosition;
  Timer? _backgroundTimer;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  LocationService._internal();

  factory LocationService() => _instance;

  // Initialize location service
  Future<void> initialize() async {
    await _initializeNotifications();
  }

  // Initialize notifications for background tracking
  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  // Check and request location permissions
  Future<bool> checkLocationPermissions() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // Request background location permission
    final backgroundStatus = await Permission.locationAlways.request();
    return backgroundStatus.isGranted;
  }

  // Get current location
  Future<Position?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeout,
  }) async {
    try {
      final hasPermission = await checkLocationPermissions();
      if (!hasPermission) {
        throw Exception('Location permissions not granted');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: _getLocationAccuracy(accuracy),
        timeLimit: timeout ?? const Duration(seconds: 15),
      );

      _lastKnownPosition = position;
      return position;
    } catch (e) {
      // Return last known position if available
      return _lastKnownPosition;
    }
  }

  // Get last known location
  Position? getLastKnownLocation() {
    return _lastKnownPosition;
  }

  // Start location tracking
  Future<StreamSubscription<Position>> startLocationTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
    int timeInterval = 5000, // milliseconds
    required Function(Position) onLocationUpdate,
    Function(String)? onError,
  }) async {
    try {
      final hasPermission = await checkLocationPermissions();
      if (!hasPermission) {
        throw Exception('Location permissions not granted');
      }

      final LocationSettings locationSettings = LocationSettings(
        accuracy: _getLocationAccuracy(accuracy),
        distanceFilter: distanceFilter,
        timeLimit: Duration(milliseconds: timeInterval),
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _lastKnownPosition = position;
          onLocationUpdate(position);
        },
        onError: (error) {
          onError?.call(error.toString());
        },
      );

      return _positionStreamSubscription!;
    } catch (e) {
      throw Exception('Failed to start location tracking: $e');
    }
  }

  // Stop location tracking
  Future<void> stopLocationTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // Start background location tracking (for journey tracking)
  Future<void> startBackgroundTracking({
    required String journeyId,
    int intervalMinutes = 1,
    required Function(Position, String) onLocationUpdate,
  }) async {
    try {
      final hasPermission = await checkLocationPermissions();
      if (!hasPermission) {
        throw Exception('Background location permissions not granted');
      }

      // Show persistent notification for background tracking
      await _showBackgroundTrackingNotification();

      _backgroundTimer = Timer.periodic(
        Duration(minutes: intervalMinutes),
        (timer) async {
          try {
            final position = await getCurrentLocation();
            if (position != null) {
              onLocationUpdate(position, journeyId);
            }
          } catch (e) {
            print('Background location update failed: $e');
          }
        },
      );
    } catch (e) {
      throw Exception('Failed to start background tracking: $e');
    }
  }

  // Stop background location tracking
  Future<void> stopBackgroundTracking() async {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    await _notificationsPlugin.cancel(1); // Cancel background notification
  }

  // Get address from coordinates
  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';
      }
      return null;
    } catch (e) {
      return null;
    }
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
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Calculate distance between two points
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Calculate bearing between two points
  double calculateBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Check if position is within a geofence
  bool isWithinGeofence({
    required Position currentPosition,
    required double centerLatitude,
    required double centerLongitude,
    required double radiusMeters,
  }) {
    final distance = calculateDistance(
      startLatitude: currentPosition.latitude,
      startLongitude: currentPosition.longitude,
      endLatitude: centerLatitude,
      endLongitude: centerLongitude,
    );
    return distance <= radiusMeters;
  }

  // Get location accuracy string
  String getAccuracyString(double accuracy) {
    if (accuracy <= 5) return 'Excellent';
    if (accuracy <= 10) return 'Good';
    if (accuracy <= 20) return 'Fair';
    if (accuracy <= 50) return 'Poor';
    return 'Very Poor';
  }

  // Check if location is mock/fake
  bool isMockLocation(Position position) {
    // This is a basic check - in production you might want more sophisticated detection
    return position.isMocked;
  }

  // Get location settings recommendations
  Map<String, dynamic> getLocationSettings() {
    return {
      'high_accuracy_mode': true,
      'background_location': true,
      'location_history': false, // For privacy
      'improve_accuracy': true,
      'scanning': true,
    };
  }

  // Show background tracking notification
  Future<void> _showBackgroundTrackingNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'location_tracking',
      'Location Tracking',
      channelDescription: 'SafeHer is tracking your location for safety',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      1,
      'SafeHer Location Tracking',
      'Your location is being tracked for safety purposes',
      notificationDetails,
    );
  }

  // Convert LocationAccuracy enum to Geolocator LocationAccuracy
  LocationAccuracy _getLocationAccuracy(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return LocationAccuracy.lowest;
      case LocationAccuracy.low:
        return LocationAccuracy.low;
      case LocationAccuracy.medium:
        return LocationAccuracy.medium;
      case LocationAccuracy.high:
        return LocationAccuracy.high;
      case LocationAccuracy.best:
        return LocationAccuracy.best;
    }
  }

  // Dispose resources
  void dispose() {
    _positionStreamSubscription?.cancel();
    _backgroundTimer?.cancel();
  }
}
