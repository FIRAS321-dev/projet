import 'package:flutter/material.dart';
import 'package:edubridge/models/course.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:edubridge/widgets/lesson_card.dart';
import 'package:edubridge/models/lesson.dart';
import 'package:edubridge/models/question.dart';
import 'package:edubridge/widgets/student_question_card.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data
  final List<Lesson> _lessons = [
    Lesson(
      id: '1',
      title: 'Introduction au cours',
      duration: '15 min',
      isCompleted: true,
      type: LessonType.video,
    ),
    Lesson(
      id: '2',
      title: 'Concepts fondamentaux',
      duration: '25 min',
      isCompleted: true,
      type: LessonType.document,
    ),
    Lesson(
      id: '3',
      title: 'Exercices pratiques',
      duration: '30 min',
      isCompleted: true,
      type: LessonType.exercise,
    ),
    Lesson(
      id: '4',
      title: 'Applications avancées',
      duration: '20 min',
      isCompleted: false,
      type: LessonType.video,
    ),
    Lesson(
      id: '5',
      title: 'Étude de cas',
      duration: '40 min',
      isCompleted: false,
      type: LessonType.document,
    ),
    Lesson(
      id: '6',
      title: 'Quiz final',
      duration: '15 min',
      isCompleted: false,
      type: LessonType.quiz,
    ),
  ];

  final List<Question> _questions = [
    Question(
      id: '1',
      studentName: 'Sophie Martin',
      studentAvatar: 'assets/images/student1.jpg',
      courseTitle: 'Algèbre linéaire',
      question:
          'Comment résoudre un système d\'équations linéaires avec la méthode de Gauss?',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      answered: false,
    ),
    Question(
      id: '2',
      studentName: 'Thomas Dubois',
      studentAvatar: 'assets/images/student2.jpg',
      courseTitle: 'Programmation Python',
      question:
          'Quelle est la différence entre une liste et un tuple en Python?',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      answered: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.course.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/course_bg.jpg',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Contenu'),
                  Tab(text: 'Étudiants'),
                  Tab(text: 'Questions'),
                  Tab(text: 'Statistiques'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildContentTab(),
            _buildStudentsTab(),
            _buildQuestionsTab(),
            _buildStatsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new lesson
          _showAddLessonDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une leçon'),
      ),
    );
  }

  Widget _buildContentTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Course progress
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progression du cours',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressItem(
                      icon: Icons.book,
                      value:
                          '${widget.course.completedLessons}/${widget.course.totalLessons}',
                      label: 'Leçons',
                    ),
                    _buildProgressItem(
                      icon: Icons.people,
                      value: '${widget.course.studentsCount}',
                      label: 'Étudiants',
                    ),
                    _buildProgressItem(
                      icon: Icons.access_time,
                      value: '${widget.course.totalLessons * 20}',
                      label: 'Minutes',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Lessons list
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Leçons', style: Theme.of(context).textTheme.displaySmall),
            TextButton.icon(
              onPressed: () {
                // Reorder lessons
              },
              icon: const Icon(Icons.sort),
              label: const Text('Réorganiser'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ..._lessons
            .map(
              (lesson) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Dismissible(
                  key: Key(lesson.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Supprimer la leçon'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir supprimer cette leçon?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                    );
                  },
                  onDismissed: (direction) {
                    // Remove lesson
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Leçon "${lesson.title}" supprimée'),
                        action: SnackBarAction(
                          label: 'Annuler',
                          onPressed: () {
                            // Undo deletion
                          },
                        ),
                      ),
                    );
                  },
                  child: LessonCard(
                    lesson: lesson,
                    onTap: () {
                      // Edit lesson
                    },
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildStudentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.course.studentsCount ?? 0,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                String.fromCharCode(65 + index),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('Étudiant ${index + 1}'),
            subtitle: Text('Progression: ${(index % 10) * 10}%'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show student options
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionsTab() {
    return _questions.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.question_answer_outlined,
                size: 64,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune question pour ce cours',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Les questions des étudiants apparaîtront ici',
                style: TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final question = _questions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: StudentQuestionCard(
                question: question,
                onTap: () {
                  // Show answer dialog
                  _showAnswerDialog(context, question);
                },
              ),
            );
          },
        );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vue d\'ensemble',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  _buildStatItem(
                    icon: Icons.visibility,
                    title: 'Vues totales',
                    value: '${widget.course.studentsCount! * 5}',
                  ),
                  const SizedBox(height: 12),
                  _buildStatItem(
                    icon: Icons.download,
                    title: 'Téléchargements',
                    value: '${widget.course.studentsCount! * 3}',
                  ),
                  const SizedBox(height: 12),
                  _buildStatItem(
                    icon: Icons.star,
                    title: 'Note moyenne',
                    value: '4.7/5',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Engagement des étudiants',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progression des étudiants',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar('Terminé', 0.3, Colors.green),
                  const SizedBox(height: 8),
                  _buildProgressBar('En cours', 0.5, AppTheme.primaryColor),
                  const SizedBox(height: 8),
                  _buildProgressBar('Pas commencé', 0.2, Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leçons les plus populaires',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildPopularLesson('Introduction au cours', 95),
                  const SizedBox(height: 8),
                  _buildPopularLesson('Concepts fondamentaux', 87),
                  const SizedBox(height: 8),
                  _buildPopularLesson('Exercices pratiques', 76),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: AppTheme.primaryColor, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text('${(value * 100).toInt()}%')],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildPopularLesson(String title, int views) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$views vues',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddLessonDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    LessonType selectedType = LessonType.video;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajouter une leçon'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    hintText: 'Entrez le titre de la leçon',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Durée (minutes)',
                    hintText: 'Entrez la durée de la leçon',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<LessonType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items:
                      LessonType.values.map((LessonType type) {
                        String label;
                        switch (type) {
                          case LessonType.video:
                            label = 'Vidéo';
                            break;
                          case LessonType.document:
                            label = 'Document';
                            break;
                          case LessonType.exercise:
                            label = 'Exercice';
                            break;
                          case LessonType.quiz:
                            label = 'Quiz';
                            break;
                        }
                        return DropdownMenuItem<LessonType>(
                          value: type,
                          child: Text(label),
                        );
                      }).toList(),
                  onChanged: (LessonType? newValue) {
                    if (newValue != null) {
                      selectedType = newValue;
                    }
                  },
                ),
              ],
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
                  // Add lesson logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Leçon ajoutée avec succès!'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
    );
  }

  void _showAnswerDialog(BuildContext context, Question question) {
    final TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Répondre à la question'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question de ${question.studentName}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(question.question),
                const SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    labelText: 'Votre réponse',
                    hintText: 'Entrez votre réponse',
                    prefixIcon: Icon(Icons.question_answer),
                  ),
                  maxLines: 5,
                ),
              ],
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
                  // Submit answer logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Réponse envoyée avec succès!'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                child: const Text('Répondre'),
              ),
            ],
          ),
    );
  }
}
