# Wine Collection Notification System

## Overview

Intelligent notification system for wine collection management with three main alert types:
1. **Aging Alerts**: Notify when wines reach preferred consumption age
2. **Low Stock Alerts**: Notify when wine quantities drop below thresholds  
3. **Favorite Wine Reminders**: Suggest revisiting favorite wines not consumed recently

## Architecture

### Backend Components

#### 1. Firebase Cloud Functions (Scheduled)
**Function**: `daily-wine-alerts`
- **Trigger**: Daily cron job (runs at 10:00 AM user's timezone)
- **Purpose**: Process all wine aging, low stock, and favorite reminders
- **Deployment**: Firebase Functions with timezone-aware scheduling

#### 2. Firebase Cloud Functions (On-Write)
**Function**: `wine-quantity-change`
- **Trigger**: Firestore write on `wines/{wineId}` quantity field
- **Purpose**: Immediate low stock alerts when wine is consumed
- **Deployment**: Firestore triggered function

#### 3. Firebase Cloud Messaging (FCM)
- **Purpose**: Cross-platform push notification delivery
- **Features**: Background notifications, custom data payload, notification grouping

### Data Model Extensions

#### Wine Document (Enhanced)
```dart
class Wine {
  // ... existing fields ...
  
  // Notification-related fields
  int? preferredConsumptionAgeYears; // User preference (e.g., 5 years)
  DateTime? nextAlertDate;           // Calculated: vintage_year + preference
  DateTime? lastAlertSent;           // Anti-spam for aging alerts
  bool isFavorite;                   // User-marked favorite
  DateTime? lastConsumedDate;        // Last consumption (from ConsumptionEvent)
  DateTime? lastFavoriteReminderSent; // Anti-spam for favorite reminders
}
```

#### User Preferences (Enhanced)
```dart
class UserPreferences {
  // ... existing fields ...
  
  bool enableAgingAlerts;          // Wine aging notifications (default: true)
  bool enableLowStockAlerts;       // Low stock notifications (default: true) 
  bool enableFavoriteReminders;    // Favorite wine reminders (default: true)
  int favoriteReminderDays;        // Days before suggesting favorites (default: 90)
  int alertCooldownDays;           // Days between similar alerts (default: 30)
}
```

## Notification Logic

### 1. Wine Aging Alerts

#### Trigger Calculation
```javascript
// Cloud Function logic
alertYear = wine.year + wine.preferredConsumptionAgeYears;
currentYear = new Date().getFullYear();

if (currentYear >= alertYear && 
    wine.quantity > 0 &&
    !wine.lastAlertSent || 
    daysSince(wine.lastAlertSent) >= user.preferences.alertCooldownDays) {
  
  sendNotification({
    type: 'agingReady',
    title: `${wine.name} is Ready to Drink!`,
    message: `Your ${wine.year} ${wine.name} has reached ${wine.preferredConsumptionAgeYears} years. Perfect time to enjoy it!`,
    data: { wineId: wine.id, type: 'aging' }
  });
  
  // Update anti-spam timestamp
  wine.lastAlertSent = new Date();
}
```

#### User Experience
- **Notification**: "🍷 Château Margaux 2015 is Ready to Drink!"
- **Message**: "Your 2015 Château Margaux has reached 5 years. Perfect time to enjoy it! You have 3 bottles remaining."
- **Action**: Tap to view wine details and consumption options

### 2. Low Stock Alerts

#### Immediate Trigger (On-Write Function)
```javascript
// Triggered when wine.quantity changes
if (newQuantity <= wine.alertThreshold && 
    newQuantity > 0 &&
    (!wine.lastAlertSent || daysSince(wine.lastAlertSent) >= 7)) {
  
  sendNotification({
    type: 'lowStock',
    title: `Running Low: ${wine.name}`,
    message: `Only ${newQuantity} bottle(s) left of ${wine.name}. Consider restocking!`,
    data: { wineId: wine.id, type: 'lowStock' }
  });
}

// Zero stock alert
if (newQuantity === 0) {
  sendNotification({
    type: 'zeroStock', 
    title: `Out of Stock: ${wine.name}`,
    message: `You've finished your last bottle of ${wine.name}. Time to find more!`,
    data: { wineId: wine.id, type: 'zeroStock' }
  });
}
```

#### User Experience
- **Low Stock**: "📦 Running Low: Opus One 2018 - Only 2 bottles left"
- **Zero Stock**: "🚫 Out of Stock: Opus One 2018 - Time to restock!"

### 3. Favorite Wine Reminders

#### Daily Check Logic
```javascript
// Daily function checks favorite wines
favoriteWines = wines.filter(w => w.isFavorite && w.quantity > 0);

