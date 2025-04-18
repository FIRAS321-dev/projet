import 'package:flutter/material.dart';
import 'package:edubridge/models/course.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:edubridge/widgets/lesson_card.dart';
import 'package:edubridge/models/lesson.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                  Tab(text: 'À propos'),
                  Tab(text: 'Forum'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildContentTab(),
            _buildAboutTab(),
            _buildForumTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Download course materials
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Téléchargement des ressources en cours...'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.download),
        label: const Text('Télécharger'),
      ),
    );
  }

  Widget _buildContentTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Progress indicator
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progression du cours',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(widget.course.progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: widget.course.progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),
            Text(
              'Leçons',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
          ],
        ),
        
        // Lessons list
        ..._lessons.map((lesson) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: LessonCard(
            lesson: lesson,
            onTap: () {
              // Navigate to lesson detail
            },
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'À propos du cours',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ce cours vous permettra de maîtriser les concepts fondamentaux et avancés de la matière. Vous apprendrez à travers des leçons théoriques, des exercices pratiques et des études de cas réels.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Enseignant',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        widget.course.teacherName.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course.teacherName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Professeur de ${widget.course.subject}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Informations',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                _buildInfoItem(Icons.book, 'Matière', widget.course.subject),
                const SizedBox(height: 8),
                _buildInfoItem(Icons.access_time, 'Durée', '${widget.course.totalLessons * 20} minutes'),
                const SizedBox(height: 8),
                _buildInfoItem(Icons.list, 'Leçons', '${widget.course.totalLessons} leçons'),
                const SizedBox(height: 8),
                _buildInfoItem(Icons.language, 'Langue', 'Français'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForumTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.forum_outlined,
            size: 64,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Forum du cours',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Posez vos questions et discutez avec les autres étudiants et le professeur',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to forum
            },
            icon: const Icon(Icons.question_answer),
            label: const Text('Poser une question'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(value),
      ],
    );
  }
}

