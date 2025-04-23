import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String courseTitle;
  final DateTime dueDate;
  final int points;
  final bool isSubmitted;
  final int? grade;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.courseTitle,
    required this.dueDate,
    required this.points,
    this.isSubmitted = false,
    this.grade,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'dueDate': dueDate.toIso8601String(),
      'points': points,
      'isSubmitted': isSubmitted,
      'grade': grade,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      courseId: json['courseId'] ?? json['course'] ?? '',
      courseTitle: json['courseTitle'] ?? '',
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : DateTime.now().add(const Duration(days: 7)),
      points: json['points'] ?? 100,
      isSubmitted: json['isSubmitted'] ?? false,
      grade: json['grade'],
    );
  }
}

class AssignmentService extends ChangeNotifier {
  List<Assignment> _assignments = [];
  bool _useLocalData = true; // Set to false when backend is available
  String? _authToken;
  final String _baseUrl = 'http://localhost:5000';

  List<Assignment> get allAssignments => _assignments;

  // Set auth token for API requests
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Initialize service
  AssignmentService() {
    _loadAssignments();
  }

  // Get assignments for a specific course
  List<Assignment> getAssignmentsByCourse(String courseId) {
    return _assignments.where((a) => a.courseId == courseId).toList();
  }

  // Get upcoming assignments
  List<Assignment> get upcomingAssignments {
    final now = DateTime.now();
    return _assignments
        .where((a) => a.dueDate.isAfter(now) && !a.isSubmitted)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get past due assignments
  List<Assignment> get pastDueAssignments {
    final now = DateTime.now();
    return _assignments
        .where((a) => a.dueDate.isBefore(now) && !a.isSubmitted)
        .toList();
  }

  // Load assignments from API or local storage
  Future<void> _loadAssignments() async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/assignments'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          _assignments = data.map((json) => Assignment.fromJson(json)).toList();
          
          // Cache assignments locally
          await _cacheAssignments();
          notifyListeners();
          return;
        }
      } catch (e) {
        print('Error loading assignments from API: $e');
      }
    }

    // Load from cache or use sample data if API fails
    try {
      final prefs = await SharedPreferences.getInstance();
      final assignmentsJson = prefs.getString('assignments');
      
      if (assignmentsJson != null) {
        final List<dynamic> data = jsonDecode(assignmentsJson);
        _assignments = data.map((json) => Assignment.fromJson(json)).toList();
      } else {
        // Sample data
        _assignments = [
          Assignment(
            id: '1',
            title: 'Introduction à l\'algèbre linéaire',
            description: 'Résoudre les exercices 1-5 du chapitre 2',
            courseId: '1',
            courseTitle: 'Algèbre linéaire',
            dueDate: DateTime.now().add(const Duration(days: 3)),
            points: 20,
          ),
          Assignment(
            id: '2',
            title: 'Projet de programmation Python',
            description: 'Créer une application simple de gestion de tâches',
            courseId: '2',
            courseTitle: 'Programmation Python',
            dueDate: DateTime.now().add(const Duration(days: 7)),
            points: 50,
          ),
          Assignment(
            id: '3',
            title: 'Expérience de laboratoire',
            description: 'Rédiger un rapport sur l\'expérience de la semaine dernière',
            courseId: '3',
            courseTitle: 'Mécanique quantique',
            dueDate: DateTime.now().add(const Duration(days: 1)),
            points: 30,
          ),
        ];
      }
      notifyListeners();
    } catch (e) {
      print('Error loading assignments from cache: $e');
    }
  }

  // Cache assignments in local storage
  Future<void> _cacheAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assignmentsJson = jsonEncode(_assignments.map((a) => a.toJson()).toList());
      await prefs.setString('assignments', assignmentsJson);
    } catch (e) {
      print('Error caching assignments: $e');
    }
  }

  // Create a new assignment
  Future<bool> createAssignment(Assignment assignment) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/assignments'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
          body: jsonEncode({
            'title': assignment.title,
            'description': assignment.description,
            'course': assignment.courseId,
            'dueDate': assignment.dueDate.toIso8601String(),
            'points': assignment.points,
          }),
        );

        if (response.statusCode == 201) {
          await _loadAssignments();
          return true;
        }
        return false;
      } catch (e) {
        print('Error creating assignment: $e');
        return false;
      }
    }

    // Local implementation
    final newAssignment = Assignment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: assignment.title,
      description: assignment.description,
      courseId: assignment.courseId,
      courseTitle: assignment.courseTitle,
      dueDate: assignment.dueDate,
      points: assignment.points,
    );

    _assignments.add(newAssignment);
    await _cacheAssignments();
    notifyListeners();
    return true;
  }

  // Submit an assignment
  Future<bool> submitAssignment(String assignmentId, String submissionContent) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/assignments/$assignmentId/submit'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
          body: jsonEncode({
            'submissionText': submissionContent,
            'submissionUrl': '', // Could be used for file uploads
          }),
        );

        if (response.statusCode == 200) {
          await _loadAssignments();
          return true;
        }
        return false;
      } catch (e) {
        print('Error submitting assignment: $e');
        return false;
      }
    }

    // Local implementation
    final index = _assignments.indexWhere((a) => a.id == assignmentId);
    if (index != -1) {
      final assignment = _assignments[index];
      _assignments[index] = Assignment(
        id: assignment.id,
        title: assignment.title,
        description: assignment.description,
        courseId: assignment.courseId,
        courseTitle: assignment.courseTitle,
        dueDate: assignment.dueDate,
        points: assignment.points,
        isSubmitted: true,
      );
      await _cacheAssignments();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Grade an assignment (teacher only)
  Future<bool> gradeAssignment(String assignmentId, String submissionId, int grade, String feedback) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/assignments/$assignmentId/grade/$submissionId'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
          body: jsonEncode({
            'grade': grade,
            'feedback': feedback,
          }),
        );

        if (response.statusCode == 200) {
          await _loadAssignments();
          return true;
        }
        return false;
      } catch (e) {
        print('Error grading assignment: $e');
        return false;
      }
    }

    // Local implementation (simplified)
    final index = _assignments.indexWhere((a) => a.id == assignmentId);
    if (index != -1) {
      final assignment = _assignments[index];
      _assignments[index] = Assignment(
        id: assignment.id,
        title: assignment.title,
        description: assignment.description,
        courseId: assignment.courseId,
        courseTitle: assignment.courseTitle,
        dueDate: assignment.dueDate,
        points: assignment.points,
        isSubmitted: assignment.isSubmitted,
        grade: grade,
      );
      await _cacheAssignments();
      notifyListeners();
      return true;
    }
    return false;
  }
}
