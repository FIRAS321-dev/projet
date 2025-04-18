class Lesson {
  final String id;
  final String title;
  final String content;
  final String courseId;
  final int order;
  final DateTime createdAt;
  final List<String> resources;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.courseId,
    required this.order,
    required this.createdAt,
    this.resources = const [],
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      courseId: map['courseId'] ?? '',
      order: map['order'] ?? 0,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
      resources: List<String>.from(map['resources'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'courseId': courseId,
      'order': order,
      'resources': resources,
    };
  }
}