for (let wine of favoriteWines) {
  daysSinceConsumed = daysSince(wine.lastConsumedDate);
  daysSinceReminder = daysSince(wine.lastFavoriteReminderSent);
  
  if (daysSinceConsumed >= user.preferences.favoriteReminderDays &&
      daysSinceReminder >= user.preferences.alertCooldownDays) {
    
    sendNotification({
      type: 'favoriteReminder',
      title: `Revisit Your Favorite: ${wine.name}`,
      message: `Today is perfect to revisit your favorite ${wine.name}! You have ${wine.quantity} bottles to enjoy.`,
      data: { wineId: wine.id, type: 'favorite' }
    });
    
    wine.lastFavoriteReminderSent = new Date();
  }
}
```

#### User Experience
- **Reminder**: "⭐ Revisit Your Favorite: Dom Pérignon 2010"
- **Message**: "Today is perfect to revisit your favorite Dom Pérignon 2010! You have 2 bottles to enjoy."
- **Frequency**: Configurable (default: every 90 days, max once per 30 days)

## Implementation Phases

### Phase 1: Local Notifications (MVP)
**Current Implementation Phase**: Add notification fields to models and tests
- Update Wine model with notification fields
- Update UserPreferences with notification settings
- Create local notification service for basic alerts
- **Files to Update**: 
  - `lib/models/wine.dart`
  - `lib/models/user_preferences.dart`
  - `test/models/wine_test.dart` 
  - `test/models/user_test.dart`

### Phase 2: Firebase Cloud Functions (Enhanced)
**Future Implementation**: Full cloud-based notification system
- Deploy Firebase Cloud Functions for automated alerts
- Implement FCM push notifications
- Add timezone-aware scheduling
- Create notification management UI

### Phase 3: Advanced Features (Future)
- ML-based consumption pattern predictions
- Price tracking alerts integration
- Social features (shared collection alerts)
- Advanced notification customization

## Anti-Spam Mechanisms

### 1. Cooldown Periods
- **Aging Alerts**: Once per wine per cooldown period (default: 30 days)
- **Low Stock**: Maximum once per week per wine
- **Favorite Reminders**: Configurable interval (default: 90 days, min: 30 days)

### 2. Smart Suppression
- No alerts for wines with 0 quantity (except zero stock notification)
- No duplicate alerts for same wine/type within cooldown period
- User preference respect (can disable each alert type)

### 3. Notification Grouping
- Batch similar notifications (e.g., "3 wines are ready to drink")
- Smart timing (avoid night hours, respect timezone)
- Priority ordering (zero stock > low stock > aging > favorites)

## Testing Strategy

### Unit Tests
- Wine model validation with notification fields
- UserPreferences notification settings validation
- Alert creation and timing logic

### Integration Tests  
- Notification service with local storage
- Alert lifecycle management
- User preference integration

### Cloud Function Tests (Future)
- Scheduled function execution
- Firebase emulator testing
- End-to-end notification flow

## Configuration

### Default Settings
```dart
UserPreferences defaultNotificationSettings = UserPreferences(
  enableAgingAlerts: true,
  enableLowStockAlerts: true, 
  enableFavoriteReminders: true,
  favoriteReminderDays: 90,
  alertCooldownDays: 30,
);

Wine defaultNotificationFields = Wine(
  preferredConsumptionAgeYears: null, // User must set
  nextAlertDate: null,                // Calculated automatically
  lastAlertSent: null,                // Updated by system
  isFavorite: false,                  // User can toggle
  lastConsumedDate: null,             // Updated from ConsumptionEvent
  lastFavoriteReminderSent: null,     // Updated by system
);
```

This notification system provides intelligent, user-customizable wine collection alerts while respecting user preferences and preventing notification spam.
