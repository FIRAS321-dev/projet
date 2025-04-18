class Course {
  final String id;
  final String title;
  final String subject;
  final String teacherName;
  final String imageUrl;
  final double progress;
  final int totalLessons;
  final int completedLessons;
  final int? studentsCount;

  Course({
    required this.id,
    required this.title,
    required this.subject,
    required this.teacherName,
    required this.imageUrl,
    required this.progress,
    required this.totalLessons,
    required this.completedLessons,
    this.studentsCount,
  });
}

