import 'package:flutter/material.dart';
import 'package:edubridge/models/course.dart';
import 'package:edubridge/models/lesson.dart';

class CourseService extends ChangeNotifier {
  // Sample data
  final List<Course> _courses = [
    Course(
      id: '1',
      title: 'Algèbre linéaire',
      subject: 'Mathématiques',
      teacherName: 'Dr. Martin',
      imageUrl: 'assets/images/math.jpg',
      progress: 0.75,
      totalLessons: 12,
      completedLessons: 9,
      studentsCount: 45,
    ),
    Course(
      id: '2',
      title: 'Programmation Python',
      subject: 'Informatique',
      teacherName: 'Prof. Johnson',
      imageUrl: 'assets/images/programming.jpg',
      progress: 0.5,
      totalLessons: 10,
      completedLessons: 5,
      studentsCount: 32,
    ),
    Course(
      id: '3',
      title: 'Mécanique quantique',
      subject: 'Physique',
      teacherName: 'Dr. Ahmed',
      imageUrl: 'assets/images/physics.jpg',
      progress: 0.3,
      totalLessons: 15,
      completedLessons: 4,
      studentsCount: 28,
    ),
    Course(
      id: '4',
      title: 'Anglais technique',
      subject: 'Langues',
      teacherName: 'Mme. Garcia',
      imageUrl: 'assets/images/english.jpg',
      progress: 0.9,
      totalLessons: 8,
      completedLessons: 7,
      studentsCount: 22,
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

  // Getters
  List<Course> get courses => _courses;
  
  List<Course> getTeacherCourses(String teacherName) {
    return _courses.where((course) => course.teacherName == teacherName).toList();
  }
  
  List<Course> getStudentCourses() {
    // In a real app, this would filter based on the student's enrolled courses
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
  Future<void> addCourse(Course course) async {
    _courses.add(course);
    notifyListeners();
  }
  
  Future<void> updateCourse(Course course) async {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      notifyListeners();
    }
  }
  
  Future<void> deleteCourse(String courseId) async {
    _courses.removeWhere((course) => course.id == courseId);
    _courseLessons.remove(courseId);
    notifyListeners();
  }
  
  Future<void> addLesson(String courseId, Lesson lesson) async {
    if (!_courseLessons.containsKey(courseId)) {
      _courseLessons[courseId] = [];
    }
    
    _courseLessons[courseId]!.add(lesson);
    
    // Update course total lessons
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex != -1) {
      final course = _courses[courseIndex];
      _courses[courseIndex] = Course(
        id: course.id,
        title: course.title,
        subject: course.subject,
        teacherName: course.teacherName,
        imageUrl: course.imageUrl,
        progress: course.progress,
        totalLessons: course.totalLessons + 1,
        completedLessons: course.completedLessons,
        studentsCount: course.studentsCount,
      );
    }
    
    notifyListeners();
  }
  
  Future<void> updateLesson(String courseId, Lesson lesson) async {
    if (_courseLessons.containsKey(courseId)) {
      final index = _courseLessons[courseId]!.indexWhere((l) => l.id == lesson.id);
      if (index != -1) {
        _courseLessons[courseId]![index] = lesson;
        
        // Update course completed lessons if needed
        if (lesson.isCompleted && !_courseLessons[courseId]![index].isCompleted) {
          final courseIndex = _courses.indexWhere((c) => c.id == courseId);
          if (courseIndex != -1) {
            final course = _courses[courseIndex];
            final newCompletedLessons = course.completedLessons + 1;
            final newProgress = newCompletedLessons / course.totalLessons;
            
            _courses[courseIndex] = Course(
              id: course.id,
              title: course.title,
              subject: course.subject,
              teacherName: course.teacherName,
              imageUrl: course.imageUrl,
              progress: newProgress,
              totalLessons: course.totalLessons,
              completedLessons: newCompletedLessons,
              studentsCount: course.studentsCount,
            );
          }
        }
        
        notifyListeners();
      }
    }
  }
  
  Future<void> deleteLesson(String courseId, String lessonId) async {
    if (_courseLessons.containsKey(courseId)) {
      final wasCompleted = _courseLessons[courseId]!
          .firstWhere((l) => l.id == lessonId, orElse: () => Lesson(
            id: '',
            title: '',
            duration: '',
            isCompleted: false,
            type: LessonType.document,
          ))
          .isCompleted;
      
      _courseLessons[courseId]!.removeWhere((lesson) => lesson.id == lessonId);
      
      // Update course total and completed lessons
      final courseIndex = _courses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _courses[courseIndex];
        final newTotalLessons = course.totalLessons - 1;
        final newCompletedLessons = wasCompleted
            ? course.completedLessons - 1
            : course.completedLessons;
        final newProgress = newTotalLessons > 0
            ? newCompletedLessons / newTotalLessons
            : 0.0;
        
        _courses[courseIndex] = Course(
          id: course.id,
          title: course.title,
          subject: course.subject,
          teacherName: course.teacherName,
          imageUrl: course.imageUrl,
          progress: newProgress,
          totalLessons: newTotalLessons,
          completedLessons: newCompletedLessons,
          studentsCount: course.studentsCount,
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
    final completedLessons = lessons.where((lesson) => lesson.isCompleted).length;
    final progress = lessons.isNotEmpty ? completedLessons / lessons.length : 0.0;
    
    return {
      'totalStudents': course.studentsCount,
      'totalLessons': lessons.length,
      'completedLessons': completedLessons,
      'progress': progress,
      'videoLessons': lessons.where((l) => l.type == LessonType.video).length,
      'documentLessons': lessons.where((l) => l.type == LessonType.document).length,
      'exerciseLessons': lessons.where((l) => l.type == LessonType.exercise).length,
      'quizLessons': lessons.where((l) => l.type == LessonType.quiz).length,
    };
  }
}

