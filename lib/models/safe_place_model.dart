enum SafePlaceType {
  policeStation,
  hospital,
  fireStation,
  pharmacy,
  governmentOffice,
  publicTransport,
  hotel,
  restaurant,
  shoppingMall,
  school,
  university,
  religious,
  other,
}

class SafePlaceModel {
  final String? id;
  final String? userId; // null for public places
  final String placeName;
  final String address;
  final double latitude;
  final double longitude;
  final SafePlaceType placeType;
  final String? phoneNumber;
  final String? website;
  final Map<String, String>? openingHours;
  final double? rating;
  final int reviewCount;
  final bool isVerified;
  final bool isPublic;
  final DateTime savedAt;
  final DateTime? updatedAt;
  final String? notes;
  final Map<String, dynamic>? additionalInfo;

  SafePlaceModel({
    this.id,
    this.userId,
    required this.placeName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.placeType,
    this.phoneNumber,
    this.website,
    this.openingHours,
    this.rating,
    this.reviewCount = 0,
    this.isVerified = false,
    this.isPublic = false,
    required this.savedAt,
    this.updatedAt,
    this.notes,
    this.additionalInfo,
  });

  // Convert from JSON
  factory SafePlaceModel.fromJson(Map<String, dynamic> json) {
    return SafePlaceModel(
      id: json['id'],
      userId: json['user_id'],
      placeName: json['place_name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      placeType: SafePlaceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['place_type'],
        orElse: () => SafePlaceType.other,
      ),
      phoneNumber: json['phone_number'],
      website: json['website'],
      openingHours: json['opening_hours'] != null 
          ? Map<String, String>.from(json['opening_hours'])
          : null,
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isPublic: json['is_public'] ?? false,
      savedAt: DateTime.parse(json['saved_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      notes: json['notes'],
      additionalInfo: json['additional_info'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'place_name': placeName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'place_type': placeType.toString().split('.').last,
      'phone_number': phoneNumber,
      'website': website,
      'opening_hours': openingHours,
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_public': isPublic,
      'saved_at': savedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'notes': notes,
      'additional_info': additionalInfo,
    };
  }

  // Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'place_name': placeName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'place_type': placeType.toString().split('.').last,
      'phone_number': phoneNumber,
      'website': website,
      'opening_hours': openingHours?.toString(),
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified ? 1 : 0,
      'is_public': isPublic ? 1 : 0,
      'saved_at': savedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'notes': notes,
      'additional_info': additionalInfo?.toString(),
    };
  }

  // Create from SQLite Map
  factory SafePlaceModel.fromMap(Map<String, dynamic> map) {
    return SafePlaceModel(
      id: map['id'],
      userId: map['user_id'],
      placeName: map['place_name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      placeType: SafePlaceType.values.firstWhere(
        (e) => e.toString().split('.').last == map['place_type'],
        orElse: () => SafePlaceType.other,
      ),
      phoneNumber: map['phone_number'],
      website: map['website'],
      openingHours: map['opening_hours'] != null 
          ? Map<String, String>.from(map['opening_hours'])
          : null,
      rating: map['rating']?.toDouble(),
      reviewCount: map['review_count'] ?? 0,
      isVerified: map['is_verified'] == 1,
      isPublic: map['is_public'] == 1,
      savedAt: DateTime.parse(map['saved_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      notes: map['notes'],
      additionalInfo: map['additional_info'] != null 
          ? Map<String, dynamic>.from(map['additional_info'])
          : null,
    );
  }

  // Get place type display name
  String get placeTypeDisplayName {
    switch (placeType) {
      case SafePlaceType.policeStation:
        return 'Police Station';
      case SafePlaceType.hospital:
        return 'Hospital';
      case SafePlaceType.fireStation:
        return 'Fire Station';
      case SafePlaceType.pharmacy:
        return 'Pharmacy';
      case SafePlaceType.governmentOffice:
        return 'Government Office';
      case SafePlaceType.publicTransport:
        return 'Public Transport';
      case SafePlaceType.hotel:
        return 'Hotel';
      case SafePlaceType.restaurant:
        return 'Restaurant';
      case SafePlaceType.shoppingMall:
        return 'Shopping Mall';
      case SafePlaceType.school:
        return 'School';
      case SafePlaceType.university:
        return 'University';
      case SafePlaceType.religious:
        return 'Religious Place';
      case SafePlaceType.other:
        return 'Other';
    }
  }

  // Check if place is currently open
  bool get isCurrentlyOpen {
    if (openingHours == null) return true;
    
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final currentHours = openingHours![dayName];
    
    if (currentHours == null || currentHours.toLowerCase() == 'closed') {
      return false;
    }
    
    if (currentHours.toLowerCase() == '24/7' || currentHours.toLowerCase() == 'always open') {
      return true;
    }
    
    // Parse opening hours (format: "09:00-17:00")
    try {
      final parts = currentHours.split('-');
      if (parts.length != 2) return true;
      
      final openTime = _parseTime(parts[0].trim());
      final closeTime = _parseTime(parts[1].trim());
      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
      
      return _isTimeBetween(currentTime, openTime, closeTime);
    } catch (e) {
      return true; // Default to open if parsing fails
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return 'monday';
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  bool _isTimeBetween(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Crosses midnight
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  // Copy with new values
  SafePlaceModel copyWith({
    String? id,
    String? userId,
    String? placeName,
    String? address,
    double? latitude,
    double? longitude,
    SafePlaceType? placeType,
    String? phoneNumber,
    String? website,
    Map<String, String>? openingHours,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    bool? isPublic,
    DateTime? savedAt,
    DateTime? updatedAt,
    String? notes,
    Map<String, dynamic>? additionalInfo,
  }) {
    return SafePlaceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      placeName: placeName ?? this.placeName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeType: placeType ?? this.placeType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      isPublic: isPublic ?? this.isPublic,
      savedAt: savedAt ?? this.savedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  String toString() {
    return 'SafePlaceModel(id: $id, name: $placeName, type: $placeType, location: ($latitude, $longitude))';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SafePlaceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});
}