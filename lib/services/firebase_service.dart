import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';
import '../models/emergency_contact_model.dart';
import '../models/emergency_alert_model.dart';
import '../models/journey_model.dart';
import '../models/safe_place_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  FirebaseService._internal();

  factory FirebaseService() => _instance;

  // Collections
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _emergencyAlertsCollection => _firestore.collection('emergency_alerts');
  CollectionReference get _communityReportsCollection => _firestore.collection('community_reports');
  CollectionReference get _sharedLocationsCollection => _firestore.collection('shared_locations');
  CollectionReference get _safeZonesCollection => _firestore.collection('safe_zones');

  // Initialize Firebase services
  Future<void> initialize() async {
    // Request notification permissions
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground message
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // User operations
  Future<void> saveUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // Delete all user-related data
      final batch = _firestore.batch();
      
      // Delete user document
      batch.delete(_usersCollection.doc(userId));

      // Delete user's emergency alerts
      final alertsQuery = await _emergencyAlertsCollection
          .where('user_id', isEqualTo: userId)
          .get();
      for (final doc in alertsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's community reports
      final reportsQuery = await _communityReportsCollection
          .where('user_id', isEqualTo: userId)
          .get();
      for (final doc in reportsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's shared locations
      final locationsQuery = await _sharedLocationsCollection
          .where('user_id', isEqualTo: userId)
          .get();
      for (final doc in locationsQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Emergency alert operations
  Future<String> saveEmergencyAlert(EmergencyAlertModel alert) async {
    try {
      final docRef = await _emergencyAlertsCollection.add(alert.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save emergency alert: $e');
    }
  }

  Future<void> updateEmergencyAlert(EmergencyAlertModel alert) async {
    try {
      await _emergencyAlertsCollection.doc(alert.id).update(alert.toJson());
    } catch (e) {
      throw Exception('Failed to update emergency alert: $e');
    }
  }

  Future<List<EmergencyAlertModel>> getUserEmergencyAlerts(String userId) async {
    try {
      final query = await _emergencyAlertsCollection
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return EmergencyAlertModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get emergency alerts: $e');
    }
  }

  // Journey operations
  Future<String> saveJourney(JourneyModel journey) async {
    try {
      final docRef = await _firestore
          .collection('journeys')
          .add(journey.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save journey: $e');
    }
  }

  Future<void> updateJourney(JourneyModel journey) async {
    try {
      await _firestore
          .collection('journeys')
          .doc(journey.id)
          .update(journey.toJson());
    } catch (e) {
      throw Exception('Failed to update journey: $e');
    }
  }

  Future<List<JourneyModel>> getUserJourneys(String userId) async {
    try {
      final query = await _firestore
          .collection('journeys')
          .where('user_id', isEqualTo: userId)
          .orderBy('start_time', descending: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return JourneyModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get journeys: $e');
    }
  }

  // Shared location operations
  Future<String> startLocationSharing({
    required String userId,
    required List<String> sharedWith,
    required double latitude,
    required double longitude,
    DateTime? endTime,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'current_location': GeoPoint(latitude, longitude),
        'shared_with': sharedWith,
        'start_time': FieldValue.serverTimestamp(),
        'end_time': endTime?.toIso8601String(),
        'is_active': true,
        'last_updated': FieldValue.serverTimestamp(),
      };

      final docRef = await _sharedLocationsCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to start location sharing: $e');
    }
  }

  Future<void> updateSharedLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _sharedLocationsCollection.doc(sessionId).update({
        'current_location': GeoPoint(latitude, longitude),
        'last_updated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update shared location: $e');
    }
  }

  Future<void> stopLocationSharing(String sessionId) async {
    try {
      await _sharedLocationsCollection.doc(sessionId).update({
        'is_active': false,
        'end_time': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to stop location sharing: $e');
    }
  }

  Stream<DocumentSnapshot> getSharedLocationStream(String sessionId) {
    return _sharedLocationsCollection.doc(sessionId).snapshots();
  }

  // Community reporting operations
  Future<String> submitCommunityReport({
    required String userId,
    required double latitude,
    required double longitude,
    required String incidentType,
    required String description,
    List<String>? photoUrls,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'location': GeoPoint(latitude, longitude),
        'incident_type': incidentType,
        'description': description,
        'photos': photoUrls ?? [],
        'timestamp': FieldValue.serverTimestamp(),
        'verification_status': 'pending',
        'upvotes': 0,
        'downvotes': 0,
      };

      final docRef = await _communityReportsCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit community report: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCommunityReports({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      // Note: This is a simplified version. For production, you'd want to use
      // geohash or GeoFlutterFire for proper geo queries
      final query = await _communityReportsCollection
          .where('verification_status', isEqualTo: 'verified')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get community reports: $e');
    }
  }

  // Safe places operations
  Future<void> saveSafePlace(SafePlaceModel place) async {
    try {
      await _firestore
          .collection('safe_places')
          .doc(place.id)
          .set(place.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save safe place: $e');
    }
  }

  Future<List<SafePlaceModel>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required double radiusKm,
    SafePlaceType? placeType,
  }) async {
    try {
      Query query = _firestore.collection('safe_places')
          .where('is_public', isEqualTo: true);

      if (placeType != null) {
        query = query.where('place_type', isEqualTo: placeType.toString().split('.').last);
      }

      final querySnapshot = await query.limit(50).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return SafePlaceModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get nearby places: $e');
    }
  }

  // File upload operations
  Future<String> uploadFile({
    required String path,
    required String fileName,
    required List<int> fileData,
  }) async {
    try {
      final ref = _storage.ref().child(path).child(fileName);
      final uploadTask = await ref.putData(Uint8List.fromList(fileData));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Push notification operations
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  Future<void> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This would typically be done through a cloud function
    // For now, we'll store the notification request in Firestore
    try {
      await _firestore.collection('notification_requests').add({
        'user_ids': userIds,
        'title': title,
        'body': body,
        'data': data ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Real-time listeners
  Stream<QuerySnapshot> getEmergencyAlertsStream() {
    return _emergencyAlertsCollection
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getCommunityReportsStream({
    required double latitude,
    required double longitude,
  }) {
    // This is a simplified version for real-time updates
    return _communityReportsCollection
        .where('verification_status', isEqualTo: 'verified')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Handle background message here
}