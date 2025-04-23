import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? courseId;
  final String type; // 'assignment', 'course', 'general', etc.

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.courseId,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'courseId': courseId,
      'type': type,
    };
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      courseId: json['courseId'],
      type: json['type'] ?? 'general',
    );
  }
}

class NotificationService extends ChangeNotifier {
  List<Notification> _notifications = [];
  bool _useLocalData = true; // Set to false when backend is available
  String? _authToken;
  final String _baseUrl = 'http://localhost:5000';

  List<Notification> get allNotifications => _notifications;
  
  List<Notification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  // Set auth token for API requests
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Initialize service
  NotificationService() {
    _loadNotifications();
  }

  // Load notifications from storage or API
  Future<void> _loadNotifications() async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/notifications'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          _notifications = data.map((json) => Notification.fromJson(json)).toList();
          _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by most recent
          
          // Cache notifications locally
          await _cacheNotifications();
          notifyListeners();
          return;
        }
      } catch (e) {
        print('Error loading notifications from API: $e');
      }
    }

    // Load from cache or use sample data if API fails
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications');
      
      if (notificationsJson != null) {
        final List<dynamic> data = jsonDecode(notificationsJson);
        _notifications = data.map((json) => Notification.fromJson(json)).toList();
      } else {
        // Sample data
        _notifications = [
          Notification(
            id: '1',
            title: 'Nouveau devoir',
            message: 'Un nouveau devoir a été ajouté au cours Algèbre linéaire',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            type: 'assignment',
            courseId: '1',
          ),
          Notification(
            id: '2',
            title: 'Date limite approchant',
            message: 'Le devoir pour le cours Programmation Python est dû dans 2 jours',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            type: 'deadline',
            courseId: '2',
          ),
          Notification(
            id: '3',
            title: 'Nouveau cours disponible',
            message: 'Un nouveau cours a été ajouté: Introduction à l\'Intelligence Artificielle',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            type: 'course',
          ),
        ];
      }
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by most recent
      notifyListeners();
    } catch (e) {
      print('Error loading notifications from cache: $e');
    }
  }

  // Cache notifications in local storage
  Future<void> _cacheNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(_notifications.map((n) => n.toJson()).toList());
      await prefs.setString('notifications', notificationsJson);
    } catch (e) {
      print('Error caching notifications: $e');
    }
  }

  // Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.put(
          Uri.parse('$_baseUrl/notifications/$notificationId/read'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
        );

        if (response.statusCode == 200) {
          await _loadNotifications();
          return true;
        }
        return false;
      } catch (e) {
        print('Error marking notification as read: $e');
        return false;
      }
    }

    // Local implementation
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications[index] = Notification(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        isRead: true,
        courseId: notification.courseId,
        type: notification.type,
      );
      await _cacheNotifications();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.put(
          Uri.parse('$_baseUrl/notifications/read-all'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
        );

        if (response.statusCode == 200) {
          await _loadNotifications();
          return true;
        }
        return false;
      } catch (e) {
        print('Error marking all notifications as read: $e');
        return false;
      }
    }

    // Local implementation
    _notifications = _notifications.map((notification) => Notification(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      timestamp: notification.timestamp,
      isRead: true,
      courseId: notification.courseId,
      type: notification.type,
    )).toList();
    await _cacheNotifications();
    notifyListeners();
    return true;
  }

  // Add a new notification (for testing or local functionality)
  Future<void> addNotification(Notification notification) async {
    _notifications.insert(0, notification);
    await _cacheNotifications();
    notifyListeners();
  }
}
