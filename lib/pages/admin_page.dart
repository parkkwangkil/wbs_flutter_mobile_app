import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'admin_security_page.dart';
import 'data_analysis_page.dart'; // 방금 보여주신 그 파일입니다.

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('관리자 페이지', 'Admin Page')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildAdminMenuItem(
            context: context,
            icon: Icons.people_outline,
            title: lang.getText('사용자 관리', 'User Management'),
            subtitle: lang.getText('사용자 추가, 수정, 삭제', 'Add, edit, or remove users'),
            onTap: () {
              _showUserManagementDialog(context, lang);
            },
          ),
          _buildAdminMenuItem(
            context: context,
            icon: Icons.settings_applications_outlined,
            title: lang.getText('시스템 설정', 'System Settings'),
            subtitle: lang.getText('시스템 전반의 동작 설정', 'Configure system-wide behavior'),
            onTap: () {
              _showSystemSettingsDialog(context, lang);
            },
          ),
          _buildAdminMenuItem(
            context: context,
            icon: Icons.security_outlined,
            title: lang.getText('보안 설정', 'Security Settings'),
            subtitle: lang.getText('접근 제어 및 보안 로그 확인', 'Control access and view security logs'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminSecurityPage()),
              );
            },
          ),
           _buildAdminMenuItem(
            context: context,
            icon: Icons.analytics_outlined,
            title: lang.getText('데이터 분석', 'Data Analytics'),
            subtitle: lang.getText('프로젝트 및 사용자 데이터 통계', 'Statistics on projects and users'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DataAnalysisPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showUserManagementDialog(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('사용자 관리', 'User Management')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add),
                title: Text(lang.getText('새 사용자 추가', 'Add New User')),
                onTap: () {
                  Navigator.pop(context);
                  _showAddUserDialog(context, lang);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: Text(lang.getText('사용자 목록', 'User List')),
                onTap: () {
                  Navigator.pop(context);
                  _showUserListDialog(context, lang);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.getText('닫기', 'Close')),
            ),
          ],
        );
      },
    );
  }

  void _showSystemSettingsDialog(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('시스템 설정', 'System Settings')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text(lang.getText('자동 백업', 'Auto Backup')),
                subtitle: Text(lang.getText('매일 자동으로 데이터를 백업합니다', 'Automatically backup data daily')),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: Text(lang.getText('알림 활성화', 'Enable Notifications')),
                subtitle: Text(lang.getText('시스템 알림을 활성화합니다', 'Enable system notifications')),
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.getText('닫기', 'Close')),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(lang.getText('설정이 저장되었습니다.', 'Settings saved.'))),
                );
                Navigator.pop(context);
              },
              child: Text(lang.getText('저장', 'Save')),
            ),
          ],
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context, LanguageProvider lang) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('새 사용자 추가', 'Add New User')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: lang.getText('이름', 'Name'),
                ),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: lang.getText('이메일', 'Email'),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: lang.getText('비밀번호', 'Password'),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.getText('취소', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && 
                    emailController.text.isNotEmpty && 
                    passwordController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lang.getText('사용자가 추가되었습니다.', 'User added.')),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(lang.getText('추가', 'Add')),
            ),
          ],
        );
      },
    );
  }

  void _showUserListDialog(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('사용자 목록', 'User List')),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView(
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Text('A')),
                  title: const Text('Admin'),
                  subtitle: const Text('admin@wbs.com'),
                  trailing: const Icon(Icons.admin_panel_settings),
                ),
                ListTile(
                  leading: const CircleAvatar(child: Text('D')),
                  title: const Text('DevOps'),
                  subtitle: const Text('devops@wbs.com'),
                  trailing: const Icon(Icons.person),
                ),
                ListTile(
                  leading: const CircleAvatar(child: Text('U')),
                  title: const Text('User1'),
                  subtitle: const Text('user1@wbs.com'),
                  trailing: const Icon(Icons.person),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.getText('닫기', 'Close')),
            ),
          ],
        );
      },
    );
  }
}
