import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';

class TimetableWidget extends StatelessWidget {
  final bool isTeacher;

  const TimetableWidget({
    Key? key,
    this.isTeacher = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Jours de la semaine
    final List<String> days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi'
    ];

    // Heures de cours
    final List<String> hours = [
      '8:00',
      '10:00',
      '12:00',
      '14:00',
      '16:00',
      '18:00'
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emploi du temps',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (isTeacher)
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddSessionDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Tableau d'emploi du temps
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    AppTheme.primaryColor.withOpacity(0.1),
                  ),
                  dataRowMaxHeight: 80,
                  columns: [
                    const DataColumn(
                      label: Text(
                        'Heures',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...days
                        .map((day) => DataColumn(
                              label: Text(
                                day,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                        .toList(),
                  ],
                  rows: hours.map((hour) {
                    return DataRow(
                      cells: [
                        DataCell(Text(hour)),
                        ...days
                            .map((day) => DataCell(
                                  _buildEmptyCell(context),
                                ))
                            .toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                isTeacher
                    ? 'Cliquez sur "Ajouter" pour planifier un cours'
                    : 'Votre emploi du temps sera affiché ici',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCell(BuildContext context) {
    return InkWell(
      onTap: isTeacher ? () => _showAddSessionDialog(context) : null,
      child: Container(
        height: 60,
        width: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Icon(
            isTeacher ? Icons.add_circle_outline : null,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  void _showAddSessionDialog(BuildContext context) {
    if (!isTeacher) return;

    final TextEditingController titleController = TextEditingController();
    final TextEditingController roomController = TextEditingController();
    String selectedDay = 'Lundi';
    String selectedTime = '8:00';

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
                decoration: const InputDecoration(
                  labelText: 'Jour',
                  border: OutlineInputBorder(),
                ),
                value: selectedDay,
                items: [
                  'Lundi',
                  'Mardi',
                  'Mercredi',
                  'Jeudi',
                  'Vendredi',
                  'Samedi'
                ]
                    .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedDay = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Heure',
                  border: OutlineInputBorder(),
                ),
                value: selectedTime,
                items: ['8:00', '10:00', '12:00', '14:00', '16:00', '18:00']
                    .map((time) => DropdownMenuItem(
                          value: time,
                          child: Text(time),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedTime = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roomController,
                decoration: const InputDecoration(
                  labelText: 'Salle',
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
              if (titleController.text.isNotEmpty) {
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
}
