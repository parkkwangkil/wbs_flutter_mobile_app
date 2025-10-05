import 'package:flutter/material.dart';
import '../services/notification_settings.dart';
import '../l10n/app_localizations.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    NotificationSettings.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<Map<String, bool>>(
        stream: NotificationSettings.settingsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = snapshot.data!;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 알림 통계
              _buildNotificationStats(settings),
              const SizedBox(height: 24),
              
              // 알림 유형별 설정
              ...NotificationSettings.settingGroups.entries.map((entry) {
                return _buildSettingsGroup(entry.key, entry.value, settings);
              }).toList(),
              
              const SizedBox(height: 24),
              
              // 액션 버튼들
              _buildActionButtons(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationStats(Map<String, bool> settings) {
    final activeCount = NotificationSettings.activeNotificationCount;
    final totalCount = NotificationSettings.totalNotificationCount;
    final ratio = NotificationSettings.notificationRatio;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '알림 통계',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '활성화된 알림',
                    '$activeCount',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '전체 알림',
                    '$totalCount',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '활성화 비율',
                    '${(ratio * 100).toInt()}%',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                ratio > 0.5 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String groupName, List<String> settingKeys, Map<String, bool> settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...settingKeys.map((key) {
              return _buildSettingItem(key, settings[key] ?? false);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String key, bool value) {
    final description = NotificationSettings.settingDescriptions[key] ?? key;
    
    return ListTile(
      title: Text(description),
      subtitle: Text(_getSettingSubtitle(key)),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          NotificationSettings.setSetting(key, newValue);
        },
      ),
      onTap: () {
        NotificationSettings.setSetting(key, !value);
      },
    );
  }

  String _getSettingSubtitle(String key) {
    switch (key) {
      case 'push_notifications':
        return '앱 내 푸시 알림을 받습니다';
      case 'email_notifications':
        return '이메일로 알림을 받습니다';
      case 'project_updates':
        return '프로젝트 업데이트 시 알림';
      case 'event_reminders':
        return '이벤트 시작 전 알림';
      case 'team_notifications':
        return '팀 관련 알림';
      case 'system_alerts':
        return '시스템 중요 알림';
      case 'daily_summary':
        return '매일 요약 이메일';
      case 'weekly_summary':
        return '매주 요약 이메일';
      case 'milestone_alerts':
        return '마일스톤 완료 알림';
      case 'deadline_warnings':
        return '마감일 경고 알림';
      default:
        return '알림 설정';
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showResetDialog();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('설정 초기화'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showExportDialog();
                },
                icon: const Icon(Icons.download),
                label: const Text('설정 내보내기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showImportDialog();
                },
                icon: const Icon(Icons.upload),
                label: const Text('설정 가져오기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showTestDialog();
                },
                icon: const Icon(Icons.notifications),
                label: const Text('테스트 알림'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text('모든 알림 설정을 기본값으로 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              NotificationSettings.resetSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('설정이 초기화되었습니다')),
              );
            },
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final settings = NotificationSettings.exportSettings();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 내보내기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('현재 알림 설정을 JSON 형태로 내보냅니다.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                settings.toString(),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 가져오기'),
        content: const Text('JSON 형태의 설정을 가져옵니다.\n\n이 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showTestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테스트 알림'),
        content: const Text('테스트 알림을 전송하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 테스트 알림 전송 로직
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('테스트 알림이 전송되었습니다')),
              );
            },
            child: const Text('전송'),
          ),
        ],
      ),
    );
  }
}
