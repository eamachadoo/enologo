# Tasks: Wine Collection Management Mobile App

**Input**: Design documents from `/specs/001-wine-collection-management/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/, quickstart.md

## MVP Feature Prioritization
**Core MVP Features (Must Have)**:
1. User authentication (Firebase Auth)
2. Warehouse management (CRUD operations)
3. Basic wine entry (manual input only for MVP)
4. Wine inventory display and basic search
5. Simple consumption tracking

**Enhanced Features (Phase 2)**:
6. Camera-based wine entry with ML Kit
7. Advanced search and filtering
8. Real-time alerts and notifications
9. Consumption history and analytics
10. Performance optimizations and polish

## Path Structure
Based on plan.md: Flutter mobile app with Firebase backend
- **Mobile**: `lib/` (Flutter/Dart code)
- **Tests**: `test/` (Flutter test framework)
- **Firebase**: `firebase/` (Cloud Functions, Firestore rules)

## Phase 3.1: Project Setup & Infrastructure

### T001 - Flutter Project Initialization
Create Flutter project structure with Firebase configuration
**Files**: Root project structure, `pubspec.yaml`, Firebase configuration files
**Dependencies**: None

### T002 - [P] Local Storage Setup (Firebase Deferred)
Setup SharedPreferences and local JSON storage for MVP (Firebase integration moved to Phase 2)
**Files**: `lib/services/local_storage_service.dart`, `lib/utils/json_storage.dart`
**Dependencies**: None

### T003 - [P] Flutter Dependencies Configuration (Core Only)
Core dependencies already configured: flutter_bloc, http, shared_preferences, path_provider
**Files**: `pubspec.yaml` (already configured with working dependencies)
**Dependencies**: T001

### T004 - [P] Project Structure Setup
Create lib/ folder structure: models/, services/, screens/, widgets/, utils/
**Files**: Directory structure in `lib/`
**Dependencies**: T001

### T005 - [P] Development Tools Configuration
Setup linting, formatting, and analysis options
**Files**: `analysis_options.yaml`, `.gitignore`
**Dependencies**: None

## Phase 3.2: Tests First (TDD) - MVP Core ⚠️ MUST COMPLETE BEFORE 3.3

### T006 - [P] User Authentication Service Tests (Local Storage)
Write unit tests for local authentication wrapper (JWT tokens stored locally)
**Files**: `test/services/auth_service_test.dart`
**Dependencies**: T003, T004

### T007 - [P] Warehouse Model Tests (Local JSON)
Write unit tests for Warehouse model validation and JSON serialization
**Files**: `test/models/warehouse_test.dart`
**Dependencies**: T004

### T008 - [P] Wine Model Tests (Local JSON)
Write unit tests for Wine model validation and JSON serialization
**Files**: `test/models/wine_test.dart`
**Dependencies**: T004

### T009 - [P] Warehouse Service Tests (Local Storage)
Write unit tests for Warehouse CRUD operations using local storage
**Files**: `test/services/warehouse_service_test.dart`
**Dependencies**: T007

### T010 - [P] Wine Service Tests (Local Storage)
Write unit tests for Wine CRUD operations using local storage
**Files**: `test/services/wine_service_test.dart` 
**Dependencies**: T008

### T011 - [P] Authentication Flow Integration Tests
Write widget tests for sign in/sign up flows
**Files**: `test/integration/auth_flow_test.dart`
**Dependencies**: T006

### T012 - [P] Warehouse Management Integration Tests
Write widget tests for warehouse CRUD operations
**Files**: `test/integration/warehouse_flow_test.dart`
**Dependencies**: T009

### T013 - [P] Wine Management Integration Tests
Write widget tests for wine CRUD operations (manual entry only for MVP)
**Files**: `test/integration/wine_flow_test.dart`
**Dependencies**: T010

## Phase 3.3: MVP Core Implementation (ONLY after tests are failing)

### T014 - [P] User Model Implementation
Implement User and UserPreferences models with JSON serialization
**Files**: `lib/models/user.dart`, `lib/models/user_preferences.dart`
**Dependencies**: T006 (tests must be failing)

### T015 - [P] Warehouse Model Implementation (Local JSON)
Implement Warehouse model with validation and JSON serialization
**Files**: `lib/models/warehouse.dart`
**Dependencies**: T007 (tests must be failing)

### T016 - [P] Wine Model Implementation (Local JSON)
Implement Wine, WineMetadata, and related models with JSON serialization
**Files**: `lib/models/wine.dart`, `lib/models/wine_metadata.dart`, `lib/models/wine_type.dart`
**Dependencies**: T008 (tests must be failing)

### T017 - Authentication Service Implementation (Local)
Implement local authentication service with mock login/logout
**Files**: `lib/services/auth_service.dart`
**Dependencies**: T006 (tests must be failing), T014

### T018 - Warehouse Service Implementation (Local Storage)
Implement SharedPreferences/JSON-based Warehouse CRUD operations
**Files**: `lib/services/warehouse_service.dart`
**Dependencies**: T009 (tests must be failing), T015

### T019 - Wine Service Implementation (Local Storage)
Implement SharedPreferences/JSON-based Wine CRUD operations
**Files**: `lib/services/wine_service.dart`
**Dependencies**: T010 (tests must be failing), T016

### T020 - [P] Authentication Screens
Implement Sign In and Sign Up screens with form validation
**Files**: `lib/screens/auth/sign_in_screen.dart`, `lib/screens/auth/sign_up_screen.dart`
**Dependencies**: T017, T011 (tests must be failing)

### T021 - [P] Warehouse Management Screens
Implement warehouse list, create, and edit screens
**Files**: `lib/screens/warehouse/warehouse_list_screen.dart`, `lib/screens/warehouse/warehouse_form_screen.dart`
**Dependencies**: T018, T012 (tests must be failing)

### T022 - Wine List Screen (MVP)
Implement basic wine inventory display with simple search
**Files**: `lib/screens/wine/wine_list_screen.dart`
**Dependencies**: T019, T013 (tests must be failing)

### T023 - Manual Wine Entry Screen (MVP)
Implement manual wine entry form (no camera for MVP)
**Files**: `lib/screens/wine/wine_form_screen.dart`
**Dependencies**: T019, T013 (tests must be failing)

### T024 - Basic Consumption Tracking
Implement simple wine consumption recording
**Files**: `lib/screens/wine/consumption_screen.dart`, `lib/models/consumption_event.dart`
**Dependencies**: T019

## Phase 3.4: MVP Integration & Navigation

### T025 - App Navigation Setup
Implement app routing and bottom navigation for MVP screens
**Files**: `lib/utils/app_router.dart`, `lib/screens/main_screen.dart`
**Dependencies**: T020, T021, T022

### T026 - Local Storage Configuration Integration
Connect all services to local storage and implement error handling
**Files**: `lib/utils/local_storage_config.dart`, `lib/utils/error_handler.dart`
**Dependencies**: T017, T018, T019

### T027 - State Management Setup
Implement Bloc/Cubit pattern for app state management
**Files**: `lib/blocs/auth_bloc.dart`, `lib/blocs/warehouse_bloc.dart`, `lib/blocs/wine_bloc.dart`
**Dependencies**: T017, T018, T019

### T028 - MVP App Integration
Wire all components together for complete MVP functionality
**Files**: `lib/main.dart`, app-wide integration
**Dependencies**: T025, T026, T027

## Phase 3.5: MVP Polish & Testing

### T029 - [P] MVP Manual Testing
Execute quickstart.md scenarios for MVP features only
**Files**: Manual testing following `quickstart.md` (authentication, warehouses, manual wine entry)
**Dependencies**: T028

### T030 - [P] MVP Performance Testing
Test app startup time, navigation speed, and memory usage
**Files**: Performance test documentation
**Dependencies**: T028

### T031 - [P] Local Data Security
Implement data validation and sanitization for local storage
**Files**: `lib/utils/data_validator.dart`
**Dependencies**: T002, T028

### T032 - [P] Error Handling Polish
Improve error messages and user feedback throughout MVP
**Files**: Various screen files for error handling improvements
**Dependencies**: T026

### T033 - MVP Code Review & Cleanup
Remove duplication, improve code quality, add documentation
**Files**: Code cleanup across all implemented files
**Dependencies**: T029, T030

## Phase 3.6: Firebase Migration (Post-MVP Local Storage)

### T034 - [P] Firebase Project Setup
Configure Firebase project with Authentication, Firestore, and Storage
**Files**: `firebase/firestore.rules`, `firebase/storage.rules`, `firebase.json`
**Dependencies**: T033

### T035 - [P] Firebase Dependencies Integration
Add compatible Firebase dependencies to pubspec.yaml
**Files**: `pubspec.yaml` (add firebase_core ^3.0.0+, cloud_firestore ^5.0.0+, firebase_auth ^5.0.0+)
**Dependencies**: T034

### T036 - [P] Firebase Service Migration Tests
Write tests for migrating local storage to Firebase
**Files**: `test/services/firebase_migration_test.dart`
**Dependencies**: T035

### T037 - [P] Firebase Service Implementations
Implement Firebase versions of auth, warehouse, and wine services
**Files**: `lib/services/firebase_auth_service.dart`, `lib/services/firebase_warehouse_service.dart`, `lib/services/firebase_wine_service.dart`
**Dependencies**: T036 (tests must be failing)

### T038 - [P] Data Migration Service
Implement service to migrate local data to Firebase
**Files**: `lib/services/data_migration_service.dart`
**Dependencies**: T037

## Phase 3.7: Enhanced Features (Camera & ML Kit)

### T039 - [P] Camera Dependencies Integration
Add compatible camera and ML Kit dependencies
**Files**: `pubspec.yaml` (add camera ^0.11.0+, google_mlkit_text_recognition ^0.13.0+)
**Dependencies**: T038

### T040 - [P] Camera Service Tests
Write tests for camera integration and image capture
**Files**: `test/services/camera_service_test.dart`
**Dependencies**: T039

### T041 - [P] ML Kit Text Recognition Tests
Write tests for wine label text extraction
**Files**: `test/services/text_recognition_service_test.dart`
**Dependencies**: T039

### T042 - [P] Advanced Search/Filter Tests
Write tests for complex wine search and filtering
**Files**: `test/services/search_service_test.dart`
**Dependencies**: T038

### T043 - [P] Alert System Tests
Write tests for low stock alerts and notifications
**Files**: `test/services/alert_service_test.dart`
**Dependencies**: T038

### T044 - Camera Service Implementation
Implement camera capture and image processing
**Files**: `lib/services/camera_service.dart`
**Dependencies**: T040 (tests must be failing)

### T045 - ML Kit Text Recognition Implementation
Implement wine label text extraction using Google ML Kit
**Files**: `lib/services/text_recognition_service.dart`
**Dependencies**: T041 (tests must be failing)

### T046 - Camera Wine Entry Screen
Implement camera-based wine entry with OCR
**Files**: `lib/screens/wine/camera_wine_entry_screen.dart`
**Dependencies**: T044, T045

### T047 - Advanced Search Implementation
Implement complex search with filters by name, year, type, etc.
**Files**: `lib/services/search_service.dart`, updated wine list screen
**Dependencies**: T042 (tests must be failing)

### T048 - Alert System Implementation
Implement low stock alerts and push notifications
**Files**: `lib/services/alert_service.dart`, `lib/models/alert.dart`
**Dependencies**: T043 (tests must be failing)

### T049 - Consumption Analytics
Implement detailed consumption history and statistics
**Files**: `lib/screens/analytics/consumption_analytics_screen.dart`
**Dependencies**: T024

### T050 - [P] Enhanced Feature Integration Testing
Test all enhanced features together
**Files**: Integration tests for camera, search, alerts
**Dependencies**: T046, T047, T048

### T051 - [P] Performance Optimization
Optimize image handling, database queries, and app performance
**Files**: Performance improvements across services
**Dependencies**: T050

### T052 - [P] Final Documentation
Create user documentation and developer setup guide
**Files**: `README.md`, `docs/` folder
**Dependencies**: T051

## Dependencies Summary

**Critical Path for MVP (Local Storage)**:
1. Setup (T001-T005) → Tests (T006-T013) → Models (T014-T016) → Services (T017-T019) → Screens (T020-T024) → Integration (T025-T028) → Polish (T029-T033)

**Firebase Migration** (can start after MVP complete):
2. Firebase Setup (T034-T038) 

**Enhanced Features** (can start after Firebase migration):
3. Camera/ML Kit (T039-T052)

## MVP Completion Criteria (Updated)
- ✅ User can authenticate with mock local authentication
- ✅ User can create and manage warehouses (stored locally)
- ✅ User can manually add wines to warehouses (stored locally)
- ✅ User can view wine inventory with basic search
- ✅ User can record wine consumption (stored locally)
- ✅ All MVP tests pass
- ✅ App runs on both iOS and Android
- ✅ Data persists in local storage (SharedPreferences + JSON)

## Notes (Updated)
- **MVP uses LOCAL STORAGE** (SharedPreferences + JSON) - no Firebase required
- **Firebase migration** happens in Phase 3.6 after MVP is complete
- **Camera/ML Kit features** happen in Phase 3.7 after Firebase migration
- **[P]** tasks can run in parallel (different files, no dependencies)
- **ALL TESTS MUST FAIL** before implementing corresponding features (TDD)
- Commit after each completed task
- Local development doesn't require Firebase setup initially
