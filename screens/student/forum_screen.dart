import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:edubridge/models/question.dart';
import 'package:edubridge/widgets/student_question_card.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // Sample data
  final List<Question> _allQuestions = [
    Question(
      id: '1',
      studentName: 'Sophie Martin',
      studentAvatar: 'assets/images/student1.jpg',
      courseTitle: 'Algèbre linéaire',
      question: 'Comment résoudre un système d\'équations linéaires avec la méthode de Gauss?',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      answered: false,
    ),
    Question(
      id: '2',
      studentName: 'Thomas Dubois',
      studentAvatar: 'assets/images/student2.jpg',
      courseTitle: 'Programmation Python',
      question: 'Quelle est la différence entre une liste et un tuple en Python?',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      answered: false,
    ),
    Question(
      id: '3',
      studentName: 'Emma Garcia',
      studentAvatar: 'assets/images/student3.jpg',
      courseTitle: 'Mécanique quantique',
      question: 'Pouvez-vous expliquer le principe d\'incertitude de Heisenberg?',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      answered: true,
    ),
    Question(
      id: '4',
      studentName: 'Lucas Bernard',
      studentAvatar: 'assets/images/student4.jpg',
      courseTitle: 'Anglais technique',
      question: 'Comment rédiger un rapport technique en anglais?',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      answered: true,
    ),
    Question(
      id: '5',
      studentName: 'Chloé Petit',
      studentAvatar: 'assets/images/student5.jpg',
      courseTitle: 'Algèbre linéaire',
      question: 'Quelle est la différence entre une matrice inversible et une matrice singulière?',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      answered: true,
    ),
  ];

  List<Question> get _myQuestions => _allQuestions.where((q) => q.studentName == 'Sophie Martin').toList();
  List<Question> get _answeredQuestions => _allQuestions.where((q) => q.answered).toList();
  List<Question> get _unansweredQuestions => _allQuestions.where((q) => !q.answered).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum de discussion'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Mes questions'),
            Tab(text: 'Répondues'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une question...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuestionsList(_allQuestions),
                _buildQuestionsList(_myQuestions),
                _buildQuestionsList(_answeredQuestions),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAskQuestionDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuestionsList(List<Question> questions) {
    return questions.isEmpty
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
                  'Aucune question trouvée',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Soyez le premier à poser une question!',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: StudentQuestionCard(
                  question: question,
                  onTap: () {
                    // Navigate to question detail
                  },
                ),
              );
            },
          );
  }

  void _showAskQuestionDialog(BuildContext context) {
    final TextEditingController questionController = TextEditingController();
    final TextEditingController courseController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Poser une question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: 'Cours',
                hintText: 'Sélectionnez un cours',
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'Entrez votre question',
                prefixIcon: Icon(Icons.help_outline),
              ),
              maxLines: 3,
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
              // Add question logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Question posée avec succès!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Poser'),
          ),
        ],
      ),
    );
  }
}

