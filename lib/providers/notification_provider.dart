import 'dart:async';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/email_service.dart';
import '../services/notification_settings.dart'; // Stream 기반의 새 서비스 import

class NotificationProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _notifications = [];
  
  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !(n['isRead'] as bool)).length;

  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
    String? payload,
    DateTime? scheduledTime,
    bool sendEmail = false,
    String? emailTo,
  }) async {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch, 'title': title, 'body': body,
      'type': type, 'payload': payload, 'createdAt': DateTime.now(), 'isRead': false,
    };
    _notifications.insert(0, notification);
    notifyListeners();

    // 새로운 NotificationSettings 클래스의 static getter를 사용하여 설정 확인
    if (NotificationSettings.pushNotifications) {
      if (scheduledTime != null) {
        await NotificationService.scheduleNotification(
          id: notification['id'] as int,
          title: title,
          body: body,
          scheduledDate: scheduledTime,
          payload: payload,
        );
      } else {
        await NotificationService.showNotification(
          id: notification['id'] as int,
          title: title,
          body: body,
          payload: payload,
        );
      }
    }
    if (sendEmail && emailTo != null && NotificationSettings.emailNotifications) {
       await EmailService.sendEmail(
        to: emailTo,
        subject: title,
        body: body,
      );
    }
  }

  Future<void> sendProjectNotification({
    required String projectName,
    required String message,
  }) async {
    // 새로운 NotificationSettings 클래스의 static getter를 사용하여 설정 확인
    if (!NotificationSettings.projectUpdates) return;
    await addNotification(
      title: '프로젝트: $projectName',
      body: message,
      type: 'project',
    );
  }

  void markAsRead(int notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n['isRead'] = true;
    }
    notifyListeners();
  }

  void deleteNotification(int notificationId) {
    _notifications.removeWhere((n) => n['id'] == notificationId);
    notifyListeners();
  }
  
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
