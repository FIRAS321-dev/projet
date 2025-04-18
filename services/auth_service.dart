import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userName;
  String? _userEmail;
  String? _userRole;

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;

  Future<bool> signIn(String email, String password) async {
    // Simuler une authentification
    await Future.delayed(const Duration(seconds: 2));
    
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userEmail = email;
      
      // Déterminer le nom d'utilisateur à partir de l'email
      _userName = email.split('@').first;
      
      // Déterminer le rôle en fonction de l'email
      if (email.contains('prof') || email.contains('teacher')) {
        _userRole = 'teacher';
      } else if (email.contains('admin')) {
        _userRole = 'admin';
      } else {
        _userRole = 'student';
      }
      
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<bool> register(String name, String email, String password, String role) async {
    // Simuler un enregistrement
    await Future.delayed(const Duration(seconds: 2));
    
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userName = name;
      _userEmail = email;
      _userRole = role;
      
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<void> signOut() async {
    // Simuler une déconnexion
    await Future.delayed(const Duration(seconds: 1));
    
    _isAuthenticated = false;
    _userName = null;
    _userEmail = null;
    _userRole = null;
    
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    // Simuler une réinitialisation de mot de passe
    await Future.delayed(const Duration(seconds: 2));
    
    return email.isNotEmpty;
  }
}

