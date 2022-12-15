import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationService {
  void init(Future<dynamic> Function(int, String?, String?, String?)? onDidReceive);
  Future selectNotification(String? payload);
  void cancelAllNotifications();
  void handleApplicationWasLaunchedFromNotification(String payload);
  Future<List<PendingNotificationRequest>> getAllScheduledNotifications();
}