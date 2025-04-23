class Question {
  final String id;
  final String studentName;
  final String studentAvatar;
  final String courseTitle;
  final String question;
  final DateTime timestamp;
  final bool answered;
  final String? answer;

  Question({
    required this.id,
    required this.studentName,
    required this.studentAvatar,
    required this.courseTitle,
    required this.question,
    required this.timestamp,
    required this.answered,
    this.answer,
  });

  // Convert to JSON for API communication
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'studentAvatar': studentAvatar,
      'courseTitle': courseTitle,
      'question': question,
      'timestamp': timestamp.toIso8601String(),
      'answered': answered,
      'answer': answer,
    };
  }

  // Create from JSON response
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'] ?? json['id'] ?? '',
      studentName: json['studentName'] ?? '',
      studentAvatar: json['studentAvatar'] ?? 'assets/images/default_avatar.jpg',
      courseTitle: json['courseTitle'] ?? '',
      question: json['text'] ?? json['question'] ?? '',
      timestamp: json['timestamp'] != null ? 
          DateTime.parse(json['timestamp']) : 
          DateTime.now(),
      answered: json['answered'] ?? false,
      answer: json['answer'],
    );
  }
}
