import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edubridge/services/course_service.dart';
import 'package:edubridge/services/question_service.dart';
import 'package:edubridge/services/assignment_service.dart';
import 'package:edubridge/services/notification_service.dart';
import 'package:provider/provider.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userType;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _token;
  bool _useLocalAuth = false; // Set to false to use the backend API instead of local authentication

  // Base URL for API requests
  final String _baseUrl = 'http://localhost:5000'; // Use localhost for direct connections

  // Predefined users for local authentication
  final Map<String, Map<String, dynamic>> _predefinedUsers = {
    'admin@edubridge.com': {
      'password': 'password123',
      'name': 'Admin User',
      'role': 'admin',
      'id': 'admin-123',
    },
    'teacher@edubridge.com': {
      'password': 'password123',
      'name': 'Teacher User',
      'role': 'teacher',
      'id': 'teacher-123',
    },
    'student@edubridge.com': {
      'password': 'password123',
      'name': 'Student User',
      'role': 'student',
      'id': 'student-123',
    },
  };

  bool get isAuthenticated => _isAuthenticated;
  String? get userType => _userType;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get token => _token;

  // Login method that first tries API then falls back to local auth
  Future<bool> signIn(String email, String password, [String? userTypeParam, BuildContext? context]) async {
    // First try with API if not using local auth
    if (!_useLocalAuth) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          await _saveUserAndToken(data['user'], data['token'], context);
          return true;
        } else {
          final error = jsonDecode(response.body);
          print('Login error: ${error['msg']}');
          return false;
        }
      } catch (e) {
        print('API error: $e');
        // Fall back to local authentication if the API is unavailable
      }
    }

    // Use local authentication with predefined users
    if (_predefinedUsers.containsKey(email) && _predefinedUsers[email]!['password'] == password) {
      final user = _predefinedUsers[email]!;

      _isAuthenticated = true;
      _userId = user['id'];
      _userName = user['name'];
      _userEmail = email;
      _userType = user['role'];
      _token = 'local-auth-token';

      // Save auth data to local storage
      await _saveAuthData();

      notifyListeners();
      return true;
    }

    return false;
  }

  // Registration method that handles both API and local auth
  Future<bool> register(String email, String password, String name, String userType) async {
    // Try API registration if not using local auth
    if (!_useLocalAuth) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'role': userType,
          }),
        );

        if (response.statusCode == 201) {
          // After registration, automatically log in
          return await signIn(email, password);
        }
      } catch (e) {
        print('API registration error: $e - Falling back to local registration');
        // Fall back to local registration
      }
    }

    // For local registration
    if (_predefinedUsers.containsKey(email)) {
      // Email already exists
      return false;
    }

    // Add new user to predefined users
    _predefinedUsers[email] = {
      'password': password,
      'name': name,
      'role': userType,
      'id': 'user-${DateTime.now().millisecondsSinceEpoch}',
    };

    return await signIn(email, password);
  }

  // Méthode de réinitialisation de mot de passe simplifiée
  Future<bool> resetPassword(String email) async {
    // Simulation d'un délai de réinitialisation
    await Future.delayed(const Duration(seconds: 1));

    // Toujours retourner true pour simuler une réussite
    return true;
  }

  // Sign out method
  Future<void> signOut() async {
    // Clear authentication data
    _isAuthenticated = false;
    _userType = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _token = null;

    // Clear from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  // Save authentication data to SharedPreferences
  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token ?? '');
    await prefs.setString('userId', _userId ?? '');
    await prefs.setString('userName', _userName ?? '');
    await prefs.setString('userEmail', _userEmail ?? '');
    await prefs.setString('userType', _userType ?? '');
    await prefs.setBool('isAuthenticated', _isAuthenticated);
  }

  // Save user and token and initialize all services
  Future<void> _saveUserAndToken(dynamic user, String token, [BuildContext? context]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
    await prefs.setString('token', token);
    _isAuthenticated = true;
    _userId = user['_id'];
    _userName = user['name'];
    _userEmail = user['email'];
    _userType = user['role'];
    _token = token;

    // Set token for all other services if context is available
    if (context != null) {
      try {
        // Set token for CourseService
        Provider.of<CourseService>(context, listen: false).setUserData(token);

        // Set token for QuestionService
        Provider.of<QuestionService>(context, listen: false).setUserData(token);

        // Set token for AssignmentService
        Provider.of<AssignmentService>(context, listen: false).setAuthToken(token);

        // Set token for NotificationService
        Provider.of<NotificationService>(context, listen: false).setAuthToken(token);
      } catch (e) {
        print('Error setting tokens for services: $e');
      }
    }

    notifyListeners();
  }

  // Load authentication data from SharedPreferences
  Future<bool> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    _userType = prefs.getString('userType');
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    // If using local auth or local token, just return the auth state
    if (_useLocalAuth || _token == 'local-auth-token') {
      notifyListeners();
      return _isAuthenticated;
    }
    
    // If we're supposed to verify with API
    if (_isAuthenticated && _token != null) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/users/me'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _token!,
          },
        );

        if (response.statusCode != 200) {
          // If token is invalid, clear auth data
          await signOut();
          return false;
        }
      } catch (e) {
        print('Error verifying token: $e - continuing with stored auth');
        // Continue with stored auth data even if verification fails
      }
    }

    notifyListeners();
    return _isAuthenticated;
  }
}
