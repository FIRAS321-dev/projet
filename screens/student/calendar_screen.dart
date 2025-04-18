import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Sample events
  final Map<DateTime, List<String>> _events = {
    DateTime.now(): ['Cours de Mathématiques', 'Devoir de Physique à rendre'],
    DateTime.now().add(const Duration(days: 1)): ['Examen d\'Informatique'],
    DateTime.now().add(const Duration(days: 3)): ['Cours d\'Anglais', 'Réunion de groupe'],
    DateTime.now().add(const Duration(days: 7)): ['Présentation de projet'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
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
              markerDecoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonShowsNext: false,
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              formatButtonTextStyle: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDay == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sélectionnez une date pour voir les événements',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _buildEventsList(_getEventsForDay(_selectedDay!)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventsList(List<String> events) {
    return events.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.event_available,
                  size: 64,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun événement pour cette date',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    event,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Show event options
                    },
                  ),
                ),
              );
            },
          );
  }

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController eventController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un événement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Date: ${_selectedDay != null ? '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}' : 'Sélectionnez une date'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: eventController,
              decoration: const InputDecoration(
                labelText: 'Événement',
                hintText: 'Entrez le nom de l\'événement',
                prefixIcon: Icon(Icons.event),
              ),
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
              // Add event logic
              if (_selectedDay != null && eventController.text.isNotEmpty) {
                setState(() {
                  final day = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                  if (_events.containsKey(day)) {
                    _events[day]!.add(eventController.text);
                  } else {
                    _events[day] = [eventController.text];
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

