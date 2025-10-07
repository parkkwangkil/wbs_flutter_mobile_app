import 'dart:async';
import 'package:flutter/material.dart';

import '../services/notification_manager.dart';

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> get notifications => NotificationManager.notifications;
  int get unreadCount => NotificationManager.unreadCount;

  @override
  void dispose() {
    super.dispose();
  }

  // NotificationManager의 메서드들을 래핑
  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
    String? payload,
    DateTime? scheduledTime,
    bool sendEmail = false,
    String? emailTo,
  }) async {
    await NotificationManager.addNotification(
      title: title,
      body: body,
      type: type,
      payload: payload,
      scheduledTime: scheduledTime,
      sendEmail: sendEmail,
      emailTo: emailTo,
    );
    notifyListeners();
  }

  Future<void> sendProjectNotification({
    required String projectName,
    required String message,
  }) async {
    await NotificationManager.sendProjectNotification(
      projectName: projectName,
      action: '업데이트',
      message: message,
    );
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    NotificationManager.markAsRead(notificationId);
    notifyListeners();
  }

  void markAllAsRead() {
    NotificationManager.markAllAsRead();
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    NotificationManager.deleteNotification(notificationId);
    notifyListeners();
  }
  
  void clearAllNotifications() {
    NotificationManager.deleteAllNotifications();
    notifyListeners();
  }
}
