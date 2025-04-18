import 'package:flutter/material.dart';
import 'package:edubridge/models/course.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:edubridge/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:edubridge/widgets/timetable_widget.dart';
import 'package:edubridge/widgets/exams_widget.dart';
import 'package:edubridge/widgets/profile_photo_widget.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  final List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simuler un chargement de données
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _courses.addAll([
        Course(
          id: '1',
          title: 'Introduction à la programmation',
          description: 'Apprenez les bases de la programmation avec Python',
          subject: 'Informatique',
          teacherName: 'Prof. Martin',
          totalLessons: 12,
          completedLessons: 5,
          progress: 0.42,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 60)),
          tags: ['Python', 'Programmation', 'Débutant'],
        ),
        Course(
          id: '2',
          title: 'Mathématiques avancées',
          description: 'Cours de mathématiques pour les étudiants avancés',
          subject: 'Mathématiques',
          teacherName: 'Prof. Dubois',
          totalLessons: 15,
          completedLessons: 10,
          progress: 0.67,
          startDate: DateTime.now().subtract(const Duration(days: 45)),
          endDate: DateTime.now().add(const Duration(days: 45)),
          tags: ['Algèbre', 'Calcul', 'Avancé'],
        ),
        Course(
          id: '3',
          title: 'Anglais professionnel',
          description: 'Améliorez votre anglais pour le monde professionnel',
          subject: 'Langues',
          teacherName: 'Prof. Smith',
          totalLessons: 10,
          completedLessons: 2,
          progress: 0.2,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 75)),
          tags: ['Anglais', 'Business', 'Communication'],
        ),
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendrier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildCourses();
      case 2:
        return _buildForum();
      case 3:
        return _buildCalendar();
      case 4:
        return _buildProfile();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Cours en cours'),
            const SizedBox(height: 16),
            _buildOngoingCourses(),
            const SizedBox(height: 24),
            _buildSectionTitle('Examens à venir'),
            const SizedBox(height: 16),
            ExamsWidget(
              exams: [
                {
                  'title': 'Examen final de programmation',
                  'course': 'Introduction à la programmation',
                  'date': '15 juin 2023',
                  'duration': '2 heures',
                },
                {
                  'title': 'Test de mi-parcours',
                  'course': 'Mathématiques avancées',
                  'date': '22 juin 2023',
                  'duration': '1 heure 30',
                },
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Emploi du temps'),
            const SizedBox(height: 16),
            TimetableWidget(
              events: [
                {
                  'title': 'Cours de programmation',
                  'time': '10:00 - 12:00',
                  'date': 'Aujourd\'hui',
                  'type': 'course',
                },
                {
                  'title': 'Cours de mathématiques',
                  'time': '14:00 - 16:00',
                  'date': 'Aujourd\'hui',
                  'type': 'course',
                },
                {
                  'title': 'Remise de devoir',
                  'time': '23:59',
                  'date': 'Demain',
                  'type': 'assignment',
                },
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final authService = Provider.of<AuthService>(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ${authService.userName}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              authService.userEmail,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Navigation vers les notifications
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenue sur EduBridge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Votre plateforme d\'apprentissage en ligne',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('Cours', '3'),
              _buildStatCard('Examens', '2'),
              _buildStatCard('Devoirs', '5'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            // Navigation vers la vue complète
          },
          child: const Text('Voir tout'),
        ),
      ],
    );
  }

  Widget _buildOngoingCourses() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_courses.isEmpty) {
      return const Center(
        child: Text('Aucun cours en cours'),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return _buildCourseCard(course);
        },
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                course.subject,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Par ${course.teacherName}',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: course.progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(course.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.completedLessons}/${course.totalLessons} leçons',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourses() {
    return const Center(
      child: Text('Page des cours'),
    );
  }

  Widget _buildForum() {
    return const Center(
      child: Text('Page du forum'),
    );
  }

  Widget _buildCalendar() {
    return const Center(
      child: Text('Page du calendrier'),
    );
  }

  Widget _buildProfile() {
    final authService = Provider.of<AuthService>(context);
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ProfilePhotoWidget(
              photoUrl: null,
              name: authService.userName,
              size: 120,
              isEditable: true,
              onTap: () {
                // Logique pour changer la photo de profil
              },
            ),
            const SizedBox(height: 16),
            Text(
              authService.userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              authService.userEmail,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Étudiant',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Modifier le profil',
              onTap: () {
                // Navigation vers la page de modification du profil
              },
            ),
            _buildProfileMenuItem(
              icon: Icons.school_outlined,
              title: 'Mes cours',
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            _buildProfileMenuItem(
              icon: Icons.assignment_outlined,
              title: 'Mes devoirs',
              onTap: () {
                // Navigation vers la page des devoirs
              },
            ),
            _buildProfileMenuItem(
              icon: Icons.calendar_today_outlined,
              title: 'Mon emploi du temps',
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
            _buildProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                // Navigation vers la page des notifications
              },
            ),
            _buildProfileMenuItem(
              icon: Icons.settings_outlined,
              title: 'Paramètres',
              onTap: () {
                // Navigation vers la page des paramètres
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildProfileMenuItem(
              icon: Icons.logout,
              title: 'Déconnexion',
              onTap: () async {
                await authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              textColor: AppTheme.errorColor,
              iconColor: AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textSecondaryColor,
      ),
      onTap: onTap,
    );
  }
}

