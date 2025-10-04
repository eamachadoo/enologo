/// Temperature unit enumeration for user preferences
enum TemperatureUnit { celsius, fahrenheit }

/// User preferences for app-specific settings including notification preferences
class UserPreferences {
  final String defaultLanguage;
  final bool enablePushNotifications;
  final bool enableCameraAutoFocus;
  final TemperatureUnit temperatureUnit;
  final bool enableAgingAlerts;
  final bool enableLowStockAlerts;
  final bool enableFavoriteReminders;
  final int favoriteReminderDays;
  final int alertCooldownDays;

  const UserPreferences({
    this.defaultLanguage = 'en',
    this.enablePushNotifications = true,
    this.enableCameraAutoFocus = true,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.enableAgingAlerts = true,
    this.enableLowStockAlerts = true,
    this.enableFavoriteReminders = true,
    this.favoriteReminderDays = 90,
    this.alertCooldownDays = 30,
  }) {
    if (favoriteReminderDays < 1 || favoriteReminderDays > 365) {
      throw ArgumentError('Favorite reminder days must be between 1 and 365');
    }
    if (alertCooldownDays < 1 || alertCooldownDays > 90) {
      throw ArgumentError('Alert cooldown days must be between 1 and 90');
    }
  }

  /// Convert UserPreferences to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'defaultLanguage': defaultLanguage,
      'enablePushNotifications': enablePushNotifications,
      'enableCameraAutoFocus': enableCameraAutoFocus,
      'temperatureUnit': temperatureUnit.name,
      'enableAgingAlerts': enableAgingAlerts,
      'enableLowStockAlerts': enableLowStockAlerts,
      'enableFavoriteReminders': enableFavoriteReminders,
      'favoriteReminderDays': favoriteReminderDays,
      'alertCooldownDays': alertCooldownDays,
    };
  }

  /// Create UserPreferences from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      defaultLanguage: json['defaultLanguage'] as String? ?? 'en',
      enablePushNotifications: json['enablePushNotifications'] as bool? ?? true,
      enableCameraAutoFocus: json['enableCameraAutoFocus'] as bool? ?? true,
      temperatureUnit: TemperatureUnit.values.firstWhere(
        (unit) => unit.name == json['temperatureUnit'],
        orElse: () => TemperatureUnit.celsius,
      ),
      enableAgingAlerts: json['enableAgingAlerts'] as bool? ?? true,
      enableLowStockAlerts: json['enableLowStockAlerts'] as bool? ?? true,
      enableFavoriteReminders: json['enableFavoriteReminders'] as bool? ?? true,
      favoriteReminderDays: json['favoriteReminderDays'] as int? ?? 90,
      alertCooldownDays: json['alertCooldownDays'] as int? ?? 30,
    );
  }

  /// Create a copy of UserPreferences with updated fields
  UserPreferences copyWith({
    String? defaultLanguage,
    bool? enablePushNotifications,
    bool? enableCameraAutoFocus,
    TemperatureUnit? temperatureUnit,
    bool? enableAgingAlerts,
    bool? enableLowStockAlerts,
    bool? enableFavoriteReminders,
    int? favoriteReminderDays,
    int? alertCooldownDays,
  }) {
    return UserPreferences(
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableCameraAutoFocus: enableCameraAutoFocus ?? this.enableCameraAutoFocus,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      enableAgingAlerts: enableAgingAlerts ?? this.enableAgingAlerts,
      enableLowStockAlerts: enableLowStockAlerts ?? this.enableLowStockAlerts,
      enableFavoriteReminders: enableFavoriteReminders ?? this.enableFavoriteReminders,
      favoriteReminderDays: favoriteReminderDays ?? this.favoriteReminderDays,
      alertCooldownDays: alertCooldownDays ?? this.alertCooldownDays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
        other.defaultLanguage == defaultLanguage &&
        other.enablePushNotifications == enablePushNotifications &&
        other.enableCameraAutoFocus == enableCameraAutoFocus &&
        other.temperatureUnit == temperatureUnit &&
        other.enableAgingAlerts == enableAgingAlerts &&
        other.enableLowStockAlerts == enableLowStockAlerts &&
        other.enableFavoriteReminders == enableFavoriteReminders &&
        other.favoriteReminderDays == favoriteReminderDays &&
        other.alertCooldownDays == alertCooldownDays;
  }

  @override
  int get hashCode {
    return defaultLanguage.hashCode ^
        enablePushNotifications.hashCode ^
        enableCameraAutoFocus.hashCode ^
        temperatureUnit.hashCode ^
        enableAgingAlerts.hashCode ^
        enableLowStockAlerts.hashCode ^
        enableFavoriteReminders.hashCode ^
        favoriteReminderDays.hashCode ^
        alertCooldownDays.hashCode;
  }

  @override
  String toString() {
    return 'UserPreferences('
        'defaultLanguage: $defaultLanguage, '
        'enablePushNotifications: $enablePushNotifications, '
        'enableCameraAutoFocus: $enableCameraAutoFocus, '
        'temperatureUnit: $temperatureUnit, '
        'enableAgingAlerts: $enableAgingAlerts, '
        'enableLowStockAlerts: $enableLowStockAlerts, '
        'enableFavoriteReminders: $enableFavoriteReminders, '
        'favoriteReminderDays: $favoriteReminderDays, '
        'alertCooldownDays: $alertCooldownDays)';
  }
}

/// User model representing authenticated app user with wine collection preferences
class User {
  final String uid;                    // Firebase Auth UID (primary key)
  final String email;                  // Authentication email
  final String? displayName;           // Optional display name
  final String? photoURL;              // Optional profile picture
  final DateTime createdAt;            // Account creation timestamp
  final DateTime lastLoginAt;          // Last authentication timestamp
  final UserPreferences preferences;   // App-specific settings

  const User({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    required this.preferences,
  }) {
    // Validate email format
    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format: $email');
    }
    
    // Validate display name length
    if (displayName != null && displayName!.length > 50) {
      throw ArgumentError('Display name cannot exceed 50 characters');
    }
    
    // Validate photo URL format
    if (photoURL != null && !_isValidHttpsUrl(photoURL!)) {
      throw ArgumentError('Photo URL must be a valid HTTPS URL');
    }
  }

  /// Validate email format using regex
  static bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Validate HTTPS URL format
  static bool _isValidHttpsUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https' && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Convert User to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'preferences': preferences.toJson(),
    };
  }

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : const UserPreferences(),
    );
  }

  /// Create a copy of User with updated fields
  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoURL == photoURL &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.preferences == preferences;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode ^
        preferences.hashCode;
  }

  @override
  String toString() {
    return 'User('
        'uid: $uid, '
        'email: $email, '
        'displayName: $displayName, '
        'photoURL: $photoURL, '
        'createdAt: $createdAt, '
        'lastLoginAt: $lastLoginAt, '
        'preferences: $preferences)';
  }
}
