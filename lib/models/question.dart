class Question {
  final String id;
  final String studentName;
  final String studentAvatar;
  final String courseTitle;
  final String question;
  final DateTime timestamp;
  final bool answered;

  Question({
    required this.id,
    required this.studentName,
    required this.studentAvatar,
    required this.courseTitle,
    required this.question,
    required this.timestamp,
    required this.answered,
  });
}
