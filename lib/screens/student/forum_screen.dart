import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:edubridge/models/question.dart';
import 'package:edubridge/widgets/student_question_card.dart';
import 'package:edubridge/services/question_service.dart';
import 'package:edubridge/services/auth_service.dart';
import 'package:provider/provider.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Questions will be loaded from QuestionService

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
    final questionService = Provider.of<QuestionService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUserName = authService.userName ?? 'Étudiant';
    
    final allQuestions = questionService.allQuestions;
    final myQuestions = questionService.getQuestionsByStudent(currentUserName);
    final answeredQuestions = questionService.answeredQuestions;
    
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
                _buildQuestionsList(allQuestions),
                _buildQuestionsList(myQuestions),
                _buildQuestionsList(answeredQuestions),
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
                style: TextStyle(color: AppTheme.textSecondaryColor),
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
    final questionService = Provider.of<QuestionService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserName = authService.userName ?? 'Étudiant';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                onPressed: () async {
                  // Validate inputs
                  if (questionController.text.trim().isEmpty || 
                      courseController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez remplir tous les champs'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                    return;
                  }
                  
                  // Add question to the service
                  await questionService.addQuestion(
                    currentUserName,
                    courseController.text.trim(),
                    questionController.text.trim()
                  );
                  
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
