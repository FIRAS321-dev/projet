import 'package:flutter/material.dart';
import 'package:edubridge/models/lesson.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:edubridge/widgets/custom_button.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final String courseTitle;

  const LessonDetailScreen({
    Key? key,
    required this.lesson,
    required this.courseTitle,
  }) : super(key: key);

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool _isCompleted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.lesson.isCompleted;
  }

  void _markAsCompleted() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isCompleted = true;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leçon marquée comme terminée!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson header
            _buildLessonHeader(),

            // Lesson content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contenu de la leçon',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  _buildLessonContent(),
                ],
              ),
            ),

            // Resources section
            if (widget.lesson.type != LessonType.quiz)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ressources',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 16),
                    _buildResourcesList(),
                  ],
                ),
              ),

            // Mark as completed button
            if (!_isCompleted)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  text: 'Marquer comme terminé',
                  isLoading: _isLoading,
                  onPressed: _markAsCompleted,
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLessonTypeColor(
                    widget.lesson.type,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getLessonTypeIcon(widget.lesson.type),
                      size: 16,
                      color: _getLessonTypeColor(widget.lesson.type),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getLessonTypeText(widget.lesson.type),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getLessonTypeColor(widget.lesson.type),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.textSecondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.lesson.duration,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Terminé',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.lesson.title,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Cours: ${widget.courseTitle}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent() {
    switch (widget.lesson.type) {
      case LessonType.video:
        return _buildVideoContent();
      case LessonType.document:
        return _buildDocumentContent();
      case LessonType.exercise:
        return _buildExerciseContent();
      case LessonType.quiz:
        return _buildQuizContent();
    }
  }

  Widget _buildVideoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video player placeholder
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),

        // Video description
        const Text(
          'Dans cette leçon, nous allons explorer les concepts fondamentaux de cette matière. Vous apprendrez les principes de base et comment les appliquer dans différentes situations.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),

        // Video chapters
        Text('Chapitres', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _buildVideoChapter('Introduction', '00:00'),
        _buildVideoChapter('Concepts de base', '03:45'),
        _buildVideoChapter('Applications pratiques', '08:20'),
        _buildVideoChapter('Exemples concrets', '12:30'),
        _buildVideoChapter('Conclusion', '17:15'),
      ],
    );
  }

  Widget _buildVideoChapter(String title, String timestamp) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.play_arrow, color: AppTheme.primaryColor),
      ),
      title: Text(title),
      trailing: Text(
        timestamp,
        style: TextStyle(color: AppTheme.textSecondaryColor),
      ),
      onTap: () {
        // Jump to specific timestamp
      },
    );
  }

  Widget _buildDocumentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Document preview
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.description,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Aperçu du document',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // Open document in full screen
                },
                icon: const Icon(Icons.fullscreen),
                label: const Text('Voir en plein écran'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Document description
        const Text(
          'Ce document contient toutes les informations nécessaires pour comprendre les concepts abordés dans cette leçon. Vous y trouverez des explications détaillées, des exemples et des illustrations.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildExerciseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise instructions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Complétez les exercices suivants en appliquant les concepts que vous avez appris. Vous pouvez soumettre vos réponses en ligne ou les télécharger pour les compléter hors ligne.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Exercise list
        Text('Exercices', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildExerciseItem('Exercice 1: Concepts de base', 'Facile'),
        _buildExerciseItem('Exercice 2: Application pratique', 'Moyen'),
        _buildExerciseItem('Exercice 3: Cas avancés', 'Difficile'),
        const SizedBox(height: 24),

        // Submit button
        CustomButton(
          text: 'Soumettre les réponses',
          onPressed: () {
            // Submit answers
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Réponses soumises avec succès!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExerciseItem(String title, String difficulty) {
    Color difficultyColor;
    switch (difficulty.toLowerCase()) {
      case 'facile':
        difficultyColor = Colors.green;
        break;
      case 'moyen':
        difficultyColor = Colors.orange;
        break;
      case 'difficile':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = AppTheme.textSecondaryColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.assignment, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: difficultyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                difficulty,
                style: TextStyle(
                  fontSize: 12,
                  color: difficultyColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Open exercise
        },
      ),
    );
  }

  Widget _buildQuizContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quiz instructions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ce quiz contient 5 questions à choix multiples. Vous avez 15 minutes pour le compléter. Bonne chance!',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quiz info
        Row(
          children: [
            _buildQuizInfoItem(Icons.help_outline, '5 questions'),
            const SizedBox(width: 16),
            _buildQuizInfoItem(Icons.access_time, '15 minutes'),
            const SizedBox(width: 16),
            _buildQuizInfoItem(Icons.star_outline, '10 points'),
          ],
        ),
        const SizedBox(height: 24),

        // Start quiz button
        CustomButton(
          text: 'Commencer le quiz',
          onPressed: () {
            // Start quiz
            _showStartQuizDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildQuizInfoItem(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesList() {
    return Column(
      children: [
        _buildResourceItem(
          'Document de cours',
          'PDF',
          '2.5 MB',
          Icons.picture_as_pdf,
          Colors.red,
        ),
        _buildResourceItem(
          'Présentation',
          'PPTX',
          '4.8 MB',
          Icons.slideshow,
          Colors.orange,
        ),
        _buildResourceItem(
          'Exercices supplémentaires',
          'PDF',
          '1.2 MB',
          Icons.picture_as_pdf,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildResourceItem(
    String title,
    String format,
    String size,
    IconData icon,
    Color iconColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title),
        subtitle: Text('$format • $size'),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            // Download resource
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Téléchargement de $title en cours...'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          },
        ),
        onTap: () {
          // Open resource
        },
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Télécharger'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Téléchargement en cours...'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Partager'),
                onTap: () {
                  Navigator.pop(context);
                  // Share lesson
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('Ajouter aux favoris'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ajouté aux favoris'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined),
                title: const Text('Signaler un problème'),
                onTap: () {
                  Navigator.pop(context);
                  // Report issue
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStartQuizDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Commencer le quiz'),
            content: const Text(
              'Vous êtes sur le point de commencer le quiz. Une fois commencé, vous aurez 15 minutes pour le terminer. Êtes-vous prêt?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Start quiz
                },
                child: const Text('Commencer'),
              ),
            ],
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
