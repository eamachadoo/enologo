import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Authentication service that handles user authentication using local storage
/// This is a local implementation for MVP, will be replaced with Firebase later
class AuthService {
  final SharedPreferences sharedPreferences;
  
  // Storage keys
  static const String _userTokenKey = 'user_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _usersStorageKey = 'stored_users'; // For local user registry
  
  AuthService({required this.sharedPreferences});
  
  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = sharedPreferences.getString(_userTokenKey);
      final userData = sharedPreferences.getString(_userDataKey);
      final expiry = sharedPreferences.getInt(_tokenExpiryKey);
      
      if (token == null || userData == null || expiry == null) {
        return false;
      }
      
      // Check if token is expired
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry);
      if (DateTime.now().isAfter(expiryDate)) {
        await _clearAuthData();
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      // Validate input
      if (!isValidEmail(email) || email.isEmpty) {
        return false;
      }
      
      if (password.isEmpty) {
        return false;
      }
      
      // Get stored users
      final storedUsers = await _getStoredUsers();
      
      // Find user by email
      final userEntry = storedUsers.entries.firstWhere(
        (entry) => entry.value['email'] == email,
        orElse: () => MapEntry('', {}),
      );
      
      if (userEntry.key.isEmpty) {
        return false; // User not found
      }
      
      // Check password (in real app, this would be hashed)
      if (userEntry.value['password'] != password) {
        return false; // Invalid password
      }
      
      // Create user object and store auth data
      final user = User(
        id: userEntry.key,
        email: userEntry.value['email'],
        name: userEntry.value['name'],
        createdAt: DateTime.parse(userEntry.value['createdAt']),
        lastLoginAt: DateTime.now(),
      );
      
      await _storeAuthData(user);
      return true;
      
    } catch (e) {
      return false;
    }
  }
  
  /// Sign up new user
  Future<bool> signUp(String email, String password, String name) async {
    try {
      // Validate input
      if (!isValidEmail(email)) {
        return false;
      }
      
      if (!isValidPassword(password)) {
        return false;
      }
      
      if (name.trim().isEmpty) {
        return false;
      }
      
      // Check if user already exists
      final storedUsers = await _getStoredUsers();
      final userExists = storedUsers.values.any((user) => user['email'] == email);
      
      if (userExists) {
        return false; // User already exists
      }
      
      // Create new user
      final userId = _generateUserId();
      final now = DateTime.now();
      
      final user = User(
        id: userId,
        email: email,
        name: name.trim(),
        createdAt: now,
        lastLoginAt: now,
      );
      
      // Store user in local registry
      storedUsers[userId] = {
        'email': email,
        'password': password, // In real app, this would be hashed
        'name': name.trim(),
        'createdAt': now.toIso8601String(),
      };
      
      await sharedPreferences.setString(_usersStorageKey, jsonEncode(storedUsers));
      
      // Store auth data
      await _storeAuthData(user);
      return true;
      
    } catch (e) {
      return false;
    }
  }
  
  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _clearAuthData();
    } catch (e) {
      // Handle gracefully - even if clearing fails, user should be signed out
      rethrow;
    }
  }
  
  /// Get current authenticated user
  Future<User?> getCurrentUser() async {
    try {
      if (!await isLoggedIn()) {
        return null;
      }
      
      final userData = sharedPreferences.getString(_userDataKey);
      if (userData == null) {
        return null;
      }
      
      final userJson = jsonDecode(userData) as Map<String, dynamic>;
      return User.fromJson(userJson);
      
    } catch (e) {
      return null;
    }
  }
  
  /// Reset password for given email
  Future<bool> resetPassword(String email) async {
    try {
      if (!isValidEmail(email)) {
        return false;
      }
      
      // Check if user exists
      final storedUsers = await _getStoredUsers();
      final userExists = storedUsers.values.any((user) => user['email'] == email);
      
      if (!userExists) {
        return false; // User not found
      }
      
      // In a real app, this would send an email
      // For local implementation, we'll just return true
      return true;
      
    } catch (e) {
      return false;
    }
  }
  
  /// Refresh token if needed
  Future<bool> refreshTokenIfNeeded() async {
    try {
      final expiry = sharedPreferences.getInt(_tokenExpiryKey);
      if (expiry == null) {
        return false;
      }
      
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry);
      final now = DateTime.now();
      
      // Refresh if token expires within next 5 minutes
      if (expiryDate.difference(now).inMinutes <= 5) {
        // Generate new token expiry
        final newExpiry = now.add(Duration(hours: 24));
        await sharedPreferences.setInt(_tokenExpiryKey, newExpiry.millisecondsSinceEpoch);
        return true;
      }
      
      return false; // No refresh needed
      
    } catch (e) {
      return false;
    }
  }
  
  /// Validate email format
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    return emailRegex.hasMatch(email);
  }
  
  /// Validate password strength
  bool isValidPassword(String password) {
    // Password must be at least 8 characters
    return password.length >= 8;
  }
  
  /// Store authentication data
  Future<void> _storeAuthData(User user) async {
    final token = _generateToken();
    final expiry = DateTime.now().add(Duration(hours: 24));
    
    await sharedPreferences.setString(_userTokenKey, token);
    await sharedPreferences.setString(_userDataKey, jsonEncode(user.toJson()));
    await sharedPreferences.setInt(_tokenExpiryKey, expiry.millisecondsSinceEpoch);
  }
  
  /// Clear authentication data
  Future<void> _clearAuthData() async {
    await sharedPreferences.remove(_userTokenKey);
    await sharedPreferences.remove(_userDataKey);
    await sharedPreferences.remove(_tokenExpiryKey);
  }
  
  /// Get stored users from local storage
  Future<Map<String, Map<String, dynamic>>> _getStoredUsers() async {
    try {
      final usersData = sharedPreferences.getString(_usersStorageKey);
      if (usersData == null) {
        return {};
      }
      
      final usersJson = jsonDecode(usersData) as Map<String, dynamic>;
      return usersJson.map((key, value) => MapEntry(key, value as Map<String, dynamic>));
      
    } catch (e) {
      return {};
    }
  }
  
  /// Generate a simple user ID
  String _generateUserId() {
    final random = Random();
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}';
  }
  
  /// Generate a simple token (in real app, this would be a proper JWT)
  String _generateToken() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(32, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
