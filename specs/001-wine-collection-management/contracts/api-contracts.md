# API Contracts: Wine Collection Management

## Authentication Service Contract

### POST /auth/signin
**Purpose**: Authenticate user with email/password or Google OAuth

```dart
// Request
class SignInRequest {
  required String email;
  required String password;
  String? provider; // "email" | "google"
}

// Response
class SignInResponse {
  required String accessToken;
  required String refreshToken;
  required UserProfile user;
  required DateTime expiresAt;
}

class UserProfile {
  required String uid;
  required String email;
  String? displayName;
  String? photoURL;
}
```

**Error Responses**:
- 401: Invalid credentials
- 400: Malformed request
- 429: Too many attempts

### POST /auth/signup
**Purpose**: Create new user account

```dart
// Request
class SignUpRequest {
  required String email;
  required String password;
  String? displayName;
}

// Response: Same as SignInResponse
```

**Error Responses**:
- 409: Email already exists
- 400: Password requirements not met

### POST /auth/refresh
**Purpose**: Refresh expired access token

```dart
// Request
class RefreshTokenRequest {
  required String refreshToken;
}

// Response: Same as SignInResponse
```

## Warehouse Management Contract

### GET /warehouses
**Purpose**: Retrieve user's warehouse list

```dart
// Response
class WarehouseListResponse {
  required List<WarehouseDto> warehouses;
  required int totalCount;
}

class WarehouseDto {
  required String id;
  required String name;
  String? description;
  String? location;
  required int wineCount;
  required DateTime createdAt;
  required DateTime updatedAt;
}
```

### POST /warehouses
**Purpose**: Create new warehouse

```dart
// Request
class CreateWarehouseRequest {
  required String name;
  String? description;
  String? location;
  double? latitude;
  double? longitude;
}

// Response
class WarehouseCreatedResponse {
  required String id;
  required WarehouseDto warehouse;
}
```

**Error Responses**:
- 400: Invalid warehouse data
- 409: Warehouse name already exists
- 422: Maximum warehouses exceeded

### PUT /warehouses/{id}
**Purpose**: Update existing warehouse

```dart
// Request: Same as CreateWarehouseRequest (all fields optional)
// Response: Updated WarehouseDto
```

### DELETE /warehouses/{id}
**Purpose**: Delete warehouse (must be empty)

```dart
// Response: 204 No Content
```

**Error Responses**:
- 409: Warehouse contains wines
- 404: Warehouse not found

## Wine Management Contract

### GET /warehouses/{warehouseId}/wines
**Purpose**: Retrieve wines in specific warehouse with search/filter

```dart
// Query Parameters
class WineSearchParams {
  String? search;          // Name search term
  int? year;              // Filter by vintage year
  WineType? type;         // Filter by wine type
  String? sortBy;         // "name" | "year" | "quantity" | "createdAt"
  String? sortOrder;      // "asc" | "desc"
  int? limit;             // Pagination limit (default 20)
  String? cursor;         // Pagination cursor
}

// Response
class WineListResponse {
  required List<WineDto> wines;
  required int totalCount;
  String? nextCursor;     // For pagination
}

class WineDto {
  required String id;
  required String name;
  int? year;
  String? winery;
  String? region;
  WineType? type;
  required int quantity;
  int? alertThreshold;
  String? notes;
  required List<String> imageUrls;
  WineMetadataDto? metadata;
  required DateTime createdAt;
  required DateTime updatedAt;
}

class WineMetadataDto {
  double? alcoholContent;
  String? grapeVariety;
  double? rating;
  double? price;
  String? purchaseLocation;
  DateTime? purchaseDate;
  String? storageNotes;
}
```

### POST /warehouses/{warehouseId}/wines
**Purpose**: Add new wine to warehouse

```dart
// Request
class CreateWineRequest {
  required String name;
  int? year;
  String? winery;
  String? region;
  WineType? type;
  required int quantity;
  int? alertThreshold;
  String? notes;
  WineMetadataDto? metadata;
}

// Response
class WineCreatedResponse {
  required String id;
  required WineDto wine;
}
```

**Error Responses**:
- 400: Invalid wine data
- 404: Warehouse not found
- 422: Validation errors

### PUT /wines/{id}
**Purpose**: Update wine details

```dart
// Request: Same as CreateWineRequest (all fields optional except quantity)
// Response: Updated WineDto
```

### DELETE /wines/{id}
**Purpose**: Remove wine from collection

```dart
// Response: 204 No Content
```

### POST /wines/{id}/consume
**Purpose**: Record wine consumption

