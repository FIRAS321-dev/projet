import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ExamsWidget extends StatelessWidget {
  final bool isTeacher;

  const ExamsWidget({
    Key? key,
    required this.isTeacher,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Liste d'examens fictifs
    final exams = [
      {
        'title': 'Examen de Mathématiques',
        'date': DateTime.now().add(const Duration(days: 5)),
        'subject': 'Mathématiques',
        'duration': '2h',
      },
      {
        'title': 'Contrôle d\'Informatique',
        'date': DateTime.now().add(const Duration(days: 10)),
        'subject': 'Informatique',
        'duration': '1h30',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Examens à venir',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (isTeacher)
              TextButton.icon(
                onPressed: () {
                  // Naviguer vers la page de création d'examen
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        exams.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  return _buildExamCard(context, exam);
                },
              ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.event_note,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun examen à venir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isTeacher
                  ? 'Créez un nouvel examen pour vos étudiants'
                  : 'Vous n\'avez pas d\'examens prévus pour le moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            if (isTeacher) const SizedBox(height: 16),
            if (isTeacher)
              ElevatedButton.icon(
                onPressed: () {
                  // Naviguer vers la page de création d'examen
                },
                icon: const Icon(Icons.add),
                label: const Text('Créer un examen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Map<String, dynamic> exam) {
    final date = exam['date'] as DateTime;
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final daysLeft = date.difference(DateTime.now()).inDays;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam['title'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exam['subject'] as String,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Durée: ${exam['duration']}',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: daysLeft <= 3
                    ? Colors.red.withOpacity(0.1)
                    : daysLeft <= 7
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                daysLeft == 0
                    ? 'Aujourd\'hui'
                    : daysLeft == 1
                        ? 'Demain'
                        : 'Dans $daysLeft jours',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: daysLeft <= 3
                      ? Colors.red
                      : daysLeft <= 7
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

