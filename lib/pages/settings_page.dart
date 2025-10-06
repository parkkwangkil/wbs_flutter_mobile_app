import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer를 사용하면 builder 내에서 Provider에 접근 가능
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, lang, theme, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(lang.getText('설정', 'Settings')),
          ),
          body: ListView(
            children: <Widget>[
              // --- 모양 설정 섹션 ---
              _buildSectionHeader(context, lang.getText('모양', 'Appearance')),
              SwitchListTile(
                title: Text(lang.getText('다크 모드', 'Dark Mode')),
                subtitle: Text(lang.getText('앱의 전체 테마를 변경합니다.', 'Change the overall theme of the app.')),
                value: theme.isDarkMode,
                onChanged: (bool value) {
                  // ThemeProvider의 함수를 호출하여 테마 변경
                  theme.toggleTheme();
                },
                secondary: const Icon(Icons.dark_mode_outlined),
              ),

              const Divider(),

              // --- 언어 설정 섹션 ---
              _buildSectionHeader(context, lang.getText('언어', 'Language')),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(lang.getText('언어 변경', 'Change Language')),
                subtitle: Text(lang.getText('현재 언어: ', 'Current: ') + (lang.currentLanguage == 'ko' ? '한국어' : 'English')),
                onTap: () {
                  // 언어 선택 다이얼로그 표시
                  _showLanguageDialog(context, lang);
                },
              ),
              const Divider(),
              // 여기에 다른 설정 항목들(알림 설정, 계정 정보 등)을 추가할 수 있습니다.
            ],
          ),
        );
      },
    );
  }

  // 섹션 제목을 만드는 헬퍼 위젯
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // 언어 선택 다이얼로그
  void _showLanguageDialog(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('언어 선택', 'Select Language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: const Text('한국어'),
                value: 'ko',
                groupValue: lang.currentLanguage,
                onChanged: (String? value) {
                  if (value != null) {
                    lang.setLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: lang.currentLanguage,
                onChanged: (String? value) {
                  if (value != null) {
                    lang.setLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
