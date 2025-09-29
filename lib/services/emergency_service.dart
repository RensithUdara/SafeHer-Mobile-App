import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torch_light/torch_light.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

import '../database/database_helper.dart';
import '../models/emergency_alert_model.dart';
import '../models/emergency_contact_model.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'location_service.dart';
import 'notification_service.dart';

enum EmergencyLevel {
  low,
  medium,
  high,
  critical,
}

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseService _firebaseService = FirebaseService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  Timer? _sosTimer;
  Timer? _alarmTimer;
  bool _isEmergencyActive = false;
  String? _activeEmergencyId;

  EmergencyService._internal();

  factory EmergencyService() => _instance;

  // Initialize emergency service
  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  // Trigger SOS emergency
  Future<String?> triggerSOS({
    required String userId,
    String? customMessage,
    bool sendToContacts = true,
    bool callPolice = false,
    bool startAlarm = true,
    bool enableFlashlight = true,
    bool vibrate = true,
  }) async {
    try {
      if (_isEmergencyActive) {
        return _activeEmergencyId;
      }

      _isEmergencyActive = true;

      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // Get address from coordinates
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Create emergency alert
      final alert = EmergencyAlertModel(
        userId: userId,
        alertType: EmergencyAlertType.sos,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        message:
            customMessage ?? 'SOS Emergency Alert - I need immediate help!',
        timestamp: DateTime.now(),
      );

      // Save to local database
      await _dbHelper.insert('emergency_alerts_table', alert.toMap());

      // Save to Firebase
      final alertId = await _firebaseService.saveEmergencyAlert(alert);
      _activeEmergencyId = alertId;

      // Start emergency actions
      if (vibrate) await _startVibration();
      if (enableFlashlight) await _startFlashlight();
      if (startAlarm) await _startAlarm();

      // Send to emergency contacts
      if (sendToContacts) {
        await _notifyEmergencyContacts(userId, alert);
      }

      // Call police if requested
      if (callPolice) {
        await _callEmergencyServices();
      }

      // Send push notifications
      await _sendEmergencyNotifications(alert);

      // Show local notification
      await _notificationService.showEmergencyNotification(
        'SOS Alert Active',
        'Emergency services and contacts have been notified',
      );

      return alertId;
    } catch (e) {
      _isEmergencyActive = false;
      throw Exception('Failed to trigger SOS: $e');
    }
  }

  // Trigger panic button
  Future<String?> triggerPanic({
    required String userId,
    String? customMessage,
    bool silent = false,
  }) async {
    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // Get address from coordinates
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Create emergency alert
      final alert = EmergencyAlertModel(
        userId: userId,
        alertType: EmergencyAlertType.panic,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        message: customMessage ?? 'Panic Alert - I\'m in danger and need help!',
        timestamp: DateTime.now(),
      );

      // Save to local database
      await _dbHelper.insert('emergency_alerts_table', alert.toMap());

      // Save to Firebase
      final alertId = await _firebaseService.saveEmergencyAlert(alert);

      // Silent mode - only notify contacts, no alarms
      if (!silent) {
        await _startVibration();
        await _startFlashlight();
      }

      // Notify emergency contacts
      await _notifyEmergencyContacts(userId, alert);

      // Send push notifications
      await _sendEmergencyNotifications(alert);

      return alertId;
    } catch (e) {
      throw Exception('Failed to trigger panic: $e');
    }
  }

  // Start journey tracking with safety monitoring
  Future<String?> startSafeJourney({
    required String userId,
    required double destinationLat,
    required double destinationLng,
    required DateTime expectedArrival,
    List<String>? shareWith,
  }) async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // This would integrate with JourneyModel and tracking service
      // For now, create a basic alert that will monitor the journey
      final alert = EmergencyAlertModel(
        userId: userId,
        alertType: EmergencyAlertType.journey,
        latitude: position.latitude,
        longitude: position.longitude,
        message: 'Safe journey monitoring started',
        timestamp: DateTime.now(),
        additionalData: {
          'destination_lat': destinationLat,
          'destination_lng': destinationLng,
          'expected_arrival': expectedArrival.toIso8601String(),
          'shared_with': shareWith ?? [],
        },
      );

      // Save to local database
      await _dbHelper.insert('emergency_alerts_table', alert.toMap());

      // Save to Firebase
      final alertId = await _firebaseService.saveEmergencyAlert(alert);

      // Start location tracking
      await _locationService.startLocationTracking(
        onLocationUpdate: (position) {
          _handleJourneyLocationUpdate(position, alertId, expectedArrival);
        },
      );

      return alertId;
    } catch (e) {
      throw Exception('Failed to start safe journey: $e');
    }
  }

  // Cancel active emergency
  Future<void> cancelEmergency(String alertId) async {
    try {
      // Update alert status
      await _dbHelper.update(
        'emergency_alerts_table',
        {
          'status': AlertStatus.cancelled.toString().split('.').last,
          'resolved_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [alertId],
      );

      // Update in Firebase
      final alert = await _getAlertById(alertId);
      if (alert != null) {
        final updatedAlert = alert.copyWith(
          status: AlertStatus.cancelled,
          resolvedAt: DateTime.now(),
        );
        await _firebaseService.updateEmergencyAlert(updatedAlert);
      }

      // Stop all emergency actions
      await _stopAllEmergencyActions();

      _isEmergencyActive = false;
      _activeEmergencyId = null;

      // Notify contacts that emergency is cancelled
      await _notifyEmergencyCancelled(alertId);
    } catch (e) {
      throw Exception('Failed to cancel emergency: $e');
    }
  }

  // Make fake call
  Future<void> makeFakeCall({
    String callerName = "Mom",
    String callerNumber = "+1234567890",
    int durationSeconds = 30,
  }) async {
    try {
      // Show fake call overlay
      await _showFakeCallOverlay(callerName, callerNumber);

      // Start ringtone/vibration
      await _startFakeCallEffects();

      // Auto-dismiss after duration
      Timer(Duration(seconds: durationSeconds), () {
        _dismissFakeCall();
      });
    } catch (e) {
      throw Exception('Failed to make fake call: $e');
    }
  }

  // Call emergency services
  Future<void> callEmergencyServices({String number = "911"}) async {
    try {
      await _callEmergencyServices(number: number);
    } catch (e) {
      throw Exception('Failed to call emergency services: $e');
    }
  }

  // Get emergency contacts
  Future<List<EmergencyContactModel>> getEmergencyContacts(
      String userId) async {
    try {
      final contacts = await _dbHelper.query(
        'emergency_contacts_table',
        where: 'user_id = ? AND is_active = 1',
        whereArgs: [userId],
        orderBy: 'priority_level ASC',
      );

      return contacts
          .map((contact) => EmergencyContactModel.fromMap(contact))
          .toList();
    } catch (e) {
      throw Exception('Failed to get emergency contacts: $e');
    }
  }

  // Add emergency contact
  Future<void> addEmergencyContact(EmergencyContactModel contact) async {
    try {
      await _dbHelper.insert('emergency_contacts_table', contact.toMap());
    } catch (e) {
      throw Exception('Failed to add emergency contact: $e');
    }
  }

  // Update emergency contact
  Future<void> updateEmergencyContact(EmergencyContactModel contact) async {
    try {
      await _dbHelper.update(
        'emergency_contacts_table',
        contact.toMap(),
        where: 'id = ?',
        whereArgs: [contact.id],
      );
    } catch (e) {
      throw Exception('Failed to update emergency contact: $e');
    }
  }

  // Delete emergency contact
  Future<void> deleteEmergencyContact(String contactId) async {
    try {
      await _dbHelper.delete(
        'emergency_contacts_table',
        where: 'id = ?',
        whereArgs: [contactId],
      );
    } catch (e) {
      throw Exception('Failed to delete emergency contact: $e');
    }
  }

  // Get emergency history
  Future<List<EmergencyAlertModel>> getEmergencyHistory(String userId) async {
    try {
      final alerts = await _dbHelper.query(
        'emergency_alerts_table',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'timestamp DESC',
      );

      return alerts.map((alert) => EmergencyAlertModel.fromMap(alert)).toList();
    } catch (e) {
      throw Exception('Failed to get emergency history: $e');
    }
  }

  // Check if emergency is active
  bool get isEmergencyActive => _isEmergencyActive;

  // Get active emergency ID
  String? get activeEmergencyId => _activeEmergencyId;

  // Private helper methods
  Future<void> _notifyEmergencyContacts(
      String userId, EmergencyAlertModel alert) async {
    try {
      final contacts = await getEmergencyContacts(userId);

      for (final contact in contacts) {
        // Send SMS if possible
        await _sendEmergencySMS(contact, alert);

        // Make call to highest priority contacts
        if (contact.priorityLevel <= 2) {
          await _makeEmergencyCall(contact.phoneNumber);
        }
      }
    } catch (e) {
      print('Error notifying emergency contacts: $e');
    }
  }

  Future<void> _sendEmergencySMS(
      EmergencyContactModel contact, EmergencyAlertModel alert) async {
    try {
      final message =
          '${alert.message}\n\nLocation: ${alert.address ?? 'Unknown'}\nMap: https://maps.google.com/?q=${alert.latitude},${alert.longitude}\n\nSent from SafeHer app';

      final uri = Uri(
        scheme: 'sms',
        path: contact.phoneNumber,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }

  Future<void> _makeEmergencyCall(String phoneNumber) async {
    try {
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Error making call: $e');
    }
  }

  Future<void> _callEmergencyServices({String number = "911"}) async {
    try {
      final uri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Error calling emergency services: $e');
    }
  }

  Future<void> _startVibration() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        // Vibrate in SOS pattern: 3 short, 3 long, 3 short
        final pattern = [
          0,
          200,
          100,
          200,
          100,
          200,
          100,
          600,
          100,
          600,
          100,
          600,
          100,
          200,
          100,
          200,
          100,
          200
        ];
        Vibration.vibrate(pattern: pattern, repeat: 0); // Repeat until stopped
      }
    } catch (e) {
      print('Error starting vibration: $e');
    }
  }

  Future<void> _startFlashlight() async {
    try {
      if (await TorchLight.isTorchAvailable()) {
        // Flash in SOS pattern
        _flashSOSPattern();
      }
    } catch (e) {
      print('Error starting flashlight: $e');
    }
  }

  void _flashSOSPattern() {
    int count = 0;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (count >= 18) {
        timer.cancel();
        Timer(const Duration(seconds: 2),
            () => _flashSOSPattern()); // Repeat after 2 seconds
        return;
      }

      if (count < 6) {
        // Short flashes (3 times)
        _toggleFlashlight();
      } else if (count < 12) {
        // Long flashes (3 times)
        if (count % 2 == 0)
          TorchLight.enableTorch();
        else
          TorchLight.disableTorch();
      } else {
        // Short flashes again (3 times)
        _toggleFlashlight();
      }
      count++;
    });
  }

  void _toggleFlashlight() async {
    try {
      await TorchLight.enableTorch();
      Timer(const Duration(milliseconds: 100), () => TorchLight.disableTorch());
    } catch (e) {
      print('Error toggling flashlight: $e');
    }
  }

  Future<void> _startAlarm() async {
    try {
      // Play emergency alarm sound
      await _notificationService.playEmergencyAlarm();
    } catch (e) {
      print('Error starting alarm: $e');
    }
  }

  Future<void> _stopAllEmergencyActions() async {
    try {
      _sosTimer?.cancel();
      _alarmTimer?.cancel();

      await Vibration.cancel();
      await TorchLight.disableTorch();
      await _notificationService.stopEmergencyAlarm();
    } catch (e) {
      print('Error stopping emergency actions: $e');
    }
  }

  Future<void> _sendEmergencyNotifications(EmergencyAlertModel alert) async {
    try {
      // This would send push notifications to nearby users or authorities
      // Implementation depends on your notification system
    } catch (e) {
      print('Error sending emergency notifications: $e');
    }
  }

  Future<void> _showFakeCallOverlay(
      String callerName, String callerNumber) async {
    // This would show a fake incoming call screen
    // Implementation depends on your UI framework
  }

  Future<void> _startFakeCallEffects() async {
    try {
      await Vibration.vibrate(pattern: [0, 1000, 500], repeat: 0);
    } catch (e) {
      print('Error starting fake call effects: $e');
    }
  }

  void _dismissFakeCall() {
    Vibration.cancel();
    // Dismiss fake call UI
  }

  void _handleJourneyLocationUpdate(
      Position position, String alertId, DateTime expectedArrival) {
    // Check if journey is overdue or if user deviates from expected route
    // Trigger alert if necessary
  }

  Future<EmergencyAlertModel?> _getAlertById(String alertId) async {
    try {
      final alert = await _dbHelper.queryFirst(
        'emergency_alerts_table',
        where: 'id = ?',
        whereArgs: [alertId],
      );

      return alert != null ? EmergencyAlertModel.fromMap(alert) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _notifyEmergencyCancelled(String alertId) async {
    // Notify contacts that emergency has been cancelled
  }

  // Dispose resources
  void dispose() {
    _sosTimer?.cancel();
    _alarmTimer?.cancel();
    _stopAllEmergencyActions();
  }
}
