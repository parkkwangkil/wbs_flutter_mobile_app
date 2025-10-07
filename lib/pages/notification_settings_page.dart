import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
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
    // LanguageProvider 인스턴스를 가져옵니다.
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        // [수정 완료] lang.translate -> lang.getText 로 올바르게 수정했습니다.
        title: Text(lang.getText('알림 설정', 'Notification Settings')),
      ),
      body: StreamBuilder<Map<NotificationSettingKey, bool>>(
        stream: NotificationSettings.settingsStream,
        initialData: NotificationSettings.settings,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = snapshot.data!;
          final settingGroups = NotificationSettings.settingGroups;

          return ListView(
            children: [
              ...settingGroups.entries.map((entry) {
                final groupTitle = entry.key;
                final settingKeys = entry.value; // List<NotificationSettingKey>
                return _buildSettingsGroup(groupTitle, settingKeys, settings);
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsGroup(
    String title,
    List<NotificationSettingKey> settingKeys,
    Map<NotificationSettingKey, bool> settings,
  ) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ...settingKeys.map((key) {
              return _buildSettingItem(key, settings[key] ?? false);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    NotificationSettingKey key,
    bool value,
  ) {
    // UI에 표시될 텍스트를 가져옵니다.
    final title = NotificationSettings.settingDescriptions[key] ?? key.name;

    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (newValue) {
        NotificationSettings.setSetting(key, newValue);
      },
      secondary: const Icon(Icons.notifications),
    );
  }
}
