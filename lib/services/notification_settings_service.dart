// lib/services/notification_settings_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 이 서비스는 static 클래스로 구현하여 인스턴스화 없이 어디서든 접근 가능하게 합니다.
class NotificationSettingsService {
  static late SharedPreferences _prefs;

  // UI가 실시간으로 설정을 반영하도록 ValueNotifier를 사용합니다.
  static final ValueNotifier<Map<String, bool>> settingsNotifier = ValueNotifier({});

  // --- 설정 키(Key) 상수 정의 ---
  static const String pushKey = 'push_notifications';
  static const String emailKey = 'email_notifications';
  // ... 다른 모든 키들도 상수로 정의하면 오타를 방지할 수 있습니다.

  // --- 설정 데이터 구조 정의 ---
  // 설정 항목에 대한 한글 설명
  static const Map<String, String> settingDescriptions = {
    pushKey: '푸시 알림',
    emailKey: '이메일 알림',
    'project_updates': '프로젝트 업데이트',
    'event_reminders': '이벤트 리마인더',
    'team_notifications': '팀 활동',
    'system_alerts': '중요 시스템 공지',
    'daily_summary': '일일 요약',
    'weekly_summary': '주간 요약',
    'milestone_alerts': '마일스톤 달성',
    'deadline_warnings': '마감일 경고',
  };

  // 설정을 그룹화하여 UI에 표시
  static const Map<String, List<String>> settingGroups = {
    '기본 알림': [pushKey, emailKey],
    '프로젝트 알림': ['project_updates', 'milestone_alerts', 'deadline_warnings'],
    '팀/이벤트 알림': ['team_notifications', 'event_reminders'],
    '요약 알림': ['daily_summary', 'weekly_summary'],
    '시스템 알림': ['system_alerts'],
  };

  // 모든 설정 키 목록 (계산을 위해 미리 만들어 둠)
  static final List<String> allSettingKeys = settingGroups.values.expand((keys) => keys).toList();

  // --- 핵심 메소드 ---

  // 앱 시작 시 main.dart에서 딱 한번 호출되어야 합니다.
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  // SharedPreferences에서 설정을 불러와 Notifier에 반영합니다.
  static Future<void> _loadSettings() async {
    final Map<String, bool> currentSettings = {};
    for (var key in allSettingKeys) {
      // 저장된 값이 없으면 기본값으로 true를 사용합니다.
      currentSettings[key] = _prefs.getBool(key) ?? true;
    }
    settingsNotifier.value = currentSettings;
  }

  // 특정 설정을 변경하고 저장합니다.
  static Future<void> setSetting(String key, bool value) async {
    await _prefs.setBool(key, value);
    // Notifier의 값을 직접 수정하는 대신, 복사본을 만들어 교체해야 UI가 갱신됩니다.
    final newSettings = Map<String, bool>.from(settingsNotifier.value);
    newSettings[key] = value;
    settingsNotifier.value = newSettings;
  }

  // 특정 설정 값을 가져옵니다. (기본값은 false)
  static bool getSetting(String key) {
    return settingsNotifier.value[key] ?? false;
  }

  // 모든 설정을 기본값(true)으로 되돌립니다.
  static Future<void> resetSettings() async {
    for (var key in allSettingKeys) {
      await _prefs.setBool(key, true);
    }
    await _loadSettings(); // 리셋 후 다시 로드하여 UI 갱신
  }

  // --- 통계 계산 getter ---
  static int get activeNotificationCount {
    return settingsNotifier.value.values.where((v) => v == true).length;
  }

  static int get totalNotificationCount {
    return allSettingKeys.length;
  }

  static double get notificationRatio {
    if (totalNotificationCount == 0) return 0.0;
    return activeNotificationCount / totalNotificationCount;
  }

  // --- 설정 내보내기/가져오기 ---
  static String exportSettings() {
    return jsonEncode(settingsNotifier.value);
  }

  static Future<bool> importSettings(String jsonString) async {
    try {
      final importedMap = Map<String, dynamic>.from(jsonDecode(jsonString));
      for (var key in importedMap.keys) {
        if (allSettingKeys.contains(key)) {
          await setSetting(key, importedMap[key] as bool);
        }
      }
      return true;
    } catch (e) {
      debugPrint("설정 가져오기 실패: $e");
      return false;
    }
  }
}
