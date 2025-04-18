import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:edubridge/models/question.dart';
import 'package:edubridge/widgets/student_question_card.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Liste vide pour les questions
  final List<Question> _allQuestions = [];

  // Liste vide pour les étudiants
  final List<Map<String, dynamic>> _students = [];

  List<Question> get _answeredQuestions =>
      _allQuestions.where((q) => q.answered).toList();
  List<Question> get _unansweredQuestions =>
      _allQuestions.where((q) => !q.answered).toList();
  List<Question> get _courseQuestions => _allQuestions
      .where((q) =>
          q.courseTitle == 'Algèbre linéaire' ||
          q.courseTitle == 'Programmation Python' ||
          q.courseTitle == 'Mécanique quantique')
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialiser la liste des étudiants (vide pour l'instant)
    _loadStudents();
  }

  // Méthode pour charger les étudiants (simulée)
  void _loadStudents() {
    // Dans une application réelle, cette méthode chargerait les étudiants depuis une API
    setState(() {
      _students = [];
    });
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
            Tab(text: 'Non répondues'),
            Tab(text: 'Mes cours'),
          ],
        ),
        actions: [
          // Bouton pour initier une discussion avec un étudiant spécifique
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Discuter avec un étudiant',
            onPressed: () {
              _showStudentSelectionDialog();
            },
          ),
        ],
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
              onChanged: (value) {
                // Implement search functionality
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuestionsList(_allQuestions),
                _buildQuestionsList(_unansweredQuestions),
                _buildQuestionsList(_courseQuestions),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showStudentSelectionDialog();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.message),
        tooltip: 'Nouvelle discussion',
      ),
    );
  }

  Widget _buildQuestionsList(List<Question> questions) {
    // Filter questions based on search query
    final String searchQuery = _searchController.text.toLowerCase();
    final filteredQuestions = searchQuery.isEmpty
        ? questions
        : questions
            .where((q) =>
                q.question.toLowerCase().contains(searchQuery) ||
                q.studentName.toLowerCase().contains(searchQuery) ||
                q.courseTitle.toLowerCase().contains(searchQuery))
            .toList();

    return filteredQuestions.isEmpty
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
                  'Les questions des étudiants apparaîtront ici',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredQuestions.length,
            itemBuilder: (context, index) {
              final question = filteredQuestions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: StudentQuestionCard(
                  question: question,
                  onTap: () {
                    _showAnswerDialog(context, question);
                  },
                ),
              );
            },
          );
  }

  void _showAnswerDialog(BuildContext context, Question question) {
    final TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Répondre à la question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question de ${question.studentName}:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
              if (answerController.text.isNotEmpty) {
                setState(() {
                  // Update question status
                  final index =
                      _allQuestions.indexWhere((q) => q.id == question.id);
                  if (index != -1) {
                    // In a real app, this would be done through a service
                    // that updates the database
                    _allQuestions[index] = Question(
                      id: question.id,
                      studentName: question.studentName,
                      studentAvatar: question.studentAvatar,
                      courseTitle: question.courseTitle,
                      question: question.question,
                      timestamp: question.timestamp,
                      answered: true,
                    );
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Réponse envoyée avec succès!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer une réponse'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Répondre'),
          ),
        ],
      ),
    );
  }

  // Nouvelle méthode pour afficher la boîte de dialogue de sélection d'étudiant
  void _showStudentSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir un étudiant'),
        content: _students.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: AppTheme.textSecondaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucun étudiant disponible',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Les étudiants inscrits à vos cours apparaîtront ici',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: student['avatar'] != null
                            ? AssetImage(student['avatar'])
                            : null,
                        child: student['avatar'] == null
                            ? Text(student['name'][0])
                            : null,
                      ),
                      title: Text(student['name']),
                      subtitle: Text(student['email']),
                      onTap: () {
                        Navigator.pop(context);
                        _startNewDiscussion(student);
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  // Méthode pour démarrer une nouvelle discussion avec un étudiant
  void _startNewDiscussion(Map<String, dynamic> student) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message à ${student['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Votre message',
                hintText: 'Entrez votre message',
                border: OutlineInputBorder(),
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
              if (messageController.text.isNotEmpty) {
                // Logique d'envoi du message
                // Dans une application réelle, cela enverrait le message à l'étudiant
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message envoyé à ${student['name']}'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un message'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
