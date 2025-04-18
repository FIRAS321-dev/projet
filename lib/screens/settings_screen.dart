import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userType;
  String? _userId;
  String? _userName;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get userType => _userType;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  Future<void> signIn(String email, String password) async {
    // In a real app, this would call Firebase Auth or your backend
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful login
    _isAuthenticated = true;
    _userType = email.contains('teacher') ? 'teacher' : 'student';
    _userId = '123';
    _userName = 'John Doe';
    _userEmail = email;

    notifyListeners();
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String userType,
  ) async {
    // In a real app, this would call Firebase Auth or your backend
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful registration
    _isAuthenticated = true;
    _userType = userType;
    _userId = '123';
    _userName = name;
    _userEmail = email;

    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    // In a real app, this would call Firebase Auth or your backend
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful password reset
    // No state changes needed
  }

  Future<void> signOut() async {
    // In a real app, this would call Firebase Auth or your backend
    await Future.delayed(const Duration(seconds: 1));

    // Reset all user data
    _isAuthenticated = false;
    _userType = null;
    _userId = null;
    _userName = null;
    _userEmail = null;

    notifyListeners();
  }
}
