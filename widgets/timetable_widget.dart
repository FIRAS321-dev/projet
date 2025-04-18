import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TimetableWidget extends StatefulWidget {
  final bool isTeacher;

  const TimetableWidget({
    Key? key,
    required this.isTeacher,
  }) : super(key: key);

  @override
  State<TimetableWidget> createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends State<TimetableWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    
    // Ajouter des événements fictifs
    _addFakeEvents();
  }

  void _addFakeEvents() {
    // Jour actuel
    final today = DateTime.now();
    
    // Créer une date sans l'heure pour la comparaison
    final normalizedToday = DateTime(today.year, today.month, today.day);
    
    // Ajouter des cours pour les 7 prochains jours
    for (int i = 0; i < 7; i++) {
      final day = normalizedToday.add(Duration(days: i));
      
      // Sauter les weekends
      if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
        continue;
      }
      
      // Ajouter 2-3 cours par jour
      final coursCount = 2 + (day.day % 2);
      final events = <Map<String, dynamic>>[];
      
      for (int j = 0; j < coursCount; j++) {
        final startHour = 8 + j * 2;
        events.add({
          'title': 'Cours de ${_getSubjectForDay(day.weekday, j)}',
          'start': DateTime(day.year, day.month, day.day, startHour, 0),
          'end': DateTime(day.year, day.month, day.day, startHour + 1, 30),
          'subject': _getSubjectForDay(day.weekday, j),
          'location': 'Salle ${100 + j}',
        });
      }
      
      _events[day] = events;
    }
  }

  String _getSubjectForDay(int weekday, int index) {
    final subjects = [
      'Mathématiques',
      'Informatique',
      'Physique',
      'Langues',
      'Développement Web',
      'Anglais',
      'Français',
      'STI',
    ];
    
    return subjects[(weekday + index) % subjects.length];
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Normaliser la date pour la comparaison (ignorer l'heure)
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                formatButtonTextStyle: TextStyle(
                  color: AppTheme.primaryColor,
                ),
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedDay != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cours du ${DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDay!)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (widget.isTeacher)
                TextButton.icon(
                  onPressed: () {
                    // Naviguer vers la page d'ajout de cours
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEventsList(),
        ],
      ],
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDay!);
    
    if (events.isEmpty) {
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
                  Icons.event_busy,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucun cours ce jour',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isTeacher
                    ? 'Vous n\'avez pas de cours à donner ce jour'
                    : 'Vous n\'avez pas de cours à suivre ce jour',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              if (widget.isTeacher) const SizedBox(height: 16),
              if (widget.isTeacher)
                ElevatedButton.icon(
                  onPressed: () {
                    // Naviguer vers la page d'ajout de cours
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un cours'),
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
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index] as Map<String, dynamic>;
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final startTime = event['start'] as DateTime;
    final endTime = event['end'] as DateTime;
    final formattedStartTime = DateFormat('HH:mm').format(startTime);
    final formattedEndTime = DateFormat('HH:mm').format(endTime);
    
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formattedStartTime,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Icon(
                      Icons.arrow_downward,
                      size: 16,
                    ),
                  ),
                  Text(
                    formattedEndTime,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                    event['title'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.subject,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event['subject'] as String,
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event['location'] as String,
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.isTeacher)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  // Gérer les actions
                  if (value == 'edit') {
                    // Modifier le cours
                  } else if (value == 'delete') {
                    // Supprimer le cours
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
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

