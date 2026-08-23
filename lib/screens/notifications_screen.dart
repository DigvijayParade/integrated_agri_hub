import 'package:flutter/material.dart';
import '../models/app_notification.dart';

class NotificationsScreen extends StatefulWidget {
  final List<AppNotification> notifications;
  final VoidCallback onNotificationsRead;

  const NotificationsScreen({
    super.key,
    required this.notifications,
    required this.onNotificationsRead,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Notifications', style: TextStyle(color: Color(0xFF2A5934), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A5934)),
          onPressed: () {
            widget.onNotificationsRead();
            Navigator.pop(context);
          },
        ),
      ),
      body: widget.notifications.isEmpty
          ? const Center(child: Text('No new notifications.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.notifications.length,
              itemBuilder: (context, index) {
                final notif = widget.notifications[index];
                IconData icon;
                Color iconColor;
                
                if (notif.category == 'Market') {
                  icon = Icons.trending_up;
                  iconColor = Colors.orange;
                } else if (notif.category == 'Schedule') {
                  icon = Icons.calendar_today;
                  iconColor = Colors.blue;
                } else {
                  icon = Icons.notifications;
                  iconColor = const Color(0xFF4A7C59);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: notif.isRead ? Colors.white : const Color(0xFFF0F5E8),
                    borderRadius: BorderRadius.circular(12),
                    border: notif.isRead ? null : Border.all(color: const Color(0xFF4A7C59).withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                    ]
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: iconColor.withValues(alpha: 0.2),
                      child: Icon(icon, color: iconColor),
                    ),
                    title: Text(
                      notif.title, 
                      style: TextStyle(
                        fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                        color: const Color(0xFF2A5934)
                      )
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notif.message, style: const TextStyle(color: Colors.black87)),
                        const SizedBox(height: 8),
                        Text(
                          _formatTime(notif.time),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      setState(() {
                        notif.isRead = true;
                      });
                    },
                  ),
                );
              },
            ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}
