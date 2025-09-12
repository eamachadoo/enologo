# Data Model: Wine Collection Management

## Core Entities

### User
**Purpose**: Represents an authenticated app user who owns wine collections
**Storage**: Firebase Authentication + Firestore user profile

```dart
class User {
  String uid;              // Firebase Auth UID (primary key)
  String email;            // Authentication email
  String? displayName;     // Optional display name
  String? photoURL;        // Optional profile picture
  DateTime createdAt;      // Account creation timestamp
  DateTime lastLoginAt;    // Last authentication timestamp
  UserPreferences preferences; // App-specific settings
}

class UserPreferences {
  String defaultLanguage;          // UI language preference
  bool enablePushNotifications;    // Global notification setting
  bool enableCameraAutoFocus;      // Camera behavior setting
  TemperatureUnit temperatureUnit; // Celsius/Fahrenheit for storage info
}
```

**Validation Rules**:
- Email must be valid format and unique
- Display name max 50 characters
- Photo URL must be valid HTTPS URL

### Warehouse
**Purpose**: Represents a physical storage location for wine collection
**Storage**: Firestore collection `warehouses`

```dart
class Warehouse {
  String id;               // Firestore document ID
  String userId;           // Owner user ID (foreign key)
  String name;             // User-defined warehouse name
  String? description;     // Optional warehouse description
  String? location;        // Optional physical address
  double? latitude;        // Optional GPS coordinates
  double? longitude;       // Optional GPS coordinates
  int wineCount;           // Cached count of wines in warehouse
  DateTime createdAt;      // Creation timestamp
  DateTime updatedAt;      // Last modification timestamp
}
```

**Validation Rules**:
- Name required, 1-100 characters
- Description max 500 characters
- Location max 200 characters
- Latitude/longitude must be valid coordinates
- User can have max 20 warehouses

**Relationships**:
- One User has many Warehouses (1:N)
- One Warehouse contains many Wines (1:N)

### Wine
**Purpose**: Represents an individual wine entry with inventory tracking
**Storage**: Firestore collection `wines`

```dart
class Wine {
  String id;               // Firestore document ID
  String userId;           // Owner user ID (foreign key)
  String warehouseId;      // Storage location (foreign key)
  String name;             // Wine name (extracted or manual)
  int? year;               // Vintage year (extracted or manual)
  String? winery;          // Producer name (optional)
  String? region;          // Wine region (optional)
  WineType? type;          // Red, White, Rosé, Sparkling, etc.
  int quantity;            // Current bottle count
  int? alertThreshold;     // Low stock alert trigger
  String? notes;           // User notes about the wine
  List<String> imageUrls;  // Firebase Storage URLs for photos
  DateTime createdAt;      // Entry creation timestamp
  DateTime updatedAt;      // Last modification timestamp
  WineMetadata metadata;   // Additional optional fields
}

enum WineType {
  red, white, rose, sparkling, dessert, fortified
}

class WineMetadata {
  double? alcoholContent;  // ABV percentage
  String? grapeVariety;    // Grape types
  double? rating;          // User rating 1-5
  double? price;           // Purchase price
  String? purchaseLocation; // Where acquired
  DateTime? purchaseDate;  // When acquired
  String? storageNotes;    // Temperature, position info
}
```

**Validation Rules**:
- Name required, 1-200 characters
- Year must be between 1800 and current year + 5
- Quantity must be non-negative integer
- Alert threshold must be non-negative and <= quantity
- Notes max 1000 characters
- Rating must be between 1.0 and 5.0
- Max 10 images per wine

**Relationships**:
- One User has many Wines (1:N)
- One Warehouse contains many Wines (1:N)
- One Wine has many Consumption Events (1:N)

### ConsumptionEvent
**Purpose**: Records when and how wine was consumed for tracking history
**Storage**: Firestore collection `consumption_events`

