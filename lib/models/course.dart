import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String teacherName;
  final int totalLessons;
  final int completedLessons;
  final double progress;
  final String imageUrl;
  final List<String> tags;
  final DateTime startDate;
  final DateTime endDate;
  final int? studentsCount;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.teacherName,
    required this.totalLessons,
    this.completedLessons = 0,
    this.progress = 0.0,
    this.imageUrl = '',
    this.tags = const [],
    required this.startDate,
    required this.endDate,
    this.studentsCount,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subject: json['subject'],
      teacherName: json['teacherName'],
      totalLessons: json['totalLessons'],
      completedLessons: json['completedLessons'] ?? 0,
      progress: json['progress'] ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      startDate: json['startDate'] is Timestamp 
          ? (json['startDate'] as Timestamp).toDate() 
          : DateTime.parse(json['startDate']),
      endDate: json['endDate'] is Timestamp 
          ? (json['endDate'] as Timestamp).toDate() 
          : DateTime.parse(json['endDate']),
      studentsCount: json['studentsCount'],
    );
  }

  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subject: data['subject'] ?? '',
      teacherName: data['teacherName'] ?? '',
      totalLessons: data['totalLessons'] ?? 0,
      completedLessons: data['completedLessons'] ?? 0,
      progress: (data['progress'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      startDate: data['startDate'] is Timestamp 
          ? (data['startDate'] as Timestamp).toDate() 
          : DateTime.now(),
      endDate: data['endDate'] is Timestamp 
          ? (data['endDate'] as Timestamp).toDate() 
          : DateTime.now().add(const Duration(days: 90)),
      studentsCount: data['studentsCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'teacherName': teacherName,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'progress': progress,
      'imageUrl': imageUrl,
      'tags': tags,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'studentsCount': studentsCount,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'teacherName': teacherName,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'progress': progress,
      'imageUrl': imageUrl,
      'tags': tags,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'studentsCount': studentsCount,
    };
  }
}

