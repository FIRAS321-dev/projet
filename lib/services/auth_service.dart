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

  // Méthode de connexion simplifiée
  Future<bool> signIn(String email, String password,
      [String? userTypeParam]) async {
    // Simulation d'un délai de connexion
    await Future.delayed(const Duration(seconds: 1));

    // Vérification simplifiée des identifiants
    if (email.isNotEmpty && password.length >= 6) {
      _isAuthenticated = true;

      // Déterminer le type d'utilisateur
      if (email.contains('admin')) {
        _userType = 'admin';
      } else if (userTypeParam == 'teacher' || email.contains('teacher')) {
        _userType = 'teacher';
      } else {
        _userType = 'student';
      }

      _userId = '123';
      _userName = email.split('@')[0];
      _userEmail = email;

      notifyListeners();
      return true;
    }

    return false;
  }

  // Méthode d'inscription simplifiée
  Future<bool> register(
      String email, String password, String name, String userType) async {
    // Simulation d'un délai d'inscription
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6 && name.isNotEmpty) {
      _isAuthenticated = true;
      _userType = userType;
      _userId = '123';
      _userName = name;
      _userEmail = email;

      notifyListeners();
      return true;
    }

    return false;
  }

  // Méthode de réinitialisation de mot de passe simplifiée
  Future<bool> resetPassword(String email) async {
    // Simulation d'un délai de réinitialisation
    await Future.delayed(const Duration(seconds: 1));

    // Toujours retourner true pour simuler une réussite
    return true;
  }

  // Méthode de déconnexion
  Future<void> signOut() async {
    // Simulation d'un délai de déconnexion
    await Future.delayed(const Duration(seconds: 1));

    // Réinitialisation des données utilisateur
    _isAuthenticated = false;
    _userType = null;
    _userId = null;
    _userName = null;
    _userEmail = null;

    notifyListeners();
  }
}
