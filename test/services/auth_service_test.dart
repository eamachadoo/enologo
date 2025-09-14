import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the service we'll implement
import 'package:wine_collection_app/services/auth_service.dart';
import 'package:wine_collection_app/models/user.dart';

// Mock classes for dependencies
@GenerateMocks([SharedPreferences])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService Tests (Local Storage)', () {
    late MockSharedPreferences mockSharedPreferences;
    late AuthService authService;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      authService = AuthService(sharedPreferences: mockSharedPreferences);
    });

    group('Authentication State Management', () {
      test('should return false when no user is logged in', () async {
        // Arrange
        when(mockSharedPreferences.getString('user_token'))
            .thenReturn(null);
        when(mockSharedPreferences.getString('user_data'))
            .thenReturn(null);

        // Act & Assert
        final isLoggedIn = await authService.isLoggedIn();
        expect(isLoggedIn, false);
      });

      test('should return true when valid user token exists', () async {
        // Arrange
        const validToken = 'valid_jwt_token_here';
        const userData = '{"id":"123","email":"test@example.com","name":"Test User","createdAt":"2024-01-01T00:00:00.000Z"}';
        
        when(mockSharedPreferences.getString('user_token'))
            .thenReturn(validToken);
        when(mockSharedPreferences.getString('user_data'))
            .thenReturn(userData);
        when(mockSharedPreferences.getInt('token_expiry'))
            .thenReturn(DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch);

        // Act & Assert
        final isLoggedIn = await authService.isLoggedIn();
        expect(isLoggedIn, true);
      });

      test('should return false when token is expired', () async {
        // Arrange
        const validToken = 'valid_jwt_token_here';
        const userData = '{"id":"123","email":"test@example.com","name":"Test User","createdAt":"2024-01-01T00:00:00.000Z"}';
        
        when(mockSharedPreferences.getString('user_token'))
            .thenReturn(validToken);
        when(mockSharedPreferences.getString('user_data'))
            .thenReturn(userData);
        when(mockSharedPreferences.getInt('token_expiry'))
            .thenReturn(DateTime.now().subtract(Duration(hours: 1)).millisecondsSinceEpoch);
        when(mockSharedPreferences.remove('user_token'))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.remove('user_data'))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.remove('token_expiry'))
            .thenAnswer((_) async => true);

        // Act & Assert
        final isLoggedIn = await authService.isLoggedIn();
        expect(isLoggedIn, false);
      });
    });

    group('User Sign In', () {
      test('should successfully sign in with valid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'securePassword123';
        const storedUsers = '{"user_123":{"email":"test@example.com","password":"securePassword123","name":"Test User","createdAt":"2024-01-01T00:00:00.000Z"}}';
        
        when(mockSharedPreferences.getString('stored_users'))
            .thenReturn(storedUsers);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.setInt(any, any))
            .thenAnswer((_) async => true);

        // Act & Assert
        final result = await authService.signIn(email, password);
        expect(result, true);
      });

      test('should fail sign in with invalid credentials', () async {
        // Arrange
        const email = 'invalid@example.com';
        const password = 'wrongPassword';
        const storedUsers = '{"user_123":{"email":"test@example.com","password":"securePassword123","name":"Test User","createdAt":"2024-01-01T00:00:00.000Z"}}';
        
        when(mockSharedPreferences.getString('stored_users'))
            .thenReturn(storedUsers);

        // Act & Assert
        final result = await authService.signIn(email, password);
        expect(result, false);
      });

      test('should fail sign in with empty email', () async {
        // Arrange
        const email = '';
        const password = 'password123';

        // Act & Assert
        final result = await authService.signIn(email, password);
        expect(result, false);
      });

      test('should fail sign in with invalid email format', () async {
        // Arrange
        const email = 'invalid-email';
        const password = 'password123';

        // Act & Assert
        final result = await authService.signIn(email, password);
        expect(result, false);
      });
    });

    group('User Sign Up', () {
      test('should successfully create new user account', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'securePassword123';
        const name = 'New User';
        const existingUsers = '{}';
        
        when(mockSharedPreferences.getString('stored_users'))
            .thenReturn(existingUsers);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.setInt(any, any))
            .thenAnswer((_) async => true);

        // Act & Assert
        final result = await authService.signUp(email, password, name);
        expect(result, true);
      });

      test('should fail sign up with existing email', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'securePassword123';
        const name = 'Test User';
        const existingUsers = '{"user_123":{"email":"test@example.com","password":"securePassword123","name":"Test User","createdAt":"2024-01-01T00:00:00.000Z"}}';
        
        when(mockSharedPreferences.getString('stored_users'))
            .thenReturn(existingUsers);

        // Act & Assert
        final result = await authService.signUp(email, password, name);
        expect(result, false);
      });

      test('should fail sign up with weak password', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'weak'; // Less than 8 characters
        const name = 'New User';

        // Act & Assert
        final result = await authService.signUp(email, password, name);
        expect(result, false);
      });
    });

    group('User Sign Out', () {
      test('should successfully sign out and clear stored data', () async {
        // Arrange
        when(mockSharedPreferences.remove('user_token'))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.remove('user_data'))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.remove('token_expiry'))
            .thenAnswer((_) async => true);

        // Act & Assert
        await authService.signOut();
        
        verify(mockSharedPreferences.remove('user_token')).called(1);
        verify(mockSharedPreferences.remove('user_data')).called(1);
        verify(mockSharedPreferences.remove('token_expiry')).called(1);
      });

      test('should handle sign out errors gracefully', () async {
        // Arrange
        when(mockSharedPreferences.remove('user_token'))
            .thenThrow(Exception('Storage error'));
        when(mockSharedPreferences.remove('user_data'))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.remove('token_expiry'))
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(() async => await authService.signOut(), throwsException);
      });
    });

    group('Current User Management', () {
      test('should return current user when logged in', () async {
        // Arrange
        const validToken = 'valid_jwt_token_here';
        const userData = '{"id":"123","email":"test@example.com","name":"Test User","createdAt":"2024-01-01T00:00:00.000Z"}';
        
        when(mockSharedPreferences.getString('user_token'))
            .thenReturn(validToken);
        when(mockSharedPreferences.getString('user_data'))
            .thenReturn(userData);
        when(mockSharedPreferences.getInt('token_expiry'))
            .thenReturn(DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch);

        // Act & Assert
        final user = await authService.getCurrentUser();
        expect(user, isNotNull);
        expect(user!.email, 'test@example.com');
        expect(user.name, 'Test User');
      });

      test('should return null when no user is logged in', () async {
        // Arrange
        when(mockSharedPreferences.getString('user_token'))
            .thenReturn(null);
        when(mockSharedPreferences.getString('user_data'))
            .thenReturn(null);

        // Act & Assert
        final user = await authService.getCurrentUser();
        expect(user, isNull);
      });

      test('should return null when token is expired', () async {
        // Arrange
        const validToken = 'valid_jwt_token_here';
        const userData = '{"id":"123","email":"test@example.com","name":"Test User","createdAt":"2024-01-01T00:00:00.000Z"}';
        
        when(mockSharedPreferences.getString('user_token'))
            .thenReturn(validToken);
        when(mockSharedPreferences.getString('user_data'))
            .thenReturn(userData);
        when(mockSharedPreferences.getInt('token_expiry'))
            .thenReturn(DateTime.now().subtract(Duration(hours: 1)).millisecondsSinceEpoch);
        when(mockSharedPreferences.remove(any))
            .thenAnswer((_) async => true);

        // Act & Assert
        final user = await authService.getCurrentUser();
        expect(user, isNull);
      });
    });

    group('Password Reset', () {
      test('should successfully initiate password reset', () async {
        // Arrange
        const email = 'test@example.com';
        const existingUsers = '{"user_123":{"email":"test@example.com","password":"securePassword123","name":"Test User","createdAt":"2024-01-01T00:00:00.000Z"}}';
        
        when(mockSharedPreferences.getString('stored_users'))
            .thenReturn(existingUsers);

        // Act & Assert
        final result = await authService.resetPassword(email);
        expect(result, true);
      });

      test('should fail password reset with invalid email', () async {
        // Arrange
        const email = 'nonexistent@example.com';
        const existingUsers = '{"user_123":{"email":"test@example.com","password":"securePassword123","name":"Test User","createdAt":"2024-01-01T00:00:00.000Z"}}';
        
        when(mockSharedPreferences.getString('stored_users'))
            .thenReturn(existingUsers);

        // Act & Assert
        final result = await authService.resetPassword(email);
        expect(result, false);
      });
    });

    group('Token Management', () {
      test('should refresh token when close to expiry', () async {
        // Arrange
        final closeToExpiry = DateTime.now().add(Duration(minutes: 3));
        
        when(mockSharedPreferences.getInt('token_expiry'))
            .thenReturn(closeToExpiry.millisecondsSinceEpoch);
        when(mockSharedPreferences.setInt('token_expiry', any))
            .thenAnswer((_) async => true);

        // Act & Assert
        final result = await authService.refreshTokenIfNeeded();
        expect(result, true);
        verify(mockSharedPreferences.setInt('token_expiry', any)).called(1);
      });

      test('should not refresh token when still valid', () async {
        // Arrange
        final validForLong = DateTime.now().add(Duration(hours: 1));
        
        when(mockSharedPreferences.getInt('token_expiry'))
            .thenReturn(validForLong.millisecondsSinceEpoch);

        // Act & Assert
        final result = await authService.refreshTokenIfNeeded();
        expect(result, false);
        verifyNever(mockSharedPreferences.setInt('token_expiry', any));
      });
    });

    group('Data Validation', () {
      test('should validate email format correctly', () {
        // Act & Assert
        expect(authService.isValidEmail('test@example.com'), true);
        expect(authService.isValidEmail('invalid-email'), false);
        expect(authService.isValidEmail(''), false);
        expect(authService.isValidEmail('test@'), false);
        expect(authService.isValidEmail('@example.com'), false);
      });

      test('should validate password strength correctly', () {
        // Act & Assert
        expect(authService.isValidPassword('password123'), true);
        expect(authService.isValidPassword('weak'), false);
        expect(authService.isValidPassword(''), false);
        expect(authService.isValidPassword('1234567'), false);
        expect(authService.isValidPassword('strongPassword!@#'), true);
      });
    });

    group('Error Handling', () {
      test('should handle storage exceptions gracefully', () async {
        // Arrange
        when(mockSharedPreferences.getString('stored_users'))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        final result = await authService.signIn('test@example.com', 'password123');
        expect(result, false);
      });

      test('should handle corrupted user data gracefully', () async {
        // Arrange
        when(mockSharedPreferences.getString('user_token'))
            .thenReturn('valid_token');
        when(mockSharedPreferences.getString('user_data'))
            .thenReturn('invalid_json_data');
        when(mockSharedPreferences.getInt('token_expiry'))
            .thenReturn(DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch);

        // Act & Assert
        final user = await authService.getCurrentUser();
        expect(user, isNull);
      });
    });
  });
}
