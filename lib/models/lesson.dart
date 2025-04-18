enum LessonType { video, document, exercise, quiz }

class Lesson {
  final String id;
  final String title;
  final String duration;
  final bool isCompleted;
  final LessonType type;

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.isCompleted,
    required this.type,
  });
}
