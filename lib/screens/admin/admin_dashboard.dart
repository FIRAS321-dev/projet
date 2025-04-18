import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:edubridge/widgets/custom_button.dart';
import 'package:edubridge/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:edubridge/services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  // Statistiques vides
  final Map<String, int> _stats = {
    'Utilisateurs': 0,
    'Étudiants': 0,
    'Enseignants': 0,
    'Administrateurs': 0,
    'Cours': 0,
    'Leçons': 0,
  };

  // Listes vides
  final List<Map<String, dynamic>> _users = [];
  final List<Map<String, dynamic>> _courses = [];
  final List<Map<String, dynamic>> _activities = [];
  final List<Map<String, dynamic>> _interactions = [];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userName = authService.userName ?? 'Administrateur';

    return Scaffold(
      appBar: AppBar(
        title: const Text('EduBridge Admin'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      drawer: _buildAdminDrawer(userName),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1 || _currentIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                if (_currentIndex == 1) {
                  _showAddUserDialog();
                } else if (_currentIndex == 2) {
                  _showAddCourseDialog();
                }
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildAdminDrawer(String userName) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 30,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Administrateur',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Tableau de bord',
              index: 0,
            ),
            _buildDrawerItem(
              icon: Icons.people,
              title: 'Gestion des utilisateurs',
              index: 1,
            ),
            _buildDrawerItem(
              icon: Icons.book,
              title: 'Gestion des cours',
              index: 2,
            ),
            _buildDrawerItem(
              icon: Icons.forum,
              title: 'Forums',
              index: -1,
              onTap: () {
                // Naviguer vers la gestion des forums
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir'),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.analytics,
              title: 'Statistiques avancées',
              index: -1,
              onTap: () {
                // Naviguer vers les statistiques avancées
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir'),
                  ),
                );
              },
            ),
            // Nouvel élément pour surveiller les interactions
            _buildDrawerItem(
              icon: Icons.visibility,
              title: 'Surveillance des interactions',
              index: 4,
              onTap: () {
                setState(() {
                  _currentIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(color: Colors.grey),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Paramètres',
              index: 3,
            ),
            _buildDrawerItem(
              icon: Icons.help_outline,
              title: 'Aide et support',
              index: -1,
              onTap: () {
                // Naviguer vers l'aide et le support
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir'),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Déconnexion',
              index: -1,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    VoidCallback? onTap,
  }) {
    final isSelected = index == _currentIndex;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.white70,
        ),
      ),
      onTap: onTap ??
          () {
            setState(() {
              _currentIndex = index;
            });
            Navigator.pop(context);
          },
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildUsersTab();
      case 2:
        return _buildCoursesTab();
      case 3:
        return _buildSettingsTab();
      case 4:
        return _buildInteractionsTab(); // Nouvel onglet pour les interactions
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Text(
            'Tableau de bord administrateur',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Vue d\'ensemble de la plateforme EduBridge',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Statistiques
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _stats.entries.map((entry) {
              return _buildStatCard(
                title: entry.key,
                value: entry.value.toString(),
                icon: _getStatIcon(entry.key),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Activités récentes
          Text(
            'Activités récentes',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          _activities.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.history,
                            size: 48,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune activité récente',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Les activités des utilisateurs apparaîtront ici',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _activities.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final activity = _activities[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppTheme.primaryColor.withOpacity(0.1),
                          child: Text(
                            activity['user'][0],
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text: activity['user'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' ${activity['action']} '),
                              TextSpan(
                                text: activity['target'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Text(activity['time']),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            // Afficher les détails de l'activité
                          },
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 24),

          // Actions rapides
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Ajouter un utilisateur',
                  icon: Icons.person_add,
                  onTap: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                    _showAddUserDialog();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  title: 'Ajouter un cours',
                  icon: Icons.add_box,
                  onTap: () {
                    setState(() {
                      _currentIndex = 2;
                    });
                    _showAddCourseDialog();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Gérer les forums',
                  icon: Icons.forum,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité à venir'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  title: 'Voir les interactions',
                  icon: Icons.visibility,
                  onTap: () {
                    setState(() {
                      _currentIndex = 4;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un utilisateur...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) {
              // Filtrer les utilisateurs
            },
          ),
        ),

        // Filtres
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              DropdownButton<String>(
                value: 'Tous',
                items: ['Tous', 'Étudiants', 'Enseignants', 'Administrateurs']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Filtrer par type d'utilisateur
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: 'Actif',
                items: ['Tous', 'Actif', 'Inactif'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Filtrer par statut
                },
              ),
            ],
          ),
        ),

        // Liste des utilisateurs
        Expanded(
          child: _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 64,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun utilisateur trouvé',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ajoutez des utilisateurs en utilisant le bouton +',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getUserTypeColor(user['type']),
                          child: Text(
                            user['name'][0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(user['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['email']),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getUserTypeColor(user['type'])
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getUserTypeLabel(user['type']),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getUserTypeColor(user['type']),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user['status'] == 'Actif'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    user['status'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: user['status'] == 'Actif'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditUserDialog(user);
                            } else if (value == 'delete') {
                              _showDeleteUserDialog(user);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Modifier'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Supprimer',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCoursesTab() {
    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un cours...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) {
              // Filtrer les cours
            },
          ),
        ),

        // Filtres
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              DropdownButton<String>(
                value: 'Tous',
                items: [
                  'Tous',
                  'Mathématiques',
                  'Informatique',
                  'Physique',
                  'Langues'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Filtrer par matière
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: 'Actif',
                items: ['Tous', 'Actif', 'Inactif'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Filtrer par statut
                },
              ),
            ],
          ),
        ),

        // Liste des cours
        Expanded(
          child: _courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun cours trouvé',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ajoutez des cours en utilisant le bouton +',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _getSubjectColor(course['subject'])
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getSubjectIcon(course['subject']),
                                    color: _getSubjectColor(course['subject']),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course['title'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        course['subject'],
                                        style: TextStyle(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditCourseDialog(course);
                                    } else if (value == 'delete') {
                                      _showDeleteCourseDialog(course);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Modifier'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              size: 18, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Supprimer',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildCourseInfoItem(
                                  icon: Icons.person,
                                  label: 'Enseignant',
                                  value: course['teacher'],
                                ),
                                _buildCourseInfoItem(
                                  icon: Icons.people,
                                  label: 'Étudiants',
                                  value: course['students'].toString(),
                                ),
                                _buildCourseInfoItem(
                                  icon: Icons.calendar_today,
                                  label: 'Créé le',
                                  value: course['createdDate'],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: course['status'] == 'Actif'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    course['status'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: course['status'] == 'Actif'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                OutlinedButton(
                                  onPressed: () {
                                    // Voir les détails du cours
                                  },
                                  child: const Text('Détails'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // Gérer le cours
                                  },
                                  child: const Text('Gérer'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Nouvel onglet pour surveiller les interactions
  Widget _buildInteractionsTab() {
    return Column(
      children: [
        // En-tête
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Surveillance des interactions',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Suivez les interactions entre étudiants et enseignants',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        // Filtres
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              DropdownButton<String>(
                value: 'Tous',
                items: ['Tous', 'Messages', 'Questions', 'Réponses']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Filtrer par type d'interaction
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: 'Tous',
                items: ['Tous', 'Aujourd\'hui', 'Cette semaine', 'Ce mois']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Filtrer par période
                },
              ),
            ],
          ),
        ),

        // Liste des interactions
        Expanded(
          child: _interactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune interaction trouvée',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Les interactions entre étudiants et enseignants apparaîtront ici',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _interactions.length,
                  itemBuilder: (context, index) {
                    final interaction = _interactions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _getInteractionTypeColor(interaction['type']),
                          child: Icon(
                            _getInteractionTypeIcon(interaction['type']),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text: interaction['from'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' ${interaction['action']} '),
                              TextSpan(
                                text: interaction['to'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(interaction['content']),
                            Text(
                              interaction['time'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            _showInteractionDetailsDialog(interaction);
                          },
                        ),
                        onTap: () {
                          _showInteractionDetailsDialog(interaction);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres de la plateforme',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 24),

          // Paramètres généraux
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paramètres généraux',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),

                  // Nom de la plateforme
                  _buildSettingsItem(
                    title: 'Nom de la plateforme',
                    subtitle: 'EduBridge',
                    icon: Icons.business,
                    onTap: () {
                      // Modifier le nom de la plateforme
                      _showEditSettingDialog(
                        title: 'Nom de la plateforme',
                        currentValue: 'EduBridge',
                      );
                    },
                  ),
                  const Divider(),

                  // Langue par défaut
                  _buildSettingsItem(
                    title: 'Langue par défaut',
                    subtitle: 'Français',
                    icon: Icons.language,
                    onTap: () {
                      // Modifier la langue par défaut
                      _showLanguageSelectionDialog();
                    },
                  ),
                  const Divider(),

                  // Fuseau horaire
                  _buildSettingsItem(
                    title: 'Fuseau horaire',
                    subtitle: 'Europe/Paris (UTC+1)',
                    icon: Icons.access_time,
                    onTap: () {
                      // Modifier le fuseau horaire
                      _showTimezoneSelectionDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Paramètres d'inscription
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paramètres d\'inscription',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),

                  // Inscription ouverte
                  _buildSwitchSettingsItem(
                    title: 'Inscription ouverte',
                    subtitle:
                        'Permettre aux nouveaux utilisateurs de s\'inscrire',
                    icon: Icons.app_registration,
                    value: true,
                    onChanged: (value) {
                      // Activer/désactiver l'inscription
                    },
                  ),
                  const Divider(),

                  // Validation par email
                  _buildSwitchSettingsItem(
                    title: 'Validation par email',
                    subtitle:
                        'Exiger une validation par email lors de l\'inscription',
                    icon: Icons.email,
                    value: true,
                    onChanged: (value) {
                      // Activer/désactiver la validation par email
                    },
                  ),
                  const Divider(),

                  // Approbation manuelle
                  _buildSwitchSettingsItem(
                    title: 'Approbation manuelle',
                    subtitle:
                        'Les nouveaux comptes doivent être approuvés par un administrateur',
                    icon: Icons.admin_panel_settings,
                    value: false,
                    onChanged: (value) {
                      // Activer/désactiver l'approbation manuelle
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Paramètres de sécurité
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paramètres de sécurité',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),

                  // Authentification à deux facteurs
                  _buildSwitchSettingsItem(
                    title: 'Authentification à deux facteurs',
                    subtitle:
                        'Exiger l\'authentification à deux facteurs pour tous les utilisateurs',
                    icon: Icons.security,
                    value: false,
                    onChanged: (value) {
                      // Activer/désactiver l'authentification à deux facteurs
                    },
                  ),
                  const Divider(),

                  // Politique de mot de passe
                  _buildSettingsItem(
                    title: 'Politique de mot de passe',
                    subtitle: 'Minimum 6 caractères',
                    icon: Icons.password,
                    onTap: () {
                      // Modifier la politique de mot de passe
                      _showPasswordPolicyDialog();
                    },
                  ),
                  const Divider(),

                  // Durée de session
                  _buildSettingsItem(
                    title: 'Durée de session',
                    subtitle: '24 heures',
                    icon: Icons.timer,
                    onTap: () {
                      // Modifier la durée de session
                      _showSessionDurationDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sauvegarder les paramètres
          CustomButton(
            text: 'Sauvegarder les paramètres',
            icon: Icons.save,
            onPressed: () {
              // Sauvegarder les paramètres
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paramètres sauvegardés avec succès!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchSettingsItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  IconData _getStatIcon(String stat) {
    switch (stat) {
      case 'Utilisateurs':
        return Icons.people;
      case 'Étudiants':
        return Icons.school;
      case 'Enseignants':
        return Icons.person;
      case 'Administrateurs':
        return Icons.admin_panel_settings;
      case 'Cours':
        return Icons.book;
      case 'Leçons':
        return Icons.menu_book;
      default:
        return Icons.info;
    }
  }

  Color _getUserTypeColor(String type) {
    switch (type) {
      case 'admin':
        return Colors.red;
      case 'teacher':
        return Colors.blue;
      case 'student':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getUserTypeLabel(String type) {
    switch (type) {
      case 'admin':
        return 'Administrateur';
      case 'teacher':
        return 'Enseignant';
      case 'student':
        return 'Étudiant';
      default:
        return 'Inconnu';
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Mathématiques':
        return Colors.blue;
      case 'Informatique':
        return Colors.green;
      case 'Physique':
        return Colors.orange;
      case 'Langues':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Mathématiques':
        return Icons.calculate;
      case 'Informatique':
        return Icons.computer;
      case 'Physique':
        return Icons.science;
      case 'Langues':
        return Icons.language;
      default:
        return Icons.book;
    }
  }

  // Nouvelles méthodes pour les interactions
  Color _getInteractionTypeColor(String type) {
    switch (type) {
      case 'message':
        return Colors.blue;
      case 'question':
        return Colors.orange;
      case 'answer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getInteractionTypeIcon(String type) {
    switch (type) {
      case 'message':
        return Icons.message;
      case 'question':
        return Icons.help;
      case 'answer':
        return Icons.question_answer;
      default:
        return Icons.chat;
    }
  }

  void _showInteractionDetailsDialog(Map<String, dynamic> interaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de l\'interaction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        _getInteractionTypeColor(interaction['type']),
                    child: Icon(
                      _getInteractionTypeIcon(interaction['type']),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          interaction['from'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          interaction['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Contenu:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(interaction['content']),
              ),
              if (interaction['response'] != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Réponse:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(interaction['response']),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    String selectedType = 'student';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un utilisateur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type d\'utilisateur',
                  border: OutlineInputBorder(),
                ),
                items: ['student', 'teacher', 'admin'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(_getUserTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedType = newValue;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                // Ajouter l'utilisateur
                setState(() {
                  _users.add({
                    'id': (_users.length + 1).toString(),
                    'name': nameController.text,
                    'email': emailController.text,
                    'type': selectedType,
                    'status': 'Actif',
                    'joinDate': DateTime.now().toString().split(' ')[0],
                  });
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Utilisateur ajouté avec succès!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final TextEditingController nameController =
        TextEditingController(text: user['name']);
    final TextEditingController emailController =
        TextEditingController(text: user['email']);
    String selectedType = user['type'];
    String selectedStatus = user['status'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'utilisateur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type d\'utilisateur',
                  border: OutlineInputBorder(),
                ),
                items: ['student', 'teacher', 'admin'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(_getUserTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedType = newValue;
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: ['Actif', 'Inactif'].map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedStatus = newValue;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                // Modifier l'utilisateur
                setState(() {
                  final index = _users.indexWhere((u) => u['id'] == user['id']);
                  if (index != -1) {
                    _users[index] = {
                      'id': user['id'],
                      'name': nameController.text,
                      'email': emailController.text,
                      'type': selectedType,
                      'status': selectedStatus,
                      'joinDate': user['joinDate'],
                    };
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Utilisateur modifié avec succès!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'utilisateur'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer l\'utilisateur ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Supprimer l'utilisateur
              setState(() {
                _users.removeWhere((u) => u['id'] == user['id']);
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Utilisateur supprimé avec succès!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showAddCourseDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController teacherController = TextEditingController();
    String selectedSubject = 'Mathématiques';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un cours'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du cours',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Matière',
                  border: OutlineInputBorder(),
                ),
                items: ['Mathématiques', 'Informatique', 'Physique', 'Langues']
                    .map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedSubject = newValue;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: teacherController,
                decoration: const InputDecoration(
                  labelText: 'Enseignant',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  teacherController.text.isNotEmpty) {
                // Ajouter le cours
                setState(() {
                  _courses.add({
                    'id': (_courses.length + 1).toString(),
                    'title': titleController.text,
                    'subject': selectedSubject,
                    'teacher': teacherController.text,
                    'students': 0,
                    'status': 'Actif',
                    'createdDate': DateTime.now().toString().split(' ')[0],
                  });
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cours ajouté avec succès!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(Map<String, dynamic> course) {
    final TextEditingController titleController =
        TextEditingController(text: course['title']);
    final TextEditingController teacherController =
        TextEditingController(text: course['teacher']);
    String selectedSubject = course['subject'];
    String selectedStatus = course['status'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le cours'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du cours',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Matière',
                  border: OutlineInputBorder(),
                ),
                items: ['Mathématiques', 'Informatique', 'Physique', 'Langues']
                    .map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedSubject = newValue;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: teacherController,
                decoration: const InputDecoration(
                  labelText: 'Enseignant',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: ['Actif', 'Inactif'].map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedStatus = newValue;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  teacherController.text.isNotEmpty) {
                // Modifier le cours
                setState(() {
                  final index =
                      _courses.indexWhere((c) => c['id'] == course['id']);
                  if (index != -1) {
                    _courses[index] = {
                      'id': course['id'],
                      'title': titleController.text,
                      'subject': selectedSubject,
                      'teacher': teacherController.text,
                      'students': course['students'],
                      'status': selectedStatus,
                      'createdDate': course['createdDate'],
                    };
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cours modifié avec succès!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCourseDialog(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le cours'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer le cours ${course['title']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Supprimer le cours
              setState(() {
                _courses.removeWhere((c) => c['id'] == course['id']);
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cours supprimé avec succès!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showEditSettingDialog({
    required String title,
    required String currentValue,
  }) {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title modifié avec succès!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner la langue par défaut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              leading: Radio<String>(
                value: 'Français',
                groupValue: 'Français',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'English',
                groupValue: 'Français',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Español'),
              leading: Radio<String>(
                value: 'Español',
                groupValue: 'Français',
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Langue modifiée avec succès!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showTimezoneSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner le fuseau horaire'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Europe/Paris (UTC+1)'),
              leading: Radio<String>(
                value: 'Europe/Paris',
                groupValue: 'Europe/Paris',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('America/New_York (UTC-5)'),
              leading: Radio<String>(
                value: 'America/New_York',
                groupValue: 'Europe/Paris',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Asia/Tokyo (UTC+9)'),
              leading: Radio<String>(
                value: 'Asia/Tokyo',
                groupValue: 'Europe/Paris',
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fuseau horaire modifié avec succès!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showPasswordPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Politique de mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Longueur minimale'),
              subtitle: const Text('6 caractères'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
            ),
            ListTile(
              title: const Text('Exiger une majuscule'),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
                activeColor: AppTheme.primaryColor,
              ),
            ),
            ListTile(
              title: const Text('Exiger un chiffre'),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
                activeColor: AppTheme.primaryColor,
              ),
            ),
            ListTile(
              title: const Text('Exiger un caractère spécial'),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
                activeColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Politique de mot de passe modifiée avec succès!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showSessionDurationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durée de session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('1 heure'),
              leading: Radio<String>(
                value: '1 heure',
                groupValue: '24 heures',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('8 heures'),
              leading: Radio<String>(
                value: '8 heures',
                groupValue: '24 heures',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('24 heures'),
              leading: Radio<String>(
                value: '24 heures',
                groupValue: '24 heures',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('7 jours'),
              leading: Radio<String>(
                value: '7 jours',
                groupValue: '24 heures',
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Durée de session modifiée avec succès!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.signOut();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