```dart
class ConsumptionEvent {
  String id;               // Firestore document ID
  String userId;           // Owner user ID (foreign key)
  String wineId;           // Consumed wine (foreign key)
  int quantity;            // Number of bottles consumed
  DateTime consumedAt;     // When wine was consumed
  String? occasion;        // Event/reason for consumption
  String? notes;           // Tasting notes or experience
  List<String>? companions; // Who shared the wine
  double? rating;          // Rating for this specific consumption
  String? location;        // Where consumed
  DateTime createdAt;      // Record creation timestamp
}
```

**Validation Rules**:
- Quantity must be positive integer
- Consumed date cannot be in future
- Occasion max 100 characters
- Notes max 500 characters
- Rating must be between 1.0 and 5.0
- Location max 100 characters
- Max 20 companions per event

**Relationships**:
- One User has many Consumption Events (1:N)
- One Wine has many Consumption Events (1:N)

### Alert
**Purpose**: System-generated notifications for low stock warnings
**Storage**: Firestore collection `alerts`

```dart
class Alert {
  String id;               // Firestore document ID
  String userId;           // Target user (foreign key)
  String wineId;           // Related wine (foreign key)
  AlertType type;          // Type of alert
  String title;            // Alert headline
  String message;          // Alert description
  bool isRead;             // User acknowledgment status
  bool isActive;           // Whether alert is still relevant
  DateTime triggeredAt;    // When alert was created
  DateTime? readAt;        // When user acknowledged alert
  DateTime? expiresAt;     // Optional expiration time
}

enum AlertType {
  lowStock,        // Quantity below threshold
  zeroStock,       // Completely out of wine
  oldWine,         // Wine aging beyond optimal period
  priceAlert       // Future: price tracking alerts
}
```

**Validation Rules**:
- Title required, max 100 characters
- Message required, max 300 characters
- Triggered date cannot be in future
- Read date must be after triggered date

**Relationships**:
- One User has many Alerts (1:N)
- One Wine can trigger many Alerts (1:N)

## Firestore Collections Structure

```
/users/{userId}
  - User profile data

/warehouses/{warehouseId}
  - Warehouse documents
  - Index: userId, name
  - Security: user owns warehouse

/wines/{wineId}
  - Wine documents
  - Index: userId, warehouseId, name, year
  - Security: user owns wine

/consumption_events/{eventId}
  - Consumption event documents
  - Index: userId, wineId, consumedAt
  - Security: user owns event

/alerts/{alertId}
  - Alert documents
  - Index: userId, isRead, triggeredAt
  - Security: user owns alert
```

## State Transitions

### Wine Quantity Management
```
Initial: quantity = N
Consume: quantity = N - consumed_amount
  → If quantity <= alertThreshold: Create Alert
  → If quantity = 0: Create zeroStock Alert
Add Stock: quantity = N + added_amount
  → If quantity > alertThreshold: Deactivate lowStock Alert
```

### Alert Lifecycle
```
Triggered → Active (isActive = true, isRead = false)
Active → Read (isRead = true, user acknowledged)
Active → Resolved (isActive = false, condition no longer met)
```

## Data Access Patterns

### Common Queries
1. **User's warehouses**: `WHERE userId == currentUser ORDER BY name`
2. **Wines in warehouse**: `WHERE warehouseId == selected ORDER BY name`
3. **Search wines**: `WHERE userId == currentUser AND name >= searchTerm`
4. **Recent consumption**: `WHERE userId == currentUser ORDER BY consumedAt DESC LIMIT 20`
5. **Active alerts**: `WHERE userId == currentUser AND isActive == true ORDER BY triggeredAt`

### Performance Considerations
- Compound indexes for multi-field queries
- Denormalized wine count in Warehouse for dashboard
- Pagination for large collections
- Offline caching for frequently accessed data

## Security Rules Preview
```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /warehouses/{warehouseId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /wines/{wineId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Similar rules for consumption_events and alerts
  }
}
```
