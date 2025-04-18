import 'package:flutter/material.dart';
import 'package:edubridge/models/lesson.dart';
import 'package:edubridge/theme/app_theme.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonCard({
    Key? key,
    required this.lesson,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Lesson type icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getLessonTypeColor(lesson.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getLessonTypeIcon(lesson.type),
                    color: _getLessonTypeColor(lesson.type),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Lesson info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: lesson.isCompleted
                            ? AppTheme.textPrimaryColor
                            : AppTheme.textPrimaryColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getLessonTypeText(lesson.type)} • ${lesson.duration}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Completion status
              lesson.isCompleted
                  ? const Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 24,
                    )
                  : const Icon(
                      Icons.play_circle_fill,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_circle_outline;
      case LessonType.document:
        return Icons.article_outlined;
      case LessonType.exercise:
        return Icons.assignment_outlined;
      case LessonType.quiz:
        return Icons.quiz_outlined;
    }
  }

  Color _getLessonTypeColor(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Colors.blue;
      case LessonType.document:
        return Colors.green;
      case LessonType.exercise:
        return Colors.orange;
      case LessonType.quiz:
        return Colors.purple;
    }
  }

  String _getLessonTypeText(LessonType type) {
    switch (type) {
      case LessonType.video:
        return 'Vidéo';
      case LessonType.document:
        return 'Document';
      case LessonType.exercise:
        return 'Exercice';
      case LessonType.quiz:
        return 'Quiz';
    }
  }
}

