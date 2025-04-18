import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/course.dart';
import '../models/notification_model.dart';
import '../models/lesson.dart';
import '../models/question.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'edubridge.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Créer la table des cours
    await db.execute('''
      CREATE TABLE courses(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        imageUrl TEXT,
        teacherId TEXT,
        category TEXT,
        duration INTEGER,
        createdAt TEXT
      )
    ''');

    // Créer la table des leçons
    await db.execute('''
      CREATE TABLE lessons(
        id TEXT PRIMARY KEY,
        courseId TEXT,
        title TEXT,
        content TEXT,
        duration INTEGER,
        order_index INTEGER,
        FOREIGN KEY (courseId) REFERENCES courses (id)
      )
    ''');

    // Créer la table des notifications
    await db.execute('''
      CREATE TABLE notifications(
        id TEXT PRIMARY KEY,
        title TEXT,
        message TEXT,
        timestamp TEXT,
        isRead INTEGER,
        userId TEXT,
        type TEXT
      )
    ''');

    // Créer la table des questions
    await db.execute('''
      CREATE TABLE questions(
        id TEXT PRIMARY KEY,
        courseId TEXT,
        userId TEXT,
        userName TEXT,
        question TEXT,
        timestamp TEXT,
        answers TEXT,
        FOREIGN KEY (courseId) REFERENCES courses (id)
      )
    ''');

    // Créer la table des utilisateurs
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        userType TEXT,
        profileImageUrl TEXT
      )
    ''');

    // Créer la table des examens
    await db.execute('''
      CREATE TABLE exams(
        id TEXT PRIMARY KEY,
        courseId TEXT,
        title TEXT,
        date TEXT,
        duration INTEGER,
        FOREIGN KEY (courseId) REFERENCES courses (id)
      )
    ''');

    // Créer la table des emplois du temps
    await db.execute('''
      CREATE TABLE timetable(
        id TEXT PRIMARY KEY,
        userId TEXT,
        day TEXT,
        startTime TEXT,
        endTime TEXT,
        courseId TEXT,
        FOREIGN KEY (courseId) REFERENCES courses (id)
      )
    ''');
  }

  // Méthodes CRUD pour les cours
  Future<List<Course>> getCourses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return List.generate(maps.length, (i) {
      return Course.fromMap(maps[i], maps[i]['id']);
    });
  }

  Future<void> addCourse(Course course) async {
    final db = await database;
    await db.insert(
      'courses',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCourse(Course course) async {
    final db = await database;
    await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<void> deleteCourse(String id) async {
    final db = await database;
    await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour les notifications
  Future<List<NotificationModel>> getNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notifications');
    return List.generate(maps.length, (i) {
      return NotificationModel.fromMap(maps[i], maps[i]['id']);
    });
  }

  Future<void> addNotification(NotificationModel notification) async {
    final db = await database;
    await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markNotificationAsRead(String id) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour les leçons
  Future<List<Lesson>> getLessons(String courseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
    return List.generate(maps.length, (i) {
      return Lesson.fromMap(maps[i]);
    });
  }

  // Méthodes CRUD pour les questions
  Future<List<Question>> getQuestions(String courseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
    return List.generate(maps.length, (i) {
      return Question.fromMap(maps[i]);
    });
  }

  Future<void> addQuestion(Question question) async {
    final db = await database;
    await db.insert(
      'questions',
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Méthode pour vider toutes les tables (utile pour la réinitialisation)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('courses');
    await db.delete('lessons');
    await db.delete('notifications');
    await db.delete('questions');
    await db.delete('exams');
    await db.delete('timetable');
  }
}

