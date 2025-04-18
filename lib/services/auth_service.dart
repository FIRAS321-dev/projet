import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { student, teacher, admin }

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  UserRole? _userRole;
  bool _isLoading = false;
  String? _error;
  String? _userName;
  String? _userEmail;

  User? get user => _user;
  UserRole? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  String get userName => _userName ?? 'Utilisateur';
  String get userEmail => _userEmail ?? 'utilisateur@edubridge.com';

  AuthService() {
    _initUser();
  }

  Future<void> _initUser() async {
    _user = _auth.currentUser;
    if (_user != null) {
      await _loadUserRole();
      _userName = _user!.displayName ?? 'Utilisateur';
      _userEmail = _user!.email;
    }
    notifyListeners();
  }

  Future<void> _loadUserRole() async {
    if (_user == null) return;
    
    try {
      final docSnapshot = await _firestore.collection('users').doc(_user!.uid).get();
      if (docSnapshot.exists) {
        final roleStr = docSnapshot.data()?['role'] as String?;
        if (roleStr == 'student') {
          _userRole = UserRole.student;
        } else if (roleStr == 'teacher') {
          _userRole = UserRole.teacher;
        } else if (roleStr == 'admin') {
          _userRole = UserRole.admin;
        }
        
        _userName = docSnapshot.data()?['name'] as String?;
      }
      
      // Sauvegarder le rôle dans les préférences pour utilisation hors ligne
      final prefs = await SharedPreferences.getInstance();
      if (_userRole != null) {
        prefs.setString('userRole', _userRole.toString().split('.').last);
      }
      if (_userName != null) {
        prefs.setString('userName', _userName!);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du rôle utilisateur: $e');
      
      // Fallback: essayer de charger depuis les préférences locales
      final prefs = await SharedPreferences.getInstance();
      final roleStr = prefs.getString('userRole');
      if (roleStr == 'student') {
        _userRole = UserRole.student;
      } else if (roleStr == 'teacher') {
        _userRole = UserRole.teacher;
      } else if (roleStr == 'admin') {
        _userRole = UserRole.admin;
      }
      
      _userName = prefs.getString('userName') ?? 'Utilisateur';
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = userCredential.user;
      await _loadUserRole();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  Future<bool> register({
    required String email, 
    required String password, 
    required String name,
    required UserRole role,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = userCredential.user;
      
      // Mettre à jour le profil utilisateur
      await _user?.updateDisplayName(name);
      
      // Sauvegarder les données supplémentaires dans Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'name': name,
        'email': email,
        'role': role.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      _userRole = role;
      _userName = name;
      _userEmail = email;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _auth.signOut();
      _user = null;
      _userRole = null;
      _userName = null;
      _userEmail = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userRole');
      await prefs.remove('userName');
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }
    
    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleAuthError(dynamic error) {
    debugPrint('Erreur d\'authentification: $error');
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          _error = 'Aucun utilisateur trouvé avec cet email.';
          break;
        case 'wrong-password':
          _error = 'Mot de passe incorrect.';
          break;
        case 'email-already-in-use':
          _error = 'Cet email est déjà utilisé par un autre compte.';
          break;
        case 'weak-password':
          _error = 'Ce mot de passe est trop faible.';
          break;
        case 'invalid-email':
          _error = 'Email invalide.';
          break;
        case 'network-request-failed':
          _error = 'Problème de connexion réseau.';
          break;
        default:
          _error = 'Une erreur est survenue: ${error.message}';
      }
    } else {
      _error = 'Une erreur est survenue: $error';
    }
    
    _setLoading(false);
  }
}

