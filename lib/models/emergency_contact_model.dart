class EmergencyContactModel {
  final String? id;
  final String userId;
  final String contactName;
  final String phoneNumber;
  final String relationship;
  final int priorityLevel; // 1 = highest priority
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmergencyContactModel({
    this.id,
    required this.userId,
    required this.contactName,
    required this.phoneNumber,
    required this.relationship,
    this.priorityLevel = 1,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from JSON
  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      contactName: json['contact_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      relationship: json['relationship'] ?? '',
      priorityLevel: json['priority_level'] ?? 1,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'contact_name': contactName,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'priority_level': priorityLevel,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'contact_name': contactName,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'priority_level': priorityLevel,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from SQLite Map
  factory EmergencyContactModel.fromMap(Map<String, dynamic> map) {
    return EmergencyContactModel(
      id: map['id'],
      userId: map['user_id'] ?? '',
      contactName: map['contact_name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      relationship: map['relationship'] ?? '',
      priorityLevel: map['priority_level'] ?? 1,
      isActive: map['is_active'] == 1,
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with new values
  EmergencyContactModel copyWith({
    String? id,
    String? userId,
    String? contactName,
    String? phoneNumber,
    String? relationship,
    int? priorityLevel,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContactModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contactName: contactName ?? this.contactName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'EmergencyContactModel(id: $id, name: $contactName, phone: $phoneNumber, relationship: $relationship)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyContactModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
