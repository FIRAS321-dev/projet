import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edubridge/models/course.dart';
import 'package:edubridge/models/lesson.dart';

class CourseService extends ChangeNotifier {
  List<Course> _courses = [];
  bool _useLocalData = false; // Set to false to use API data instead of sample data
  final String _baseUrl = 'http://localhost:5000';
  String? _authToken;
  
  // Initialize service
  CourseService() {
    _loadCourses();
  }
  
  // Set user data for API requests
  void setUserData(String token) {
    _authToken = token;
    _loadCourses(); // Reload courses with new auth data
  }
  
  // Sample data for fallback
  // Sample data with all required fields correctly specified
  final List<Course> _sampleCourses = [
    Course(
      id: '1',
      title: 'Algèbre linéaire',
      subject: 'Mathématiques',
      description: 'Introduction aux concepts fondamentaux de l\'algèbre linéaire et leurs applications.',
      teacherName: 'Dr. Martin',
      imageUrl: 'assets/images/math.jpg',
      progress: 0.75,
      totalLessons: 12,
      completedLessons: 9,
      studentsCount: 45,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 60)),
    ),
    Course(
      id: '2',
      title: 'Programmation Python',
      subject: 'Informatique',
      description: 'Apprentissage de la programmation avec Python, des bases jusqu\'aux concepts avancés.',
      teacherName: 'Prof. Johnson',
      imageUrl: 'assets/images/programming.jpg',
      progress: 0.5,
      totalLessons: 10,
      completedLessons: 5,
      studentsCount: 32,
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 75)),
    ),
    Course(
      id: '3',
      title: 'Mécanique quantique',
      subject: 'Physique',
      description: 'Étude des principes fondamentaux de la physique quantique et de ses applications.',
      teacherName: 'Dr. Ahmed',
      imageUrl: 'assets/images/physics.jpg',
      progress: 0.3,
      totalLessons: 15,
      completedLessons: 4,
      studentsCount: 28,
      startDate: DateTime.now().subtract(const Duration(days: 45)),
      endDate: DateTime.now().add(const Duration(days: 45)),
    ),
    Course(
      id: '4',
      title: 'Anglais technique',
      subject: 'Langues',
      description: 'Cours spécialisé d\'anglais pour les contextes scientifiques et techniques.',
      teacherName: 'Mme. Garcia',
      imageUrl: 'assets/images/english.jpg',
      progress: 0.9,
      totalLessons: 8,
      completedLessons: 7,
      studentsCount: 22,
      startDate: DateTime.now().subtract(const Duration(days: 60)),
      endDate: DateTime.now().add(const Duration(days: 30)),
    ),
  ];

  // Sample lessons data
  final Map<String, List<Lesson>> _courseLessons = {
    '1': [
      Lesson(
        id: '1',
        title: 'Introduction à l\'algèbre linéaire',
        duration: '15 min',
        isCompleted: true,
        type: LessonType.video,
      ),
      Lesson(
        id: '2',
        title: 'Vecteurs et espaces vectoriels',
        duration: '25 min',
        isCompleted: true,
        type: LessonType.document,
      ),
      Lesson(
        id: '3',
        title: 'Exercices sur les vecteurs',
        duration: '30 min',
        isCompleted: true,
        type: LessonType.exercise,
      ),
      Lesson(
        id: '4',
        title: 'Matrices et opérations',
        duration: '20 min',
        isCompleted: false,
        type: LessonType.video,
      ),
      Lesson(
        id: '5',
        title: 'Déterminants',
        duration: '40 min',
        isCompleted: false,
        type: LessonType.document,
      ),
      Lesson(
        id: '6',
        title: 'Quiz final',
        duration: '15 min',
        isCompleted: false,
        type: LessonType.quiz,
      ),
    ],
  };

  // Load courses from API or local storage
  Future<void> _loadCourses() async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/courses'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          _courses = data.map((json) => _convertJsonToCourse(json)).toList();
          
          // Also load lessons for each course
          for (var course in _courses) {
            await _loadLessonsForCourse(course.id);
          }
          
          // Cache courses locally
          await _cacheCoursesToLocal();
          notifyListeners();
          return;
        }
      } catch (e) {
        print('Error loading courses from API: $e');
        // Fall back to local storage if API fails
      }
    }

    // Load from cache or use sample data
    await _loadCoursesFromCache();
  }
  
  // Load courses from local cache
  Future<void> _loadCoursesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = prefs.getString('courses');
      
      if (coursesJson != null) {
        final List<dynamic> data = jsonDecode(coursesJson);
        _courses = data.map((json) => _convertJsonToCourse(json)).toList();
        
        // Also load lessons from cache
        final lessonsJson = prefs.getString('lessons');
        if (lessonsJson != null) {
          final Map<String, dynamic> lessonsData = jsonDecode(lessonsJson);
          lessonsData.forEach((courseId, lessonsList) {
            _courseLessons[courseId] = (lessonsList as List)
                .map((lessonJson) => _convertJsonToLesson(lessonJson))
                .toList();
          });
        }
      } else {
        // Use sample data if no cache is available
        _courses = List.from(_sampleCourses);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading courses from cache: $e');
      // Fall back to sample data
      _courses = List.from(_sampleCourses);
      notifyListeners();
    }
  }
  
  // Cache courses to local storage
  Future<void> _cacheCoursesToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = jsonEncode(_courses.map((c) => _convertCourseToJson(c)).toList());
      await prefs.setString('courses', coursesJson);
      
      // Also cache lessons
      final Map<String, dynamic> lessonsJson = {};
      _courseLessons.forEach((courseId, lessons) {
        lessonsJson[courseId] = lessons.map((l) => _convertLessonToJson(l)).toList();
      });
      await prefs.setString('lessons', jsonEncode(lessonsJson));
    } catch (e) {
      print('Error caching courses: $e');
    }
  }
  
  // Convert JSON to Course object
  Course _convertJsonToCourse(Map<String, dynamic> json) {
    // Calculate progress if we have the data
    double progress = 0.0;
    if (json['totalLessons'] != null && json['completedLessons'] != null) {
      final totalLessons = json['totalLessons'] as int;
      final completedLessons = json['completedLessons'] as int;
      progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    } else if (json['progress'] != null) {
      progress = (json['progress'] as num).toDouble();
    }
    
    return Course(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      teacherName: json['teacherName'] ?? json['instructor'] ?? '',
      imageUrl: json['imageUrl'] ?? 'assets/images/default_course.jpg',
      progress: progress,
      totalLessons: json['totalLessons'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      studentsCount: json['studentsCount'] ?? json['enrolledStudents']?.length ?? 0,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now().add(const Duration(days: 90)),
    );
  }
  
  // Convert Course to JSON
  Map<String, dynamic> _convertCourseToJson(Course course) {
    return {
      'id': course.id,
      'title': course.title,
      'subject': course.subject,
      'description': course.description,
      'teacherName': course.teacherName,
      'imageUrl': course.imageUrl,
      'progress': course.progress,
      'totalLessons': course.totalLessons,
      'completedLessons': course.completedLessons,
      'studentsCount': course.studentsCount,
      'startDate': course.startDate.toIso8601String(),
      'endDate': course.endDate.toIso8601String(),
    };
  }
  
  // Convert JSON to Lesson
  Lesson _convertJsonToLesson(Map<String, dynamic> json) {
    return Lesson(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '0 min',
      isCompleted: json['isCompleted'] ?? false,
      type: _getLessonTypeFromString(json['type'] ?? 'document'),
    );
  }
  
  // Convert Lesson to JSON
  Map<String, dynamic> _convertLessonToJson(Lesson lesson) {
    return {
      'id': lesson.id,
      'title': lesson.title,
      'duration': lesson.duration,
      'isCompleted': lesson.isCompleted,
      'type': _getLessonTypeString(lesson.type),
    };
  }
  
  // Helper to convert string to LessonType
  LessonType _getLessonTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return LessonType.video;
      case 'document':
        return LessonType.document;
      case 'exercise':
        return LessonType.exercise;
      case 'quiz':
        return LessonType.quiz;
      default:
        return LessonType.document;
    }
  }
  
  // Helper to convert LessonType to string
  String _getLessonTypeString(LessonType type) {
    // Using a straightforward approach to avoid unreachable code warnings
    if (type == LessonType.video) return 'video';
    if (type == LessonType.exercise) return 'exercise';
    if (type == LessonType.quiz) return 'quiz';
    return 'document'; // Default for LessonType.document or any future types
  }
  
  // Load lessons for a specific course
  Future<void> _loadLessonsForCourse(String courseId) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/courses/$courseId/lessons'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          _courseLessons[courseId] = data.map((json) => _convertJsonToLesson(json)).toList();
          return;
        }
      } catch (e) {
        print('Error loading lessons for course $courseId: $e');
      }
    }
    // If we get here, either API failed or we're using local data
    // Keep existing lessons or use empty list
  }
  
  // Getters
  List<Course> get courses => _courses;

  List<Course> getTeacherCourses(String teacherName) {
    return _courses
        .where((course) => course.teacherName == teacherName)
        .toList();
  }

  List<Course> getStudentCourses() {
    if (!_useLocalData && _authToken != null) {
      // This would be implemented with an API call in a real app
      // For now, we'll just return all courses as a simplification
    }
    return _courses;
  }

  List<Course> getCoursesBySubject(String subject) {
    if (subject == 'Tous') {
      return _courses;
    }
    return _courses.where((course) => course.subject == subject).toList();
  }

  Course? getCourseById(String id) {
    try {
      return _courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Lesson> getLessonsForCourse(String courseId) {
    return _courseLessons[courseId] ?? [];
  }

  // CRUD operations
  Future<bool> addCourse(Course course) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/courses'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
          body: jsonEncode({
            'title': course.title,
            'subject': course.subject,
            'description': course.description,
            'imageUrl': course.imageUrl,
            'startDate': course.startDate.toIso8601String(),
            'endDate': course.endDate.toIso8601String(),
          }),
        );

        if (response.statusCode == 201) {
          // Reload courses to get the newly created course with server-generated ID
          await _loadCourses();
          return true;
        }
        return false;
      } catch (e) {
        print('Error adding course: $e');
        // Fall back to local implementation if API fails
      }
    }

    // Local implementation
    final newCourse = Course(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: course.title,
      subject: course.subject,
      description: course.description,
      teacherName: course.teacherName,
      imageUrl: course.imageUrl,
      progress: 0,
      totalLessons: 0,
      completedLessons: 0,
      studentsCount: 0,
      startDate: course.startDate,
      endDate: course.endDate,
    );
    
    _courses.add(newCourse);
    await _cacheCoursesToLocal();
    notifyListeners();
    return true;
  }

  Future<bool> updateCourse(Course course) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.put(
          Uri.parse('$_baseUrl/courses/${course.id}'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
          body: jsonEncode({
            'title': course.title,
            'subject': course.subject,
            'description': course.description,
            'imageUrl': course.imageUrl,
            'startDate': course.startDate.toIso8601String(),
            'endDate': course.endDate.toIso8601String(),
          }),
        );

        if (response.statusCode == 200) {
          // Reload the course to get updated data
          await _loadCourses();
          return true;
        }
        return false;
      } catch (e) {
        print('Error updating course: $e');
        // Fall back to local implementation if API fails
      }
    }

    // Local implementation
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      await _cacheCoursesToLocal();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteCourse(String courseId) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.delete(
          Uri.parse('$_baseUrl/courses/$courseId'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
        );

        if (response.statusCode == 200) {
          // Remove from local list
          _courses.removeWhere((course) => course.id == courseId);
          _courseLessons.remove(courseId);
          await _cacheCoursesToLocal();
          notifyListeners();
          return true;
        }
        return false;
      } catch (e) {
        print('Error deleting course: $e');
        // Fall back to local implementation if API fails
      }
    }

    // Local implementation
    _courses.removeWhere((course) => course.id == courseId);
    _courseLessons.remove(courseId);
    await _cacheCoursesToLocal();
    notifyListeners();
    return true;
  }

  Future<bool> addLesson(String courseId, Lesson lesson) async {
    if (!_useLocalData && _authToken != null) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/courses/$courseId/lessons'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': _authToken!,
          },
          body: jsonEncode({
            'title': lesson.title,
            'duration': lesson.duration,
            'type': _getLessonTypeString(lesson.type),
            'content': '', // Could add content field to Lesson model if needed
          }),
        );

        if (response.statusCode == 201) {
          // Reload lessons for this course to get server-assigned ID
          await _loadLessonsForCourse(courseId);
          
          // Reload course to get updated totalLessons count
          await _loadCourses();
          return true;
        }
        return false;
      } catch (e) {
        print('Error adding lesson: $e');
      }
    }

    // Local implementation
    if (!_courseLessons.containsKey(courseId)) {
      _courseLessons[courseId] = [];
    }

    final newLesson = Lesson(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: lesson.title,
      duration: lesson.duration,
      isCompleted: false,
      type: lesson.type,
    );

    _courseLessons[courseId]!.add(newLesson);

    // Update course total lessons
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex != -1) {
      final course = _courses[courseIndex];
      _courses[courseIndex] = Course(
        id: course.id,
        title: course.title,
        subject: course.subject,
        description: course.description,
        teacherName: course.teacherName,
        imageUrl: course.imageUrl,
        progress: course.progress,
        totalLessons: course.totalLessons + 1,
        completedLessons: course.completedLessons,
        studentsCount: course.studentsCount,
        startDate: course.startDate,
        endDate: course.endDate,
      );
    }

    await _cacheCoursesToLocal();
    notifyListeners();
    return true;
  }

  Future<void> updateLesson(String courseId, Lesson lesson) async {
    if (_courseLessons.containsKey(courseId)) {
      final index = _courseLessons[courseId]!.indexWhere(
        (l) => l.id == lesson.id,
      );
      if (index != -1) {
        _courseLessons[courseId]![index] = lesson;

        // Update course completed lessons if needed
        if (lesson.isCompleted &&
            !_courseLessons[courseId]![index].isCompleted) {
          final courseIndex = _courses.indexWhere((c) => c.id == courseId);
          if (courseIndex != -1) {
            final course = _courses[courseIndex];
            final newCompletedLessons = course.completedLessons + 1;
            final newProgress = newCompletedLessons / course.totalLessons;

            _courses[courseIndex] = Course(
              id: course.id,
              title: course.title,
              subject: course.subject,
              description: course.description,
              teacherName: course.teacherName,
              imageUrl: course.imageUrl,
              progress: newProgress,
              totalLessons: course.totalLessons,
              completedLessons: newCompletedLessons,
              studentsCount: course.studentsCount,
              startDate: course.startDate,
              endDate: course.endDate,
            );
          }
        }

        notifyListeners();
      }
    }
  }

  Future<void> deleteLesson(String courseId, String lessonId) async {
    if (_courseLessons.containsKey(courseId)) {
      final wasCompleted =
          _courseLessons[courseId]!
              .firstWhere(
                (l) => l.id == lessonId,
                orElse:
                    () => Lesson(
                      id: '',
                      title: '',
                      duration: '',
                      isCompleted: false,
                      type: LessonType.document,
                    ),
              )
              .isCompleted;

      _courseLessons[courseId]!.removeWhere((lesson) => lesson.id == lessonId);

      // Update course total and completed lessons
      final courseIndex = _courses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _courses[courseIndex];
        final newTotalLessons = course.totalLessons - 1;
        final newCompletedLessons =
            wasCompleted
                ? course.completedLessons - 1
                : course.completedLessons;
        final newProgress =
            newTotalLessons > 0 ? newCompletedLessons / newTotalLessons : 0.0;

        _courses[courseIndex] = Course(
          id: course.id,
          title: course.title,
          subject: course.subject,
          description: course.description,
          teacherName: course.teacherName,
          imageUrl: course.imageUrl,
          progress: newProgress,
          totalLessons: newTotalLessons,
          completedLessons: newCompletedLessons,
          studentsCount: course.studentsCount,
          startDate: course.startDate,
          endDate: course.endDate,
        );
      }

      notifyListeners();
    }
  }

  // Analytics
  Map<String, dynamic> getCourseAnalytics(String courseId) {
    final course = getCourseById(courseId);
    if (course == null) {
      return {};
    }

    final lessons = getLessonsForCourse(courseId);
    final completedLessons =
        lessons.where((lesson) => lesson.isCompleted).length;
    final progress =
        lessons.isNotEmpty ? completedLessons / lessons.length : 0.0;

    return {
      'totalStudents': course.studentsCount,
      'totalLessons': lessons.length,
      'completedLessons': completedLessons,
      'progress': progress,
      'videoLessons': lessons.where((l) => l.type == LessonType.video).length,
      'documentLessons':
          lessons.where((l) => l.type == LessonType.document).length,
      'exerciseLessons':
          lessons.where((l) => l.type == LessonType.exercise).length,
      'quizLessons': lessons.where((l) => l.type == LessonType.quiz).length,
    };
  }
}
