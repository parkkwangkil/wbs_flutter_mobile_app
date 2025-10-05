import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class NotificationSettings {
  static final Map<String, bool> _defaultSettings = {
    'project_updates': true,
    'event_reminders': true,
    'team_notifications': true,
    'system_alerts': true,
    'email_notifications': false,
    'push_notifications': true,
    'daily_summary': false,
    'weekly_summary': false,
    'milestone_alerts': true,
    'deadline_warnings': true,
  };

  static final Map<String, bool> _settings = Map.from(_defaultSettings);
  static final StreamController<Map<String, bool>> _settingsController = 
      StreamController<Map<String, bool>>.broadcast();

  static Stream<Map<String, bool>> get settingsStream => _settingsController.stream;
  static Map<String, bool> get settings => Map.unmodifiable(_settings);

  // 설정 초기화
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    for (final key in _defaultSettings.keys) {
      _settings[key] = prefs.getBool(key) ?? _defaultSettings[key]!;
    }
    
    _settingsController.add(Map.unmodifiable(_settings));
  }

  // 설정 가져오기
  static bool getSetting(String key) {
    return _settings[key] ?? _defaultSettings[key] ?? false;
  }

  // 설정 변경
  static Future<void> setSetting(String key, bool value) async {
    _settings[key] = value;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    
    _settingsController.add(Map.unmodifiable(_settings));
  }

  // 여러 설정 변경
  static Future<void> setSettings(Map<String, bool> newSettings) async {
    _settings.addAll(newSettings);
    
    final prefs = await SharedPreferences.getInstance();
    for (final entry in newSettings.entries) {
      await prefs.setBool(entry.key, entry.value);
    }
    
    _settingsController.add(Map.unmodifiable(_settings));
  }

  // 설정 초기화
  static Future<void> resetSettings() async {
    _settings.clear();
    _settings.addAll(_defaultSettings);
    
    final prefs = await SharedPreferences.getInstance();
    for (final key in _defaultSettings.keys) {
      await prefs.setBool(key, _defaultSettings[key]!);
    }
    
    _settingsController.add(Map.unmodifiable(_settings));
  }

  // 설정 내보내기
  static Map<String, dynamic> exportSettings() {
    return Map.from(_settings);
  }

  // 설정 가져오기
  static Future<void> importSettings(Map<String, dynamic> importedSettings) async {
    final newSettings = <String, bool>{};
    
    for (final entry in importedSettings.entries) {
      if (entry.value is bool) {
        newSettings[entry.key] = entry.value;
      }
    }
    
    await setSettings(newSettings);
  }

  // 알림 타입별 설정
  static bool get projectUpdates => getSetting('project_updates');
  static bool get eventReminders => getSetting('event_reminders');
  static bool get teamNotifications => getSetting('team_notifications');
  static bool get systemAlerts => getSetting('system_alerts');
  static bool get emailNotifications => getSetting('email_notifications');
  static bool get pushNotifications => getSetting('push_notifications');
  static bool get dailySummary => getSetting('daily_summary');
  static bool get weeklySummary => getSetting('weekly_summary');
  static bool get milestoneAlerts => getSetting('milestone_alerts');
  static bool get deadlineWarnings => getSetting('deadline_warnings');

  // 알림 타입별 설정 변경
  static Future<void> setProjectUpdates(bool value) async {
    await setSetting('project_updates', value);
  }

  static Future<void> setEventReminders(bool value) async {
    await setSetting('event_reminders', value);
  }

  static Future<void> setTeamNotifications(bool value) async {
    await setSetting('team_notifications', value);
  }

  static Future<void> setSystemAlerts(bool value) async {
    await setSetting('system_alerts', value);
  }

  static Future<void> setEmailNotifications(bool value) async {
    await setSetting('email_notifications', value);
  }

  static Future<void> setPushNotifications(bool value) async {
    await setSetting('push_notifications', value);
  }

  static Future<void> setDailySummary(bool value) async {
    await setSetting('daily_summary', value);
  }

  static Future<void> setWeeklySummary(bool value) async {
    await setSetting('weekly_summary', value);
  }

  static Future<void> setMilestoneAlerts(bool value) async {
    await setSetting('milestone_alerts', value);
  }

  static Future<void> setDeadlineWarnings(bool value) async {
    await setSetting('deadline_warnings', value);
  }

  // 설정 설명
  static Map<String, String> get settingDescriptions => {
    'project_updates': '프로젝트 업데이트 알림',
    'event_reminders': '이벤트 알림',
    'team_notifications': '팀 알림',
    'system_alerts': '시스템 알림',
    'email_notifications': '이메일 알림',
    'push_notifications': '푸시 알림',
    'daily_summary': '일일 요약',
    'weekly_summary': '주간 요약',
    'milestone_alerts': '마일스톤 알림',
    'deadline_warnings': '마감일 경고',
  };

  // 설정 그룹
  static Map<String, List<String>> get settingGroups => {
    '알림 유형': [
      'push_notifications',
      'email_notifications',
    ],
    '프로젝트': [
      'project_updates',
      'milestone_alerts',
      'deadline_warnings',
    ],
    '이벤트': [
      'event_reminders',
    ],
    '팀': [
      'team_notifications',
    ],
    '시스템': [
      'system_alerts',
    ],
    '요약': [
      'daily_summary',
      'weekly_summary',
    ],
  };

  // 활성화된 알림 수
  static int get activeNotificationCount {
    return _settings.values.where((value) => value).length;
  }

  // 전체 알림 수
  static int get totalNotificationCount {
    return _settings.length;
  }

  // 알림 활성화 비율
  static double get notificationRatio {
    return activeNotificationCount / totalNotificationCount;
  }
}
