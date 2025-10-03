import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../database/database_helper.dart';
import '../models/journey_model.dart';
import '../services/location_service.dart';

enum JourneyType { walking, driving, publicTransport, cycling, other }

class JourneyController extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  JourneyModel? _activeJourney;
  List<JourneyModel> _journeyHistory = [];
  List<Position> _routeCoordinates = [];
  bool _isTracking = false;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _journeyTimer;
  Timer? _locationUpdateTimer;
  StreamSubscription<Position>? _positionStream;

  // Journey settings
  int _checkInIntervalMinutes = 15;
  int _overdueAlertMinutes = 30;
  bool _autoStartTracking = true;
  bool _shareLocationDuringJourney = true;
  bool _enableRouteDeviation = true;
  double _routeDeviationThreshold = 500; // meters

  // Getters
  JourneyModel? get activeJourney => _activeJourney;
  List<JourneyModel> get journeyHistory => _journeyHistory;
  List<Position> get routeCoordinates => _routeCoordinates;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveJourney =>
      _activeJourney != null && _activeJourney!.status == JourneyStatus.active;

  // Settings getters
  int get checkInIntervalMinutes => _checkInIntervalMinutes;
  int get overdueAlertMinutes => _overdueAlertMinutes;
  bool get autoStartTracking => _autoStartTracking;
  bool get shareLocationDuringJourney => _shareLocationDuringJourney;
  bool get enableRouteDeviation => _enableRouteDeviation;
  double get routeDeviationThreshold => _routeDeviationThreshold;

  JourneyController() {
    _initializeJourney();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _initializeJourney() async {
    await _loadJourneyHistory();
    await _checkForActiveJourney();
  }

  // Load journey history
  Future<void> _loadJourneyHistory() async {
    try {
      final db = await _databaseHelper.database;
      final journeyMaps = await db.query(
        'journey_history_table',
        orderBy: 'start_time DESC',
      );
      _journeyHistory =
          journeyMaps.map((map) => JourneyModel.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading journey history: $e');
    }
  }

  // Check for active journey (in case app was closed during journey)
  Future<void> _checkForActiveJourney() async {
    try {
      final activeJourneys = _journeyHistory
          .where((journey) => journey.status == JourneyStatus.active)
          .toList();

      if (activeJourneys.isNotEmpty) {
        _activeJourney = activeJourneys.first;
        await _resumeActiveJourney();
      }
    } catch (e) {
      debugPrint('Error checking for active journey: $e');
    }
  }

  // Resume active journey after app restart
  Future<void> _resumeActiveJourney() async {
    if (_activeJourney == null) return;

    _isTracking = true;
    await _startLocationTracking();
    await _startJourneyTimer();
    notifyListeners();
  }

  // Start a new journey
  Future<bool> startJourney({
    required String startLocation,
    required String endLocation,
    required DateTime expectedArrivalTime,
    JourneyType journeyType = JourneyType.walking,
    List<String>? emergencyContactIds,
    String? notes,
  }) async {
    if (hasActiveJourney) {
      _setError('A journey is already active');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      // Get current location
      final currentPosition = await _locationService.getCurrentLocation();
      if (currentPosition == null) {
        _setError('Unable to get current location');
        return false;
      }

      // Create new journey
      final journey = JourneyModel(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        title: startLocation,
        startLatitude: currentPosition.latitude,
        startLongitude: currentPosition.longitude,
        startAddress: startLocation,
        endAddress: endLocation,
        startTime: DateTime.now(),
        estimatedArrival: expectedArrivalTime,
        status: JourneyStatus.active,
        routeCoordinates: [],
        notes: notes,
      );

      // Save to database
      final db = await _databaseHelper.database;
      final journeyId =
          await db.insert('journey_history_table', journey.toMap());

      // Create journey with ID
      final journeyWithId = journey.copyWith(id: journeyId.toString());

      // Save to Firebase
      await _saveJourneyToFirebase(journeyWithId);

      _activeJourney = journeyWithId;
      _routeCoordinates = [currentPosition];

      // Start tracking if enabled
      if (_autoStartTracking) {
        await _startLocationTracking();
      }

      // Start journey timer
      await _startJourneyTimer();

      // Share location with emergency contacts if enabled
      if (_shareLocationDuringJourney &&
          emergencyContactIds != null &&
          emergencyContactIds.isNotEmpty) {
        // Implementation depends on LocationController
        // await locationController.shareLocationWithContacts(emergencyContactIds);
      }

      // Send notification to emergency contacts
      await _notifyEmergencyContactsJourneyStarted();

      _isTracking = true;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to start journey: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Start location tracking
  Future<void> _startLocationTracking() async {
    try {
      await _locationService.startLocationTracking(
        onLocationUpdate: (Position position) {
          _routeCoordinates.add(position);
          _updateJourneyLocation(position);

          // Check for route deviation
          if (_enableRouteDeviation) {
            _checkRouteDeviation(position);
          }

          notifyListeners();
        },
        onError: (error) {
          debugPrint('Location tracking error: $error');
        },
      );
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
    }
  }

  // Update journey location
  Future<void> _updateJourneyLocation(Position position) async {
    if (_activeJourney == null) return;

    try {
      final routeCoordinates = _routeCoordinates
          .map((pos) => {
                'lat': pos.latitude,
                'lng': pos.longitude,
              })
          .toList();

      final updatedJourney = _activeJourney!.copyWith(
        routeCoordinates: routeCoordinates,
      );

      await _updateJourneyInDatabase(updatedJourney);
      await _updateJourneyInFirebase(updatedJourney);

      _activeJourney = updatedJourney;
    } catch (e) {
      debugPrint('Error updating journey location: $e');
    }
  }

  // Check for route deviation
  void _checkRouteDeviation(Position currentPosition) {
    if (_routeCoordinates.length < 2) return;

    // Simple deviation check - compare with expected route
    final previousPosition = _routeCoordinates[_routeCoordinates.length - 2];
    final deviation = Geolocator.distanceBetween(
      previousPosition.latitude,
      previousPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    if (deviation > _routeDeviationThreshold) {
      _handleRouteDeviation(currentPosition, deviation);
    }
  }

  // Handle route deviation
  Future<void> _handleRouteDeviation(
      Position position, double deviation) async {
    try {
      await _showRouteDeviationAlert(
        deviation: deviation,
        currentLocation: '${position.latitude}, ${position.longitude}',
      );

      // Optionally notify emergency contacts
      await _notifyEmergencyContactsDeviation(position, deviation);
    } catch (e) {
      debugPrint('Error handling route deviation: $e');
    }
  }

  // Start journey timer
  Future<void> _startJourneyTimer() async {
    if (_activeJourney == null || _activeJourney!.estimatedArrival == null)
      return;

    final expectedDuration =
        _activeJourney!.estimatedArrival!.difference(DateTime.now());
    if (expectedDuration.inMinutes <= 0) return;

    // Set up check-in intervals
    _journeyTimer = Timer.periodic(
      Duration(minutes: _checkInIntervalMinutes),
      (timer) => _handleCheckIn(),
    );

    // Set up overdue alert
    Timer(
      expectedDuration + Duration(minutes: _overdueAlertMinutes),
      () => _handleOverdueJourney(),
    );
  }

  // Handle check-in
  Future<void> _handleCheckIn() async {
    if (!hasActiveJourney) return;

    try {
      await _showJourneyCheckInNotification();

      // Send periodic update to emergency contacts
      await _notifyEmergencyContactsCheckIn();
    } catch (e) {
      debugPrint('Error handling check-in: $e');
    }
  }

  // Handle overdue journey
  Future<void> _handleOverdueJourney() async {
    if (!hasActiveJourney) return;

    try {
      // Update journey status
      final updatedJourney = _activeJourney!.copyWith(
        status: JourneyStatus.overdue,
      );

      await _updateJourneyInDatabase(updatedJourney);
      await _updateJourneyInFirebase(updatedJourney);

      _activeJourney = updatedJourney;

      // Notify emergency contacts
      await _notifyEmergencyContactsOverdue();

      // Show overdue notification
      await _showJourneyOverdueAlert();

      notifyListeners();
    } catch (e) {
      debugPrint('Error handling overdue journey: $e');
    }
  }

  // Complete journey
  Future<bool> completeJourney({String? notes}) async {
    if (!hasActiveJourney) {
      _setError('No active journey to complete');
      return false;
    }

    _setLoading(true);
    try {
      // Get current location for end coordinates
      final currentPosition = await _locationService.getCurrentLocation();

      final completedJourney = _activeJourney!.copyWith(
        endTime: DateTime.now(),
        status: JourneyStatus.completed,
        endLatitude: currentPosition?.latitude,
        endLongitude: currentPosition?.longitude,
        notes: notes ?? _activeJourney!.notes,
      );

      await _updateJourneyInDatabase(completedJourney);
      await _updateJourneyInFirebase(completedJourney);

      // Stop tracking
      await _stopLocationTracking();

      // Cancel timers
      _journeyTimer?.cancel();

      // Notify emergency contacts
      await _notifyEmergencyContactsJourneyCompleted();

      _activeJourney = null;
      _routeCoordinates.clear();
      _isTracking = false;

      // Reload history
      await _loadJourneyHistory();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to complete journey: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel journey
  Future<bool> cancelJourney({String? reason}) async {
    if (!hasActiveJourney) {
      _setError('No active journey to cancel');
      return false;
    }

    _setLoading(true);
    try {
      final cancelledJourney = _activeJourney!.copyWith(
        endTime: DateTime.now(),
        status: JourneyStatus.cancelled,
        notes: reason ?? 'Journey cancelled',
      );

      await _updateJourneyInDatabase(cancelledJourney);
      await _updateJourneyInFirebase(cancelledJourney);

      // Stop tracking
      await _stopLocationTracking();

      // Cancel timers
      _journeyTimer?.cancel();

      // Notify emergency contacts
      await _notifyEmergencyContactsJourneyCancelled(reason);

      _activeJourney = null;
      _routeCoordinates.clear();
      _isTracking = false;

      // Reload history
      await _loadJourneyHistory();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to cancel journey: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Stop location tracking
  Future<void> _stopLocationTracking() async {
    try {
      await _locationService.stopLocationTracking();
      await _positionStream?.cancel();
      _positionStream = null;
    } catch (e) {
      debugPrint('Error stopping location tracking: $e');
    }
  }

  // Extend journey time
  Future<bool> extendJourneyTime(Duration extension) async {
    if (!hasActiveJourney || _activeJourney!.estimatedArrival == null)
      return false;

    try {
      final extendedJourney = _activeJourney!.copyWith(
        estimatedArrival: _activeJourney!.estimatedArrival!.add(extension),
      );

      await _updateJourneyInDatabase(extendedJourney);
      await _updateJourneyInFirebase(extendedJourney);

      _activeJourney = extendedJourney;

      // Notify emergency contacts about extension
      await _notifyEmergencyContactsTimeExtended(extension);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to extend journey time: ${e.toString()}');
      return false;
    }
  }

  // Database helper methods
  Future<void> _updateJourneyInDatabase(JourneyModel journey) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'journey_history_table',
        journey.toMap(),
        where: 'id = ?',
        whereArgs: [journey.id],
      );
    } catch (e) {
      debugPrint('Error updating journey in database: $e');
    }
  }

  // Firebase helper methods
  Future<void> _saveJourneyToFirebase(JourneyModel journey) async {
    try {
      // Implementation depends on FirebaseService
      // await _firebaseService.saveJourney(journey);
    } catch (e) {
      debugPrint('Error saving journey to Firebase: $e');
    }
  }

  Future<void> _updateJourneyInFirebase(JourneyModel journey) async {
    try {
      // Implementation depends on FirebaseService
      // await _firebaseService.updateJourney(journey);
    } catch (e) {
      debugPrint('Error updating journey in Firebase: $e');
    }
  }

  // Notification helper methods
  Future<void> _showRouteDeviationAlert({
    required double deviation,
    required String currentLocation,
  }) async {
    try {
      // Implementation depends on NotificationService
      // await _notificationService.showRouteDeviationAlert(
      //   deviation: deviation,
      //   currentLocation: currentLocation,
      // );
    } catch (e) {
      debugPrint('Error showing route deviation alert: $e');
    }
  }

  Future<void> _showJourneyCheckInNotification() async {
    try {
      // Implementation depends on NotificationService
      // await _notificationService.showJourneyCheckInNotification();
    } catch (e) {
      debugPrint('Error showing check-in notification: $e');
    }
  }

  Future<void> _showJourneyOverdueAlert() async {
    try {
      // Implementation depends on NotificationService
      // await _notificationService.showJourneyOverdueAlert();
    } catch (e) {
      debugPrint('Error showing overdue alert: $e');
    }
  }

  // Emergency contact notification methods
  Future<void> _notifyEmergencyContactsJourneyStarted() async {
    try {
      if (_activeJourney != null) {
        // Implementation depends on NotificationService
        // await _notificationService.notifyContactsJourneyStarted(_activeJourney!);
      }
    } catch (e) {
      debugPrint('Error notifying contacts about journey start: $e');
    }
  }

  Future<void> _notifyEmergencyContactsDeviation(
      Position position, double deviation) async {
    try {
      if (_activeJourney != null) {
        // Implementation depends on NotificationService
        // await _notificationService.notifyContactsRouteDeviation(
        //   position: position,
        //   deviation: deviation,
        //   journey: _activeJourney!,
        // );
      }
    } catch (e) {
      debugPrint('Error notifying contacts about deviation: $e');
    }
  }

  Future<void> _notifyEmergencyContactsCheckIn() async {
    try {
      if (_activeJourney != null) {
        // Implementation depends on NotificationService
        // await _notificationService.notifyContactsJourneyCheckIn(_activeJourney!);
      }
    } catch (e) {
      debugPrint('Error notifying contacts about check-in: $e');
    }
  }

  Future<void> _notifyEmergencyContactsOverdue() async {
    try {
      if (_activeJourney != null) {
        // Implementation depends on NotificationService
        // await _notificationService.notifyContactsJourneyOverdue(_activeJourney!);
      }
    } catch (e) {
      debugPrint('Error notifying contacts about overdue journey: $e');
    }
  }

  Future<void> _notifyEmergencyContactsJourneyCompleted() async {
    try {
      if (_activeJourney != null) {
        // Implementation depends on NotificationService
        // await _notificationService.notifyContactsJourneyCompleted(_activeJourney!);
      }
    } catch (e) {
      debugPrint('Error notifying contacts about journey completion: $e');
    }
  }

  Future<void> _notifyEmergencyContactsJourneyCancelled(String? reason) async {
    try {
      if (_activeJourney != null) {
        // Implementation depends on NotificationService
        // await _notificationService.notifyContactsJourneyCancelled(_activeJourney!, reason);
      }
    } catch (e) {
      debugPrint('Error notifying contacts about journey cancellation: $e');
    }
  }

  Future<void> _notifyEmergencyContactsTimeExtended(Duration extension) async {
    try {
      if (_activeJourney != null) {
        // Implementation depends on NotificationService
        // await _notificationService.notifyContactsJourneyTimeExtended(_activeJourney!, extension);
      }
    } catch (e) {
      debugPrint('Error notifying contacts about time extension: $e');
    }
  }

  // Settings methods
  void updateCheckInInterval(int minutes) {
    _checkInIntervalMinutes = minutes;
    notifyListeners();
  }

  void updateOverdueAlert(int minutes) {
    _overdueAlertMinutes = minutes;
    notifyListeners();
  }

  void updateAutoStartTracking(bool enabled) {
    _autoStartTracking = enabled;
    notifyListeners();
  }

  void updateShareLocationDuringJourney(bool enabled) {
    _shareLocationDuringJourney = enabled;
    notifyListeners();
  }

  void updateEnableRouteDeviation(bool enabled) {
    _enableRouteDeviation = enabled;
    notifyListeners();
  }

  void updateRouteDeviationThreshold(double threshold) {
    _routeDeviationThreshold = threshold;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    _stopLocationTracking();
    _journeyTimer?.cancel();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
}
