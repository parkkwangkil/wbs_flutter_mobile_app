import 'dart:async';
import 'notification_service.dart';
import 'email_service.dart';
import 'notification_settings.dart';

class NotificationManager {
  static final List<Map<String, dynamic>> _notifications = [];
  static final StreamController<List<Map<String, dynamic>>> _notificationController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();

  static Stream<List<Map<String, dynamic>>> get notificationStream => _notificationController.stream;
  static List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);

  // 알림 초기화
  static Future<void> initialize() async {
    await NotificationService.initialize();
    await NotificationSettings.initialize();
  }

  // 알림 추가
  static Future<void> addNotification({
    required String title,
    required String body,
    required String type,
    String? payload,
    DateTime? scheduledTime,
    bool sendEmail = false,
    String? emailTo,
  }) async {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'type': type,
      'payload': payload,
      'scheduledTime': scheduledTime ?? DateTime.now(),
      'isRead': false,
      'createdAt': DateTime.now(),
    };

    _notifications.insert(0, notification);
    _notificationController.add(List.unmodifiable(_notifications));

    // 푸시 알림 전송
    if (NotificationSettings.pushNotifications) {
      if (scheduledTime != null) {
        await NotificationService.scheduleNotification(
          id: int.parse(notification['id']),
          title: title,
          body: body,
          scheduledDate: scheduledTime,
          payload: payload,
        );
      } else {
        await NotificationService.showNotification(
          id: int.parse(notification['id']),
          title: title,
          body: body,
          payload: payload,
        );
      }
    }

    // 이메일 알림 전송
    if (sendEmail && emailTo != null && NotificationSettings.emailNotifications) {
      await EmailService.sendEmail(
        to: emailTo,
        subject: title,
        body: body,
      );
    }
  }

  // 프로젝트 알림
  static Future<void> sendProjectNotification({
    required String projectName,
    required String action,
    required String message,
    String? projectUrl,
    String? emailTo,
  }) async {
    if (!NotificationSettings.projectUpdates) return;

    final title = '프로젝트 알림: $projectName';
    final body = '$action: $message';

    await addNotification(
      title: title,
      body: body,
      type: 'project',
      payload: projectUrl,
      sendEmail: emailTo != null,
      emailTo: emailTo,
    );
  }

  // 이벤트 알림
  static Future<void> sendEventNotification({
    required String eventName,
    required DateTime eventDate,
    required String location,
    required String message,
    String? emailTo,
  }) async {
    if (!NotificationSettings.eventReminders) return;

    final title = '이벤트 알림: $eventName';
    final body = '${eventDate.toString().split(' ')[0]} $location: $message';

    await addNotification(
      title: title,
      body: body,
      type: 'event',
      sendEmail: emailTo != null,
      emailTo: emailTo,
    );
  }

  // 팀 알림
  static Future<void> sendTeamNotification({
    required String teamName,
    required String action,
    required String message,
    String? emailTo,
  }) async {
    if (!NotificationSettings.teamNotifications) return;

    final title = '팀 알림: $teamName';
    final body = '$action: $message';

    await addNotification(
      title: title,
      body: body,
      type: 'team',
      sendEmail: emailTo != null,
      emailTo: emailTo,
    );
  }

  // 시스템 알림
  static Future<void> sendSystemNotification({
    required String title,
    required String message,
    String? emailTo,
  }) async {
    if (!NotificationSettings.systemAlerts) return;

    await addNotification(
      title: title,
      body: message,
      type: 'system',
      sendEmail: emailTo != null,
      emailTo: emailTo,
    );
  }

  // 마일스톤 알림
  static Future<void> sendMilestoneNotification({
    required String projectName,
    required String milestoneName,
    required String action,
    String? emailTo,
  }) async {
    if (!NotificationSettings.milestoneAlerts) return;

    final title = '마일스톤 알림: $projectName';
    final body = '$milestoneName: $action';

    await addNotification(
      title: title,
      body: body,
      type: 'milestone',
      sendEmail: emailTo != null,
      emailTo: emailTo,
    );
  }

  // 마감일 경고
  static Future<void> sendDeadlineWarning({
    required String itemName,
    required DateTime deadline,
    required String type,
    String? emailTo,
  }) async {
    if (!NotificationSettings.deadlineWarnings) return;

    final daysLeft = deadline.difference(DateTime.now()).inDays;
    final title = '마감일 경고: $itemName';
    final body = '${deadline.toString().split(' ')[0]}까지 $daysLeft일 남았습니다.';

    await addNotification(
      title: title,
      body: body,
      type: 'deadline',
      sendEmail: emailTo != null,
      emailTo: emailTo,
    );
  }

  // 일일 요약
  static Future<void> sendDailySummary({
    required List<Map<String, dynamic>> projects,
    required List<Map<String, dynamic>> events,
    required String emailTo,
  }) async {
    if (!NotificationSettings.dailySummary) return;

    final title = '일일 요약 - ${DateTime.now().toString().split(' ')[0]}';
    final body = '프로젝트 ${projects.length}개, 이벤트 ${events.length}개';

    await addNotification(
      title: title,
      body: body,
      type: 'daily_summary',
      sendEmail: true,
      emailTo: emailTo,
    );
  }

  // 주간 요약
  static Future<void> sendWeeklySummary({
    required List<Map<String, dynamic>> completedProjects,
    required List<Map<String, dynamic>> upcomingEvents,
    required String emailTo,
  }) async {
    if (!NotificationSettings.weeklySummary) return;

    final title = '주간 요약 - ${DateTime.now().toString().split(' ')[0]}';
    final body = '완료된 프로젝트 ${completedProjects.length}개, 예정된 이벤트 ${upcomingEvents.length}개';

    await addNotification(
      title: title,
      body: body,
      type: 'weekly_summary',
      sendEmail: true,
      emailTo: emailTo,
    );
  }

  // 알림 읽음 처리
  static void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      _notificationController.add(List.unmodifiable(_notifications));
    }
  }

  // 모든 알림 읽음 처리
  static void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _notificationController.add(List.unmodifiable(_notifications));
  }

  // 알림 삭제
  static void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n['id'] == notificationId);
    _notificationController.add(List.unmodifiable(_notifications));
  }

  // 모든 알림 삭제
  static void deleteAllNotifications() {
    _notifications.clear();
    _notificationController.add(List.unmodifiable(_notifications));
  }

  // 읽지 않은 알림 수
  static int get unreadCount {
    return _notifications.where((n) => !n['isRead']).length;
  }

  // 타입별 알림 수
  static int getNotificationCountByType(String type) {
    return _notifications.where((n) => n['type'] == type).length;
  }

  // 알림 통계
  static Map<String, dynamic> getNotificationStats() {
    final total = _notifications.length;
    final unread = unreadCount;
    final byType = <String, int>{};
    
    for (final notification in _notifications) {
      final type = notification['type'] as String;
      byType[type] = (byType[type] ?? 0) + 1;
    }

    return {
      'total': total,
      'unread': unread,
      'read': total - unread,
      'byType': byType,
    };
  }

  // 알림 필터링
  static List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((n) => n['type'] == type).toList();
  }

  // 알림 검색
  static List<Map<String, dynamic>> searchNotifications(String query) {
    return _notifications.where((n) {
      final title = (n['title'] as String).toLowerCase();
      final body = (n['body'] as String).toLowerCase();
      final searchQuery = query.toLowerCase();
      
      return title.contains(searchQuery) || body.contains(searchQuery);
    }).toList();
  }
}
