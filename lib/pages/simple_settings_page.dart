import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class SimpleSettingsPage extends StatelessWidget {
  const SimpleSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('설정', 'Settings')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 프로필 섹션
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.getText('프로필', 'Profile'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(lang.getText('이름', 'Name')),
                    subtitle: const Text('사용자'),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang.getText('프로필 수정 기능', 'Profile edit feature'))),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(lang.getText('이메일', 'Email')),
                    subtitle: const Text('user@example.com'),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang.getText('이메일 수정 기능', 'Email edit feature'))),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 알림 설정 섹션
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.getText('알림 설정', 'Notification Settings'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(lang.getText('푸시 알림', 'Push Notifications')),
                    subtitle: Text(lang.getText('앱 알림을 받습니다', 'Receive app notifications')),
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang.getText('푸시 알림 설정 변경', 'Push notification setting changed'))),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: Text(lang.getText('이메일 알림', 'Email Notifications')),
                    subtitle: Text(lang.getText('이메일로 알림을 받습니다', 'Receive notifications via email')),
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang.getText('이메일 알림 설정 변경', 'Email notification setting changed'))),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 앱 설정 섹션
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.getText('앱 설정', 'App Settings'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(lang.getText('언어', 'Language')),
                    subtitle: Text(lang.getText('한국어', 'Korean')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang.getText('언어 설정 기능', 'Language setting feature'))),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: Text(lang.getText('다크 모드', 'Dark Mode')),
                    subtitle: Text(lang.getText('어두운 테마를 사용합니다', 'Use dark theme')),
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang.getText('다크 모드 설정 변경', 'Dark mode setting changed'))),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