```dart
// Request
class ConsumeWineRequest {
  required int quantity;
  DateTime? consumedAt;    // Defaults to now
  String? occasion;
  String? notes;
  List<String>? companions;
  double? rating;
  String? location;
}

// Response
class ConsumptionRecordedResponse {
  required String eventId;
  required int remainingQuantity;
  bool alertTriggered;
}
```

**Error Responses**:
- 409: Insufficient quantity
- 400: Invalid consumption data

## Image Management Contract

### POST /wines/{id}/images
**Purpose**: Upload wine bottle/label photos

```dart
// Request: Multipart form with image file
// Max file size: 10MB
// Supported formats: JPEG, PNG, WebP

// Response
class ImageUploadResponse {
  required String imageUrl;
  required String thumbnailUrl;
  required ImageMetadata metadata;
}

class ImageMetadata {
  required int width;
  required int height;
  required int fileSizeBytes;
  required String format;
  DateTime? extractedDate;  // EXIF data
}
```

### DELETE /wines/{id}/images/{imageUrl}
**Purpose**: Remove wine image

```dart
// Response: 204 No Content
```

## Text Recognition Contract

### POST /ml/extract-text
**Purpose**: Extract text from wine label image

```dart
// Request: Multipart form with image file

// Response
class TextExtractionResponse {
  required List<TextBlock> textBlocks;
  ExtractedWineInfo? extractedInfo;  // Structured extraction
}

class TextBlock {
  required String text;
  required BoundingBox boundingBox;
  required double confidence;
}

class BoundingBox {
  required double x;
  required double y;
  required double width;
  required double height;
}

class ExtractedWineInfo {
  String? wineName;
  int? year;
  String? winery;
  String? region;
  double? confidence;  // Overall extraction confidence
}
```

**Error Responses**:
- 413: Image too large
- 415: Unsupported image format
- 422: No text detected

## Consumption History Contract

### GET /consumption-events
**Purpose**: Retrieve user's consumption history

```dart
// Query Parameters
class ConsumptionHistoryParams {
  DateTime? startDate;
  DateTime? endDate;
  String? wineId;         // Filter by specific wine
  String? sortBy;         // "consumedAt" | "rating"
  String? sortOrder;      // "asc" | "desc"
  int? limit;            // Default 50
  String? cursor;        // Pagination
}

// Response
class ConsumptionHistoryResponse {
  required List<ConsumptionEventDto> events;
  required int totalCount;
  String? nextCursor;
}

class ConsumptionEventDto {
  required String id;
  required String wineId;
  required String wineName;  // Denormalized for display
  required int quantity;
  required DateTime consumedAt;
  String? occasion;
  String? notes;
  List<String>? companions;
  double? rating;
  String? location;
}
```

## Alerts Contract

### GET /alerts
**Purpose**: Retrieve user's active alerts

```dart
// Query Parameters
class AlertsParams {
  bool? includeRead;      // Default false (only unread)
  AlertType? type;        // Filter by alert type
  int? limit;            // Default 20
}

// Response
class AlertsResponse {
  required List<AlertDto> alerts;
  required int unreadCount;
}

class AlertDto {
  required String id;
  required String wineId;
  required String wineName;  // Denormalized
  required AlertType type;
  required String title;
  required String message;
  required bool isRead;
  required DateTime triggeredAt;
  DateTime? readAt;
}
```

### PUT /alerts/{id}/read
**Purpose**: Mark alert as read

```dart
// Response: Updated AlertDto
```

### DELETE /alerts/{id}
**Purpose**: Dismiss alert

```dart
// Response: 204 No Content
```

## Error Response Format

All API endpoints follow consistent error response format:

```dart
class ApiError {
  required String code;
  required String message;
  String? details;
  Map<String, dynamic>? context;
  DateTime timestamp;
}

// Common error codes:
// - VALIDATION_ERROR: Input validation failed
// - AUTHENTICATION_ERROR: Invalid or expired token
// - AUTHORIZATION_ERROR: Insufficient permissions
// - RESOURCE_NOT_FOUND: Requested resource doesn't exist
// - RESOURCE_CONFLICT: Operation conflicts with current state
// - RATE_LIMIT_EXCEEDED: Too many requests
// - SERVER_ERROR: Internal server error
```

## Rate Limiting

All endpoints implement rate limiting:
- Authentication: 5 requests per minute per IP
- Image upload: 10 requests per minute per user
- Text extraction: 20 requests per minute per user
- General API: 100 requests per minute per user

## Response Headers

Standard headers included in all responses:
- `X-RateLimit-Remaining`: Remaining requests in current window
- `X-RateLimit-Reset`: When rate limit window resets
- `X-Request-ID`: Unique identifier for request tracing
