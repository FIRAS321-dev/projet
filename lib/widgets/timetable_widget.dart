import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';

class TimetableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const TimetableWidget({
    Key? key,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Emploi du temps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigation vers l'écran d'emploi du temps complet
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          events.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Aucun événement à venir',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length > 3 ? 3 : events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _EventCard(
                      title: event['title'],
                      time: event['time'],
                      date: event['date'],
                      color: _getColorForEventType(event['type']),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Color _getColorForEventType(String type) {
    switch (type) {
      case 'course':
        return AppTheme.primaryColor;
      case 'exam':
        return AppTheme.errorColor;
      case 'assignment':
        return AppTheme.warningColor;
      default:
        return AppTheme.secondaryColor;
    }
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String time;
  final String date;
  final Color color;

  const _EventCard({
    Key? key,
    required this.title,
    required this.time,
    required this.date,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date • $time',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.textSecondaryColor,
          ),
        ],
      ),
    );
  }
}

