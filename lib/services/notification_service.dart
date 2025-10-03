import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  NotificationService._internal();

  factory NotificationService() => _instance;

  // Initialize notification service
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();
  }

  // Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  // Create notification channels (Android)
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      // Emergency channel
      const emergencyChannel = AndroidNotificationChannel(
        'emergency_alerts',
        'Emergency Alerts',
        description: 'Critical emergency notifications',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );

      // Safety channel
      const safetyChannel = AndroidNotificationChannel(
        'safety_notifications',
        'Safety Notifications',
        description: 'General safety notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      // Location tracking channel
      const locationChannel = AndroidNotificationChannel(
        'location_tracking',
        'Location Tracking',
        description: 'Background location tracking notifications',
        importance: Importance.low,
        priority: Priority.low,
        enableVibration: false,
        playSound: false,
        showBadge: false,
      );

      // Journey tracking channel
      const journeyChannel = AndroidNotificationChannel(
        'journey_tracking',
        'Journey Tracking',
        description: 'Safe journey tracking notifications',
        importance: Importance.default_,
        priority: Priority.defaultPriority,
        enableVibration: true,
        playSound: true,
      );

      // Community alerts channel
      const communityChannel = AndroidNotificationChannel(
        'community_alerts',
        'Community Alerts',
        description: 'Community safety alerts',
        importance: Importance.default_,
        priority: Priority.defaultPriority,
        enableVibration: true,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(emergencyChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(safetyChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(locationChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(journeyChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(communityChannel);
    }
  }

  // Show emergency notification
  Future<void> showEmergencyNotification(
    String title,
    String body, {
    String? payload,
    bool ongoing = true,
    bool autoCancel = false,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'emergency_alerts',
      'Emergency Alerts',
      channelDescription: 'Critical emergency notifications',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      color: Color.fromARGB(255, 255, 0, 0), // Red color
      colorized: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      playSound: true,
      sound: RawResourceAndroidNotificationSound('emergency_alarm'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      criticalAlert: true,
      sound: 'emergency_alarm.aiff',
      interruptionLevel: InterruptionLevel.critical,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      1001, // Emergency notification ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show safety notification
  Future<void> showSafetyNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'safety_notifications',
      'Safety Notifications',
      channelDescription: 'General safety notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      color: Color.fromARGB(255, 255, 20, 147), // Pink color
      colorized: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      1002, // Safety notification ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show journey notification
  Future<void> showJourneyNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'journey_tracking',
      'Journey Tracking',
      channelDescription: 'Safe journey tracking notifications',
      importance: Importance.default_,
      priority: Priority.defaultPriority,
      enableVibration: true,
      playSound: true,
      color: Color.fromARGB(255, 0, 123, 255), // Blue color
      colorized: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      1003, // Journey notification ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show community alert notification
  Future<void> showCommunityAlert(
    String title,
    String body, {
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'community_alerts',
      'Community Alerts',
      channelDescription: 'Community safety alerts',
      importance: Importance.default_,
      priority: Priority.defaultPriority,
      enableVibration: true,
      playSound: true,
      color: Color.fromARGB(255, 255, 193, 7), // Amber color
      colorized: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      1004, // Community alert notification ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show location tracking notification (persistent)
  Future<void> showLocationTrackingNotification(
      String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'location_tracking',
      'Location Tracking',
      channelDescription: 'Background location tracking notifications',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      enableVibration: false,
      playSound: false,
      color: Color.fromARGB(255, 40, 167, 69), // Green color
      colorized: true,
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

    await _localNotifications.show(
      1005, // Location tracking notification ID
      title,
      body,
      notificationDetails,
    );
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channelId = 'safety_notifications',
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'safety_notifications',
      'Safety Notifications',
      channelDescription: 'General safety notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Play emergency alarm
  Future<void> playEmergencyAlarm() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      // In a real app, you might want to play a custom alarm sound
    } catch (e) {
      print('Error playing emergency alarm: $e');
    }
  }

  // Stop emergency alarm
  Future<void> stopEmergencyAlarm() async {
    // Cancel the emergency notification
    await cancelNotification(1001);
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final result = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
      );
      return result.authorizationStatus == AuthorizationStatus.authorized;
    }
    return false;
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    return false;
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Handling foreground message: ${message.messageId}');

    // Show local notification for foreground messages
    if (message.notification != null) {
      showSafetyNotification(
        message.notification!.title ?? 'SafeHer',
        message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  // Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    print('Handling background message: ${message.messageId}');
    _handleNotificationPayload(message.data.toString());
  }

  // Handle notification payload
  void _handleNotificationPayload(String payload) {
    print('Handling notification payload: $payload');
    // Navigate to appropriate screen based on payload
    // This would be implemented based on your app's navigation system
  }

  // Show badge (iOS)
  Future<void> showBadge(int count) async {
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Clear badge (iOS)
  Future<void> clearBadge() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: false,
        sound: true,
      );
    }
  }
}
