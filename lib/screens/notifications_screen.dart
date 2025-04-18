import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:edubridge/models/notification_model.dart';
import 'package:edubridge/widgets/notification_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Sample data
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      title: 'Nouveau cours disponible',
      message: 'Le cours de Calcul différentiel est maintenant disponible',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Rappel: Devoir à rendre',
      message: 'N\'oubliez pas de rendre votre devoir de Physique avant demain',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: '3',
      title: 'Réponse à votre question',
      message: 'Prof. Johnson a répondu à votre question sur Python',
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      title: 'Nouveau message',
      message: 'Vous avez reçu un nouveau message de Sophie Martin',
      time: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
    NotificationModel(
      id: '5',
      title: 'Quiz noté',
      message:
          'Votre quiz d\'Algèbre linéaire a été noté. Vous avez obtenu 85%',
      time: DateTime.now().subtract(const Duration(days: 4)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tout marquer comme lu',
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification.isRead = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Toutes les notifications ont été marquées comme lues'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'avez pas de notifications pour le moment',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    // Group notifications by date
    final Map<String, List<NotificationModel>> groupedNotifications = {};

    for (var notification in _notifications) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final notificationDate = DateTime(
        notification.time.year,
        notification.time.month,
        notification.time.day,
      );

      String group;
      if (notificationDate == today) {
        group = 'Aujourd\'hui';
      } else if (notificationDate == yesterday) {
        group = 'Hier';
      } else {
        group = 'Plus ancien';
      }

      if (!groupedNotifications.containsKey(group)) {
        groupedNotifications[group] = [];
      }

      groupedNotifications[group]!.add(notification);
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Unread count
        if (_notifications.any((n) => !n.isRead))
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              '${_notifications.where((n) => !n.isRead).length} non lues',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),

        // Grouped notifications
        for (var group in groupedNotifications.keys)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  group,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
              ...groupedNotifications[group]!.map((notification) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Supprimer la notification'),
                            content: const Text(
                                'Êtes-vous sûr de vouloir supprimer cette notification?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        setState(() {
                          _notifications
                              .removeWhere((n) => n.id == notification.id);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification supprimée'),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        );
                      },
                    ),
                    child: NotificationCard(
                      notification: notification,
                      onTap: () {
                        setState(() {
                          notification.isRead = true;
                        });
                        // Navigate to relevant screen based on notification type
                      },
                    ),
                  )),
            ],
          ),
      ],
    );
  }
}
