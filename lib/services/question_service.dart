import 'package:flutter/material.dart';
import 'package:edubridge/models/question.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuestionService extends ChangeNotifier {
  List<Question> _questions = [];
  bool _useLocalData = false; // Set to true for local fallback
  final String _baseUrl = 'http://localhost:5000';
  String? _authToken;
  
  // Getters
  List<Question> get allQuestions => _questions;
  
  List<Question> getQuestionsByStudent(String studentName) {
    return _questions.where((q) => q.studentName == studentName).toList();
  }
  
  List<Question> get answeredQuestions => 
      _questions.where((q) => q.answered).toList();
  
  List<Question> get unansweredQuestions => 
      _questions.where((q) => !q.answered).toList();
  
  // Set user data for API requests
  void setUserData(String token) {
    _authToken = token;
    _loadQuestions(); // Reload questions with new auth data
  }
  
  // Initialize service
  QuestionService() {
    _loadQuestions();
  }
  
  // Load questions from API or local storage
  Future<void> _loadQuestions() async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/api/questions'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          _questions = data.map((json) {
            return Question(
              id: json['_id'] ?? json['id'] ?? '',
              studentName: json['studentName'] ?? '',
              studentAvatar: json['studentAvatar'] ?? 'assets/images/default_avatar.jpg',
              courseTitle: json['courseTitle'] ?? '',
              question: json['text'] ?? json['question'] ?? '',
              timestamp: json['timestamp'] != null 
                  ? DateTime.parse(json['timestamp']) 
                  : DateTime.now(),
              answered: json['answered'] ?? false,
              answer: json['answer'],
            );
          }).toList();
          
          // Cache questions locally for offline access
          await _saveQuestionsToCache();
          notifyListeners();
          return;
        }
      } catch (e) {
        print('Error loading questions from API: $e');
        // Continue to load from cache if API fails
      }
    }

    // Fallback to local cache if API unavailable or disabled
    await _loadQuestionsFromCache();
  }
  
  // Load questions from local cache
  Future<void> _loadQuestionsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questionsJson = prefs.getString('questions');
      
      if (questionsJson != null) {
        final List<dynamic> decodedList = jsonDecode(questionsJson);
        _questions = decodedList.map((item) {
          return Question(
            id: item['id'],
            studentName: item['studentName'],
            studentAvatar: item['studentAvatar'],
            courseTitle: item['courseTitle'],
            question: item['question'],
            timestamp: DateTime.parse(item['timestamp']),
            answered: item['answered'],
            answer: item['answer'],
          );
        }).toList();
      } else {
        // Load demo questions if cache is empty
        _questions = [
          Question(
            id: '1',
            studentName: 'Sophie Martin',
            studentAvatar: 'assets/images/student1.jpg',
            courseTitle: 'Algèbre linéaire',
            question: 'Comment résoudre un système d\'équations linéaires avec la méthode de Gauss?',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            answered: false,
          ),
          Question(
            id: '2',
            studentName: 'Thomas Dubois',
            studentAvatar: 'assets/images/student2.jpg',
            courseTitle: 'Programmation Python',
            question: 'Quelle est la différence entre une liste et un tuple en Python?',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            answered: false,
          ),
          Question(
            id: '3',
            studentName: 'Emma Garcia',
            studentAvatar: 'assets/images/student3.jpg',
            courseTitle: 'Mécanique quantique',
            question: 'Pouvez-vous expliquer le principe d\'incertitude de Heisenberg?',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            answered: true,
            answer: 'Le principe d\'incertitude affirme qu\'on ne peut pas mesurer simultanément et avec précision la position et la quantité de mouvement d\'une particule.',
          ),
        ];
        
        await _saveQuestionsToCache();
      }
      notifyListeners();
    } catch (e) {
      print('Error loading questions from cache: $e');
    }
  }
  
  // Save questions to local cache
  Future<void> _saveQuestionsToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questionsJson = jsonEncode(_questions.map((q) => {
        'id': q.id,
        'studentName': q.studentName,
        'studentAvatar': q.studentAvatar,
        'courseTitle': q.courseTitle,
        'question': q.question,
        'timestamp': q.timestamp.toIso8601String(),
        'answered': q.answered,
        'answer': q.answer,
      }).toList());
      
      await prefs.setString('questions', questionsJson);
    } catch (e) {
      print('Error saving questions to cache: $e');
    }
  }
  
  // Add a new question
  Future<bool> addQuestion(String studentName, String courseTitle, String questionText) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/api/questions'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
          body: jsonEncode({
            'studentName': studentName,
            'courseTitle': courseTitle,
            'text': questionText,
          }),
        );

        if (response.statusCode == 201) {
          // Reload questions from API to get the newly added question
          await _loadQuestions();
          return true;
        }
        return false;
      } catch (e) {
        print('Error adding question to API: $e');
        // Fall back to local storage if API fails
      }
    }

    // Local implementation
    final newQuestion = Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentName: studentName,
      studentAvatar: 'assets/images/default_avatar.jpg', // Default avatar
      courseTitle: courseTitle,
      question: questionText,
      timestamp: DateTime.now(),
      answered: false,
    );
    
    _questions.add(newQuestion);
    await _saveQuestionsToCache();
    notifyListeners();
    return true;
  }
  
  // Mark a question as answered
  Future<bool> markAsAnswered(String questionId, [String? answerText]) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.put(
          Uri.parse('$_baseUrl/api/questions/$questionId/answer'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
          body: jsonEncode({
            'answered': true,
            'answer': answerText ?? 'Marqué comme répondu par l\'enseignant',
          }),
        );

        if (response.statusCode == 200) {
          // Reload questions from API to get the updated data
          await _loadQuestions();
          return true;
        }
        return false;
      } catch (e) {
        print('Error marking question as answered in API: $e');
        // Fall back to local storage if API fails
      }
    }

    // Local implementation
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index != -1) {
      final updatedQuestions = List<Question>.from(_questions);
      final oldQuestion = updatedQuestions[index];
      
      // Create a new question object with answered set to true
      final updatedQuestion = Question(
        id: oldQuestion.id,
        studentName: oldQuestion.studentName,
        studentAvatar: oldQuestion.studentAvatar,
        courseTitle: oldQuestion.courseTitle,
        question: oldQuestion.question,
        timestamp: oldQuestion.timestamp,
        answered: true,
        answer: answerText ?? 'Marqué comme répondu par l\'enseignant',
      );
      
      updatedQuestions[index] = updatedQuestion;
      _questions = updatedQuestions;
      
      await _saveQuestionsToCache();
      notifyListeners();
      return true;
    }
    return false;
  }
  
  // Delete a question
  Future<bool> deleteQuestion(String questionId) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.delete(
          Uri.parse('$_baseUrl/api/questions/$questionId'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
        );

        if (response.statusCode == 200) {
          // Reload questions from API after deletion
          await _loadQuestions();
          return true;
        }
        return false;
      } catch (e) {
        print('Error deleting question from API: $e');
      }
    }

    // Local implementation
    _questions.removeWhere((q) => q.id == questionId);
    await _saveQuestionsToCache();
    notifyListeners();
    return true;
  }
  
  // Refresh questions from API (can be called manually when needed)
  Future<void> refreshQuestions() async {
    await _loadQuestions();
  }
}
