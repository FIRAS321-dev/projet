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
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      studentsCount: json['studentsCount'],
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
}
