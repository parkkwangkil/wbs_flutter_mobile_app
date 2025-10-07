import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

// 모든 설정 키를 열거형(enum)으로 정의하여 실수를 원천 차단합니다.
enum NotificationSettingKey {projectUpdates,
  eventReminders,
  teamNotifications,
  systemAlerts,
  emailNotifications,
  pushNotifications,
  dailySummary,
  weeklySummary,
  milestoneAlerts,
  deadlineWarnings,
}

class NotificationSettings {
  // 클래스 내부의 모든 Map은 이제 String이 아닌 enum을 키로 사용합니다.
  static final Map<NotificationSettingKey, bool> _defaultSettings = {
    NotificationSettingKey.projectUpdates: true,
    NotificationSettingKey.eventReminders: true,
    NotificationSettingKey.teamNotifications: true,
    NotificationSettingKey.systemAlerts: true,
    NotificationSettingKey.emailNotifications: false,
    NotificationSettingKey.pushNotifications: true,
    NotificationSettingKey.dailySummary: false,
    NotificationSettingKey.weeklySummary: false,
    NotificationSettingKey.milestoneAlerts: true,
    NotificationSettingKey.deadlineWarnings: true,
  };

  static final Map<NotificationSettingKey, bool> _settings = Map.from(_defaultSettings);
  static final StreamController<Map<NotificationSettingKey, bool>> _settingsController =
      StreamController<Map<NotificationSettingKey, bool>>.broadcast();

  // 외부로 노출되는 Stream과 settings Map도 enum을 키로 사용하도록 타입을 변경합니다.
  static Stream<Map<NotificationSettingKey, bool>> get settingsStream => _settingsController.stream;
  static Map<NotificationSettingKey, bool> get settings => Map.unmodifiable(_settings);

  // 설정 초기화
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences와 통신할 때만 enum의 이름(.name)을 문자열로 변환하여 사용합니다.
    for (final key in NotificationSettingKey.values) {
      _settings[key] = prefs.getBool(key.name) ?? _defaultSettings[key]!;
    }
    _settingsController.add(Map.unmodifiable(_settings));
  }

  // 설정 가져오기 (이제 String 대신 enum을 파라미터로 받습니다)
  static bool getSetting(NotificationSettingKey key) {
    return _settings[key] ?? _defaultSettings[key] ?? false;
  }

  // 설정 변경 (이제 String 대신 enum을 파라미터로 받습니다)
  static Future<void> setSetting(NotificationSettingKey key, bool value) async {
    _settings[key] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key.name, value);
    _settingsController.add(Map.unmodifiable(_settings));
  }

  // 여러 설정 변경
  static Future<void> setSettings(Map<NotificationSettingKey, bool> newSettings) async {
    _settings.addAll(newSettings);
    final prefs = await SharedPreferences.getInstance();
    for (final entry in newSettings.entries) {
      await prefs.setBool(entry.key.name, entry.value);
    }
    _settingsController.add(Map.unmodifiable(_settings));
  }

  // 설정 초기화
  static Future<void> resetSettings() async {
    _settings.clear();
    _settings.addAll(_defaultSettings);
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _defaultSettings.entries) {
      await prefs.setBool(entry.key.name, entry.value);
    }
    _settingsController.add(Map.unmodifiable(_settings));
  }

  // 설정 내보내기 (JSON 문자열로 변환)
  static String exportSettingsAsJson() {
    final stringKeyMap = _settings.map((key, value) => MapEntry(key.name, value));
    return jsonEncode(stringKeyMap);
  }

  // 설정 가져오기 (JSON 문자열로부터 복원)
  static Future<void> importSettingsFromJson(String jsonString) async {
    try {
      final Map<String, dynamic> importedMap = jsonDecode(jsonString);
      final newSettings = <NotificationSettingKey, bool>{};

      for (final entry in importedMap.entries) {
        // 문자열 키를 다시 enum 값으로 안전하게 변환
        final key = NotificationSettingKey.values.firstWhere((e) => e.name == entry.key);
        if (entry.value is bool) {
          newSettings[key] = entry.value as bool;
        }
      }
      await setSettings(newSettings);
    } catch (e) {
      print('Failed to import settings: $e');
    }
  }
  
  // UI 구성을 위한 데이터 (설명)
  static Map<NotificationSettingKey, String> get settingDescriptions => {
    NotificationSettingKey.projectUpdates: '프로젝트 업데이트 알림',
    NotificationSettingKey.eventReminders: '이벤트 알림',
    NotificationSettingKey.teamNotifications: '팀 알림',
    NotificationSettingKey.systemAlerts: '시스템 알림',
    NotificationSettingKey.emailNotifications: '이메일 알림',
    NotificationSettingKey.pushNotifications: '푸시 알림',
    NotificationSettingKey.dailySummary: '일일 요약',
    NotificationSettingKey.weeklySummary: '주간 요약',
    NotificationSettingKey.milestoneAlerts: '마일스톤 알림',
    NotificationSettingKey.deadlineWarnings: '마감일 경고',
  };

  // UI 구성을 위한 데이터 (그룹)
  static Map<String, List<NotificationSettingKey>> get settingGroups => {
    '알림 유형': [
      NotificationSettingKey.pushNotifications,
      NotificationSettingKey.emailNotifications,
    ],
    '프로젝트': [
      NotificationSettingKey.projectUpdates,
      NotificationSettingKey.milestoneAlerts,
      NotificationSettingKey.deadlineWarnings,
    ],
    '요약': [
      NotificationSettingKey.dailySummary,
      NotificationSettingKey.weeklySummary,
    ],
    '기타': [
      NotificationSettingKey.eventReminders,
      NotificationSettingKey.teamNotifications,
      NotificationSettingKey.systemAlerts,
    ],
  };
}
