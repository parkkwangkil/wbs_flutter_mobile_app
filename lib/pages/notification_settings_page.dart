import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_provider.dart';
import '../services/notification_settings.dart';

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
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('알림 설정', 'Notification Settings')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<Map<String, bool>>(
        stream: NotificationSettings.settingsStream,
        initialData: NotificationSettings.settings,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final settings = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildNotificationStats(lang),
              const SizedBox(height: 24),
              ...NotificationSettings.settingGroups.entries.map((entry) {
                return _buildSettingsGroup(entry.key, entry.value, settings, lang);
              }).toList(),
              const SizedBox(height: 24),
              _buildActionButtons(lang),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationStats(LanguageProvider lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.getText('알림 통계', 'Notification Stats'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatItem(lang.getText('활성화', 'Active'), '${NotificationSettings.activeNotificationCount}', Colors.green)),
                Expanded(child: _buildStatItem(lang.getText('전체', 'Total'), '${NotificationSettings.totalNotificationCount}', Colors.blue)),
                Expanded(child: _buildStatItem(lang.getText('비율', 'Ratio'), '${(NotificationSettings.notificationRatio * 100).toInt()}%', Colors.orange)),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: NotificationSettings.notificationRatio,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(NotificationSettings.notificationRatio > 0.5 ? Colors.green : Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSettingsGroup(String groupName, List<String> settingKeys, Map<String, bool> settings, LanguageProvider lang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(lang.getText(groupName, groupName), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            ...settingKeys.map((key) => _buildSettingItem(key, settings[key] ?? false, lang)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String key, bool value, LanguageProvider lang) {
    final title = NotificationSettings.settingDescriptions[key] ?? key;
    
    return SwitchListTile(
      title: Text(lang.getText(title, title)),
      value: value,
      onChanged: (newValue) {
        NotificationSettings.setSetting(key, newValue);
      },
    );
  }

  Widget _buildActionButtons(LanguageProvider lang) {
    return Column(
      children: [
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => _showResetDialog(lang), icon: const Icon(Icons.refresh), label: Text(lang.getText('설정 초기화', 'Reset')), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white))),
          const SizedBox(width: 16),
          Expanded(child: ElevatedButton.icon(onPressed: () => _showExportDialog(lang), icon: const Icon(Icons.download), label: Text(lang.getText('내보내기', 'Export')), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white))),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => _showImportDialog(lang), icon: const Icon(Icons.upload), label: Text(lang.getText('가져오기', 'Import')), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
          const SizedBox(width: 16),
          Expanded(child: ElevatedButton.icon(onPressed: () => _showTestDialog(lang), icon: const Icon(Icons.notifications), label: Text(lang.getText('테스트', 'Test')), style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white))),
        ]),
      ],
    );
  }

  void _showResetDialog(LanguageProvider lang) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(lang.getText('설정 초기화', 'Reset Settings')),
      content: Text(lang.getText('모든 알림 설정을 기본값으로 초기화하시겠습니까?', 'Reset all notification settings to default?')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(lang.getText('취소', 'Cancel'))),
        ElevatedButton(onPressed: () {
          NotificationSettings.resetSettings();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.getText('설정이 초기화되었습니다', 'Settings have been reset'))));
        }, child: Text(lang.getText('초기화', 'Reset'))),
      ],
    ));
  }
  
  void _showTestDialog(LanguageProvider lang) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(lang.getText('테스트 알림', 'Test Notification')),
      content: Text(lang.getText('테스트 알림을 전송하시겠습니까?', 'Send a test notification?')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(lang.getText('취소', 'Cancel'))),
        ElevatedButton(onPressed: () {
          Provider.of<NotificationProvider>(context, listen: false).addNotification(
            title: lang.getText('테스트 알림', 'Test Notification'),
            body: lang.getText('이 알림은 WBS 앱에서 보낸 테스트 메시지입니다.', 'This is a test message from the WBS App.'),
            type: 'system_alerts',
          );
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.getText('테스트 알림이 전송되었습니다', 'Test notification sent'))));
        }, child: Text(lang.getText('전송', 'Send'))),
      ],
    ));
  }
  
  void _showExportDialog(LanguageProvider lang) {
    final settingsJson = jsonEncode(NotificationSettings.exportSettings());
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(lang.getText('설정 내보내기', 'Export Settings')),
      content: SelectableText(settingsJson),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(lang.getText('닫기', 'Close')))],
    ));
  }

  void _showImportDialog(LanguageProvider lang) {
    final controller = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(lang.getText('설정 가져오기', 'Import Settings')),
      content: TextField(controller: controller, decoration: InputDecoration(hintText: lang.getText('JSON 데이터를 여기에 붙여넣으세요', 'Paste JSON data here'))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(lang.getText('취소', 'Cancel'))),
        ElevatedButton(onPressed: () {
          try {
            final importedSettings = jsonDecode(controller.text);
            NotificationSettings.importSettings(importedSettings as Map<String, dynamic>);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.getText('설정을 가져왔습니다', 'Settings imported successfully'))));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.getText('잘못된 형식입니다', 'Invalid format'))));
          }
        }, child: Text(lang.getText('가져오기', 'Import'))),
      ],
    ));
  }
}
