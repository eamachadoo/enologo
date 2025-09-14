import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLogin = true;
  bool _isLoading = false;
  String _message = '';
  
  late AuthService _authService;
  
  @override
  void initState() {
    super.initState();
    _initAuthService();
  }
  
  Future<void> _initAuthService() async {
    final prefs = await SharedPreferences.getInstance();
    _authService = AuthService(sharedPreferences: prefs);
  }
  
  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _message = '';
    });
    
    try {
      bool success;
      
      if (_isLogin) {
        success = await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (success) {
          final user = await _authService.getCurrentUser();
          setState(() {
            _message = 'Welcome back, ${user?.name ?? 'User'}!';
          });
        } else {
          setState(() {
            _message = 'Invalid email or password';
          });
        }
      } else {
        success = await _authService.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
        
        if (success) {
          setState(() {
            _message = 'Account created successfully!';
            _isLogin = true; // Switch to login view
          });
          _clearFields();
        } else {
          setState(() {
            _message = 'Failed to create account. Email might already exist.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _message = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _handleSignOut() async {
    await _authService.signOut();
    setState(() {
      _message = 'Signed out successfully';
    });
    _clearFields();
  }
  
  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    final user = await _authService.getCurrentUser();
    
    setState(() {
      if (isLoggedIn && user != null) {
        _message = 'Currently logged in as: ${user.name} (${user.email})';
      } else {
        _message = 'Not logged in';
      }
    });
  }
  
  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Sign In' : 'Sign Up'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Auth Status Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Authentication Test Panel',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _checkAuthStatus,
                        child: const Text('Check Auth Status'),
                      ),
                      if (_message.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          _message,
                          style: TextStyle(
                            color: _message.contains('error') || _message.contains('Invalid') || _message.contains('Failed')
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Toggle Login/Signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _isLogin = true),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal,
                        color: _isLogin ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                  ),
                  const Text(' | '),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = false),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal,
                        color: !_isLogin ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Form Fields
              if (!_isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (!_isLogin && (value == null || value.trim().isEmpty)) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!_authService.isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (!_authService.isValidPassword(value)) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAuth,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_isLogin ? 'Sign In' : 'Sign Up'),
              ),
              
              const SizedBox(height: 16),
              
              OutlinedButton(
                onPressed: _handleSignOut,
                child: const Text('Sign Out'),
              ),
              
              const SizedBox(height: 20),
              
              // Test Instructions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '🧪 Test Instructions:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('1. Create an account with Sign Up'),
                      Text('2. Try signing in with those credentials'),
                      Text('3. Check auth status to see current user'),
                      Text('4. Test invalid emails/passwords'),
                      Text('5. Use Sign Out to clear session'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
