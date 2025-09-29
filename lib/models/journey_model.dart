enum JourneyStatus {
  planned,
  active,
  completed,
  cancelled,
  alert,
  overdue,
}

class JourneyModel {
  final String? id;
  final String userId;
  final String? title;
  final double startLatitude;
  final double startLongitude;
  final String? startAddress;
  final double? endLatitude;
  final double? endLongitude;
  final String? endAddress;
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime? estimatedArrival;
  final JourneyStatus status;
  final List<Map<String, double>> routeCoordinates;
  final List<String> sharedWith;
  final bool isPublic;
  final String? notes;
  final Map<String, dynamic>? settings;

  JourneyModel({
    this.id,
    required this.userId,
    this.title,
    required this.startLatitude,
    required this.startLongitude,
    this.startAddress,
    this.endLatitude,
    this.endLongitude,
    this.endAddress,
    required this.startTime,
    this.endTime,
    this.estimatedArrival,
    this.status = JourneyStatus.planned,
    this.routeCoordinates = const [],
    this.sharedWith = const [],
    this.isPublic = false,
    this.notes,
    this.settings,
  });

  // Convert from JSON
  factory JourneyModel.fromJson(Map<String, dynamic> json) {
    return JourneyModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      title: json['title'],
      startLatitude: (json['start_latitude'] ?? 0.0).toDouble(),
      startLongitude: (json['start_longitude'] ?? 0.0).toDouble(),
      startAddress: json['start_address'],
      endLatitude: json['end_latitude']?.toDouble(),
      endLongitude: json['end_longitude']?.toDouble(),
      endAddress: json['end_address'],
      startTime: DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      estimatedArrival: json['estimated_arrival'] != null ? DateTime.parse(json['estimated_arrival']) : null,
      status: JourneyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => JourneyStatus.planned,
      ),
      routeCoordinates: json['route_coordinates'] != null 
          ? List<Map<String, double>>.from(
              json['route_coordinates'].map((coord) => Map<String, double>.from(coord))
            )
          : [],
      sharedWith: List<String>.from(json['shared_with'] ?? []),
      isPublic: json['is_public'] ?? false,
      notes: json['notes'],
      settings: json['settings'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'start_address': startAddress,
      'end_latitude': endLatitude,
      'end_longitude': endLongitude,
      'end_address': endAddress,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'estimated_arrival': estimatedArrival?.toIso8601String(),
      'status': status.toString().split('.').last,
      'route_coordinates': routeCoordinates,
      'shared_with': sharedWith,
      'is_public': isPublic,
      'notes': notes,
      'settings': settings,
    };
  }

  // Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'start_address': startAddress,
      'end_latitude': endLatitude,
      'end_longitude': endLongitude,
      'end_address': endAddress,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'estimated_arrival': estimatedArrival?.toIso8601String(),
      'status': status.toString().split('.').last,
      'route_coordinates': routeCoordinates.isNotEmpty 
          ? routeCoordinates.map((coord) => '${coord['lat']},${coord['lng']}').join(';')
          : null,
      'shared_with': sharedWith.join(','),
      'is_public': isPublic ? 1 : 0,
      'notes': notes,
      'settings': settings?.toString(),
    };
  }

  // Create from SQLite Map
  factory JourneyModel.fromMap(Map<String, dynamic> map) {
    List<Map<String, double>> coordinates = [];
    if (map['route_coordinates'] != null && map['route_coordinates'].toString().isNotEmpty) {
      final coordStrings = map['route_coordinates'].toString().split(';');
      coordinates = coordStrings.map((coord) {
        final parts = coord.split(',');
        return {
          'lat': double.parse(parts[0]),
          'lng': double.parse(parts[1]),
        };
      }).toList();
    }

    return JourneyModel(
      id: map['id'],
      userId: map['user_id'] ?? '',
      title: map['title'],
      startLatitude: (map['start_latitude'] ?? 0.0).toDouble(),
      startLongitude: (map['start_longitude'] ?? 0.0).toDouble(),
      startAddress: map['start_address'],
      endLatitude: map['end_latitude']?.toDouble(),
      endLongitude: map['end_longitude']?.toDouble(),
      endAddress: map['end_address'],
      startTime: DateTime.parse(map['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      estimatedArrival: map['estimated_arrival'] != null ? DateTime.parse(map['estimated_arrival']) : null,
      status: JourneyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => JourneyStatus.planned,
      ),
      routeCoordinates: coordinates,
      sharedWith: map['shared_with'] != null && map['shared_with'].toString().isNotEmpty
          ? map['shared_with'].toString().split(',')
          : [],
      isPublic: map['is_public'] == 1,
      notes: map['notes'],
      settings: map['settings'] != null 
          ? Map<String, dynamic>.from(map['settings'])
          : null,
    );
  }

  // Calculate journey duration
  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  // Check if journey is overdue
  bool get isOverdue {
    if (estimatedArrival != null && status == JourneyStatus.active) {
      return DateTime.now().isAfter(estimatedArrival!);
    }
    return false;
  }

  // Copy with new values
  JourneyModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? startLatitude,
    double? startLongitude,
    String? startAddress,
    double? endLatitude,
    double? endLongitude,
    String? endAddress,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? estimatedArrival,
    JourneyStatus? status,
    List<Map<String, double>>? routeCoordinates,
    List<String>? sharedWith,
    bool? isPublic,
    String? notes,
    Map<String, dynamic>? settings,
  }) {
    return JourneyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      startAddress: startAddress ?? this.startAddress,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      endAddress: endAddress ?? this.endAddress,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      status: status ?? this.status,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
      sharedWith: sharedWith ?? this.sharedWith,
      isPublic: isPublic ?? this.isPublic,
      notes: notes ?? this.notes,
      settings: settings ?? this.settings,
    );
  }

  @override
  String toString() {
    return 'JourneyModel(id: $id, title: $title, status: $status, from: ($startLatitude, $startLongitude))';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JourneyModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}