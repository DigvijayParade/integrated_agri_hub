class AppNotification {
  final String title;
  final String message;
  final String category; // 'Market', 'Schedule', 'Alert'
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.title,
    required this.message,
    required this.category,
    required this.time,
    this.isRead = false,
  });
}
