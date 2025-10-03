import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:torch_light/torch_light.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

import '../database/database_helper.dart';
import '../models/emergency_alert_model.dart';
import '../models/emergency_contact_model.dart';
import '../services/emergency_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class EmergencyController extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  final EmergencyService _emergencyService = EmergencyService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEmergencyActive = false;
  bool _isLoading = false;
  bool _isTorchOn = false;
  bool _isRecording = false;

  Position? _currentPosition;
  List<EmergencyContactModel> _emergencyContacts = [];
  EmergencyAlertModel? _activeAlert;

  // Getters
  bool get isEmergencyActive => _isEmergencyActive;
  bool get isLoading => _isLoading;
  bool get isTorchOn => _isTorchOn;
  bool get isRecording => _isRecording;
  Position? get currentPosition => _currentPosition;
  List<EmergencyContactModel> get emergencyContacts => _emergencyContacts;
  EmergencyAlertModel? get activeAlert => _activeAlert;

  EmergencyController() {
    _initializeEmergencyService();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _initializeEmergencyService() async {
    await loadEmergencyContacts();
    await _locationService.checkLocationPermissions();
  }

  // SOS/Panic Button Activation
  Future<void> activateEmergency() async {
    try {
      _setLoading(true);
      _isEmergencyActive = true;
      notifyListeners();

      // Get current location
      _currentPosition = await _locationService.getCurrentLocation();

      // Create emergency alert
      _activeAlert = EmergencyAlertModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        alertType: EmergencyAlertType.sos,
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
        timestamp: DateTime.now(),
        status: AlertStatus.active,
      );

      // Save to Firestore
      await _firestore
          .collection('emergency_alerts')
          .doc(_activeAlert!.id)
          .set(_activeAlert!.toJson());

      // Save to local database
      final db = await DatabaseHelper().database;
      await db.insert('emergency_alerts_table', _activeAlert!.toMap());

      // Start emergency sequence
      await _startEmergencySequence();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      print('Emergency activation error: $e');
    }
  }

  // Start Emergency Sequence
  Future<void> _startEmergencySequence() async {
    // 1. Vibrate device
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000, 500, 1000]);
    }

    // 2. Turn on flashlight
    await toggleTorch(true);

    // 3. Send notifications to emergency contacts
    await sendEmergencyAlertsToContacts();

    // 4. Show emergency notification
    await _notificationService.showEmergencyNotification(
      'Emergency Alert Active',
      'SOS activated. Authorities and emergency contacts have been notified.',
    );

    // 5. Auto-call emergency services (optional, based on settings)
    // await _callEmergencyServices();

    // 6. Start audio recording if enabled
    await startAudioRecording();
  }

  // Deactivate Emergency
  Future<void> deactivateEmergency() async {
    try {
      _setLoading(true);

      if (_activeAlert != null) {
        // Update alert status
        _activeAlert = _activeAlert!.copyWith(
          status: AlertStatus.resolved,
          resolvedAt: DateTime.now(),
        );

        // Update Firestore
        await _firestore
            .collection('emergency_alerts')
            .doc(_activeAlert!.id)
            .update({
          'status': 'resolved',
          'resolved_at': _activeAlert!.resolvedAt?.toIso8601String(),
        });

        // Update local database
        final db = await DatabaseHelper().database;
        await db.update(
          'emergency_alerts_table',
          {
            'status': 'resolved',
            'resolved_at': _activeAlert!.resolvedAt?.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [_activeAlert!.id],
        );
      }

      _isEmergencyActive = false;
      _activeAlert = null;

      // Stop emergency features
      await toggleTorch(false);
      await stopAudioRecording();
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.cancel();
      }

      // Send resolved notification to contacts
      await sendResolvedNotificationToContacts();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      print('Emergency deactivation error: $e');
    }
  }

  // Send Emergency Alerts to Contacts
  Future<void> sendEmergencyAlertsToContacts() async {
    if (_emergencyContacts.isEmpty || _currentPosition == null) return;

    // Use the EmergencyService's triggerSOS method which handles notifications
    await _emergencyService.triggerSOS(
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      customMessage: 'Emergency Alert - I need immediate help!',
      sendToContacts: true,
      callPolice: false,
      startAlarm: true,
      enableFlashlight: true,
      vibrate: true,
    );
  }

  // Send Resolved Notification to Contacts
  Future<void> sendResolvedNotificationToContacts() async {
    for (final contact in _emergencyContacts) {
      if (contact.isActive) {
        // Use notification service to show emergency resolved notification
        await _notificationService.showEmergencyNotification(
          'Emergency Resolved',
          'Your emergency contact ${contact.contactName} is now safe.',
          payload: 'emergency_resolved_${_activeAlert?.id ?? ''}',
        );
      }
    }
  }

  // Call Emergency Services
  Future<void> callEmergencyServices() async {
    const String emergencyNumber = AppConstants.emergencyNumber;
    final Uri phoneUri = Uri(scheme: 'tel', path: emergencyNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  // Call Emergency Contact
  Future<void> callEmergencyContact(EmergencyContactModel contact) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: contact.phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  // Toggle Torch/Flashlight
  Future<void> toggleTorch([bool? enable]) async {
    try {
      if (enable != null) {
        if (enable && !_isTorchOn) {
          await TorchLight.enableTorch();
          _isTorchOn = true;
        } else if (!enable && _isTorchOn) {
          await TorchLight.disableTorch();
          _isTorchOn = false;
        }
      } else {
        if (_isTorchOn) {
          await TorchLight.disableTorch();
          _isTorchOn = false;
        } else {
          await TorchLight.enableTorch();
          _isTorchOn = true;
        }
      }
      notifyListeners();
    } catch (e) {
      print('Torch error: $e');
    }
  }

  // Start Audio Recording
  Future<void> startAudioRecording() async {
    try {
      final permission = await Permission.microphone.request();
      if (permission.isGranted) {
        // Implementation for audio recording
        _isRecording = true;
        notifyListeners();
      }
    } catch (e) {
      print('Audio recording error: $e');
    }
  }

  // Stop Audio Recording
  Future<void> stopAudioRecording() async {
    try {
      // Implementation to stop audio recording
      _isRecording = false;
      notifyListeners();
    } catch (e) {
      print('Stop audio recording error: $e');
    }
  }

  // Load Emergency Contacts
  Future<void> loadEmergencyContacts() async {
    try {
      final db = await DatabaseHelper().database;
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final List<Map<String, dynamic>> contacts = await db.query(
          'emergency_contacts_table',
          where: 'user_id = ? AND is_active = ?',
          whereArgs: [userId, 1],
          orderBy: 'priority_level ASC',
        );

        _emergencyContacts = contacts
            .map((contact) => EmergencyContactModel.fromMap(contact))
            .toList();

        notifyListeners();
      }
    } catch (e) {
      print('Load emergency contacts error: $e');
    }
  }

  // Add Emergency Contact
  Future<bool> addEmergencyContact(EmergencyContactModel contact) async {
    try {
      _setLoading(true);

      // Save to local database
      final db = await DatabaseHelper().database;
      await db.insert('emergency_contacts_table', contact.toMap());

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(contact.userId)
          .collection('emergency_contacts')
          .doc(contact.id)
          .set(contact.toJson());

      // Reload contacts
      await loadEmergencyContacts();

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      print('Add emergency contact error: $e');
      return false;
    }
  }

  // Update Emergency Contact
  Future<bool> updateEmergencyContact(EmergencyContactModel contact) async {
    try {
      _setLoading(true);

      // Update local database
      final db = await DatabaseHelper().database;
      await db.update(
        'emergency_contacts_table',
        contact.toMap(),
        where: 'id = ?',
        whereArgs: [contact.id],
      );

      // Update Firestore
      await _firestore
          .collection('users')
          .doc(contact.userId)
          .collection('emergency_contacts')
          .doc(contact.id)
          .update(contact.toJson());

      // Reload contacts
      await loadEmergencyContacts();

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      print('Update emergency contact error: $e');
      return false;
    }
  }

  // Delete Emergency Contact
  Future<bool> deleteEmergencyContact(String contactId) async {
    try {
      _setLoading(true);

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Delete from local database
        final db = await DatabaseHelper().database;
        await db.delete(
          'emergency_contacts_table',
          where: 'id = ?',
          whereArgs: [contactId],
        );

        // Delete from Firestore
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('emergency_contacts')
            .doc(contactId)
            .delete();

        // Reload contacts
        await loadEmergencyContacts();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      print('Delete emergency contact error: $e');
      return false;
    }
  }

  // Fake Call Feature
  Future<void> triggerFakeCall() async {
    await _notificationService.showEmergencyNotification(
      'Incoming Call',
      'Unknown Number',
      payload: 'fake_call',
      ongoing: true,
    );
  }

  // Shake Detection for Emergency
  void onShakeDetected() {
    if (!_isEmergencyActive) {
      activateEmergency();
    }
  }

  @override
  void dispose() {
    if (_isTorchOn) {
      toggleTorch(false);
    }
    super.dispose();
  }
}
