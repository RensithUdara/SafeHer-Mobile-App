class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhotoPath;
  final String? emergencyPin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhotoPath,
    this.emergencyPin,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profilePhotoPath: json['profile_photo_path'],
      emergencyPin: json['emergency_pin'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] ?? true,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_photo_path': profilePhotoPath,
      'emergency_pin': emergencyPin,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  // Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_photo_path': profilePhotoPath,
      'emergency_pin': emergencyPin,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  // Create from SQLite Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      profilePhotoPath: map['profile_photo_path'],
      emergencyPin: map['emergency_pin'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
      isActive: map['is_active'] == 1,
    );
  }

  // Copy with new values
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePhotoPath,
    String? emergencyPin,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      emergencyPin: emergencyPin ?? this.emergencyPin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}