import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubridge/models/course.dart';
import 'package:edubridge/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService;
  
  // File d'attente pour les opérations hors ligne
  final List<Map<String, dynamic>> _pendingOperations = [];
  
  // Cache pour les données
  final Map<String, dynamic> _cache = {};
  
  // Statut de synchronisation
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  
  DatabaseService(this._connectivityService) {
    _init();
  }
  
  Future<void> _init() async {
    // Charger les opérations en attente depuis le stockage local
    await _loadPendingOperations();
    
    // Écouter les changements de connectivité
    _connectivityService.connectionStatusController.stream.listen((status) {
      if (status == ConnectivityStatus.online) {
        _syncPendingOperations();
      }
    });
  }
  
  // Méthodes pour les cours
  
  Future<List<Course>> getCourses() async {
    try {
      // Vérifier si nous sommes en ligne
      final isOnline = await _connectivityService.isOnline();
      
      if (isOnline) {
        // Récupérer les données depuis Firestore
        final snapshot = await _firestore.collection('courses').get();
        final courses = snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
        
        // Mettre en cache les données
        await _cacheData('courses', courses.map((c) => c.toJson()).toList());
        
        return courses;
      } else {
        // Récupérer les données depuis le cache
        final cachedData = await _getCachedData('courses');
        if (cachedData != null) {
          return (cachedData as List).map((json) => Course.fromJson(json)).toList();
        }
        return [];
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des cours: $e');
      
      // Fallback: essayer de récupérer depuis le cache
      final cachedData = await _getCachedData('courses');
      if (cachedData != null) {
        return (cachedData as List).map((json) => Course.fromJson(json)).toList();
      }
      return [];
    }
  }
  
  Future<Course?> getCourse(String courseId) async {
    try {
      // Vérifier si nous sommes en ligne
      final isOnline = await _connectivityService.isOnline();
      
      if (isOnline) {
        // Récupérer les données depuis Firestore
        final doc = await _firestore.collection('courses').doc(courseId).get();
        if (!doc.exists) return null;
        
        final course = Course.fromFirestore(doc);
        
        // Mettre en cache les données
        await _cacheData('course_$courseId', course.toJson());
        
        return course;
      } else {
        // Récupérer les données depuis le cache
        final cachedData = await _getCachedData('course_$courseId');
        if (cachedData != null) {
          return Course.fromJson(cachedData);
        }
        return null;
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération du cours: $e');
      
      // Fallback: essayer de récupérer depuis le cache
      final cachedData = await _getCachedData('course_$courseId');
      if (cachedData != null) {
        return Course.fromJson(cachedData);
      }
      return null;
    }
  }
  
  // Méthodes pour la gestion du cache et des opérations hors ligne
  
  Future<void> _cacheData(String key, dynamic data) async {
    _cache[key] = data;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cache_$key', jsonEncode(data));
    } catch (e) {
      debugPrint('Erreur lors de la mise en cache des données: $e');
    }
  }
  
  Future<dynamic> _getCachedData(String key) async {
    if (_cache.containsKey(key)) {
      return _cache[key];
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cache_$key');
      if (cachedData != null) {
        final data = jsonDecode(cachedData);
        _cache[key] = data;
        return data;
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des données en cache: $e');
    }
    
    return null;
  }
  
  Future<void> _addPendingOperation(String operation, String collection, String? documentId, Map<String, dynamic> data) async {
    _pendingOperations.add({
      'operation': operation,
      'collection': collection,
      'documentId': documentId,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    await _savePendingOperations();
  }
  
  Future<void> _loadPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingOpsJson = prefs.getString('pending_operations');
      if (pendingOpsJson != null) {
        final List<dynamic> pendingOps = jsonDecode(pendingOpsJson);
        _pendingOperations.clear();
        _pendingOperations.addAll(pendingOps.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des opérations en attente: $e');
    }
  }
  
  Future<void> _savePendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_operations', jsonEncode(_pendingOperations));
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des opérations en attente: $e');
    }
  }
  
  Future<void> _syncPendingOperations() async {
    if (_isSyncing || _pendingOperations.isEmpty) return;
    
    _isSyncing = true;
    notifyListeners();
    
    try {
      // Trier les opérations par timestamp
      _pendingOperations.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      
      // Copier la liste pour éviter les modifications pendant l'itération
      final operations = List<Map<String, dynamic>>.from(_pendingOperations);
      
      for (var operation in operations) {
        try {
          final type = operation['operation'];
          final collection = operation['collection'];
          final documentId = operation['documentId'];
          final data = operation['data'];
          
          if (type == 'add') {
            await _firestore.collection(collection).add(data);
          } else if (type == 'update' && documentId != null) {
            await _firestore.collection(collection).doc(documentId).update(data);
          } else if (type == 'delete' && documentId != null) {
            await _firestore.collection(collection).doc(documentId).delete();
          }
          
          // Supprimer l'opération de la liste
          _pendingOperations.remove(operation);
        } catch (e) {
          debugPrint('Erreur lors de la synchronisation de l\'opération: $e');
          // Continuer avec les autres opérations
        }
      }
      
      // Sauvegarder les opérations restantes
      await _savePendingOperations();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}

