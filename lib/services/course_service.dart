import 'package:edubridge/models/course.dart';
import 'package:edubridge/models/lesson.dart';
import 'package:edubridge/services/database_service.dart';
import 'package:flutter/foundation.dart';

class CourseService extends ChangeNotifier {
  final DatabaseService _databaseService;
  bool _isLoading = false;
  String? _error;
  List<Course> _courses = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Course> get courses => _courses;

  CourseService(this._databaseService) {
    _loadCourses();
  }

  void _loadCourses() {
    _setLoading(true);
    _databaseService.getCoursesStream().listen(
      (coursesData) {
        _courses = coursesData.map((data) => Course.fromMap(data)).toList();
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _handleError(error);
      },
    );
  }

  Future<List<Lesson>> getLessonsForCourse(String courseId) async {
    try {
      final lessonsStream = _databaseService.getLessonsForCourseStream(courseId);
      final lessonsData = await lessonsStream.first;
      return lessonsData.map((data) => Lesson.fromMap(data)).toList();
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  Future<void> addCourse(Course course) async {
    _setLoading(true);
    try {
      await _databaseService.addCourse(course.toMap());
      _setLoading(false);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateCourse(Course course) async {
    _setLoading(true);
    try {
      await _databaseService.updateCourse(course.id, course.toMap());
      _setLoading(false);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteCourse(String courseId) async {
    _setLoading(true);
    try {
      await _databaseService.deleteCourse(courseId);
      _setLoading(false);
    } catch (e) {
      _handleError(e);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    debugPrint('Erreur dans CourseService: $error');
    _error = 'Une erreur est survenue: $error';
    _isLoading = false;
    notifyListeners();
  }
}

