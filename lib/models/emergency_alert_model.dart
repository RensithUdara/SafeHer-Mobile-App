import 'package:geolocator/geolocator.dart';

enum EmergencyAlertType {
  sos,
  panic,
  journey,
  safeZone,
  community,
}

enum AlertStatus {
  active,
  resolved,
  cancelled,
  expired,
}

class EmergencyAlertModel {
  final String? id;
  final String userId;
  final EmergencyAlertType alertType;
  final AlertStatus status;
  final double latitude;
  final double longitude;
  final String? address;
  final String? message;
  final List<String> contactsNotified;
  final DateTime timestamp;
  final DateTime? resolvedAt;
  final Map<String, dynamic>? additionalData;

  EmergencyAlertModel({
    this.id,
    required this.userId,
    required this.alertType,
    this.status = AlertStatus.active,
    required this.latitude,
    required this.longitude,
    this.address,
    this.message,
    this.contactsNotified = const [],
    required this.timestamp,
    this.resolvedAt,
    this.additionalData,
  });

  // Convert from JSON
  factory EmergencyAlertModel.fromJson(Map<String, dynamic> json) {
    return EmergencyAlertModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      alertType: EmergencyAlertType.values.firstWhere(
        (e) => e.toString().split('.').last == json['alert_type'],
        orElse: () => EmergencyAlertType.sos,
      ),
      status: AlertStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AlertStatus.active,
      ),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'],
      message: json['message'],
      contactsNotified: List<String>.from(json['contacts_notified'] ?? []),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      additionalData: json['additional_data'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'alert_type': alertType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'message': message,
      'contacts_notified': contactsNotified,
      'timestamp': timestamp.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'additional_data': additionalData,
    };
  }

  // Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'alert_type': alertType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'message': message,
      'contacts_notified': contactsNotified.join(','),
      'timestamp': timestamp.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'additional_data': additionalData != null ? additionalData.toString() : null,
    };
  }

  // Create from SQLite Map
  factory EmergencyAlertModel.fromMap(Map<String, dynamic> map) {
    return EmergencyAlertModel(
      id: map['id'],
      userId: map['user_id'] ?? '',
      alertType: EmergencyAlertType.values.firstWhere(
        (e) => e.toString().split('.').last == map['alert_type'],
        orElse: () => EmergencyAlertType.sos,
      ),
      status: AlertStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => AlertStatus.active,
      ),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'],
      message: map['message'],
      contactsNotified: map['contacts_notified'] != null 
          ? map['contacts_notified'].toString().split(',')
          : [],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      resolvedAt: map['resolved_at'] != null ? DateTime.parse(map['resolved_at']) : null,
      additionalData: map['additional_data'] != null 
          ? Map<String, dynamic>.from(map['additional_data'])
          : null,
    );
  }

  // Get distance from current position
  double getDistanceFrom(Position position) {
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      latitude,
      longitude,
    );
  }

  // Copy with new values
  EmergencyAlertModel copyWith({
    String? id,
    String? userId,
    EmergencyAlertType? alertType,
    AlertStatus? status,
    double? latitude,
    double? longitude,
    String? address,
    String? message,
    List<String>? contactsNotified,
    DateTime? timestamp,
    DateTime? resolvedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return EmergencyAlertModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      alertType: alertType ?? this.alertType,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      message: message ?? this.message,
      contactsNotified: contactsNotified ?? this.contactsNotified,
      timestamp: timestamp ?? this.timestamp,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'EmergencyAlertModel(id: $id, type: $alertType, status: $status, location: ($latitude, $longitude))';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyAlertModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}