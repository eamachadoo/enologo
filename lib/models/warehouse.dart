/// Warehouse model representing a wine storage location with inventory tracking
class Warehouse {
  final String id;                 // Firestore document ID (primary key)
  final String userId;             // Owner user ID (foreign key)
  final String name;               // User-defined warehouse name
  final String? description;       // Optional warehouse description
  final String? location;          // Optional physical address
  final double? latitude;          // Optional GPS coordinates
  final double? longitude;         // Optional GPS coordinates
  final int wineCount;             // Cached count of wines in warehouse
  final DateTime createdAt;        // Creation timestamp
  final DateTime updatedAt;        // Last modification timestamp

  Warehouse({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.wineCount = 0,
    required this.createdAt,
    required this.updatedAt,
  }) {
    // Validate warehouse name
    if (name.trim().isEmpty || name.length > 100) {
      throw ArgumentError('Warehouse name must be 1-100 characters');
    }
    
    // Validate description length
    if (description != null && description!.length > 500) {
      throw ArgumentError('Description cannot exceed 500 characters');
    }
    
    // Validate location length
    if (location != null && location!.length > 200) {
      throw ArgumentError('Location cannot exceed 200 characters');
    }
    
    // Validate GPS coordinates
    if (latitude != null && (latitude! < -90 || latitude! > 90)) {
      throw ArgumentError('Latitude must be between -90 and 90 degrees');
    }
    
    if (longitude != null && (longitude! < -180 || longitude! > 180)) {
      throw ArgumentError('Longitude must be between -180 and 180 degrees');
    }
    
    // Both coordinates must be provided together or both null
    if ((latitude == null) != (longitude == null)) {
      throw ArgumentError('Both latitude and longitude must be provided together');
    }
    
    // Validate wine count
    if (wineCount < 0) {
      throw ArgumentError('Wine count cannot be negative');
    }
    
    // Validate timestamps
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('Updated timestamp cannot be before created timestamp');
    }
  }

  /// Check if warehouse has GPS coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Check if warehouse is empty (no wines)
  bool get isEmpty => wineCount == 0;

  /// Convert Warehouse to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'wineCount': wineCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create Warehouse from JSON
  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      wineCount: json['wineCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create a copy of Warehouse with updated fields
  Warehouse copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    int? wineCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Warehouse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      wineCount: wineCount ?? this.wineCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Warehouse &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.description == description &&
        other.location == location &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.wineCount == wineCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        location.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        wineCount.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Warehouse('
        'id: $id, '
        'userId: $userId, '
        'name: $name, '
        'description: $description, '
        'location: $location, '
        'latitude: $latitude, '
        'longitude: $longitude, '
        'wineCount: $wineCount, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt)';
  }
}
