import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'simple_settings_page.dart';

class ProfilePage extends StatelessWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    // 가짜 사용자 데이터
    final user = {
      'name': username,
      'email': '$username@example.com',
      'department': '개발팀',
      'position': '선임 연구원',
      'avatarUrl': 'https://via.placeholder.com/150', // 가상 이미지
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('프로필', 'Profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SimpleSettingsPage()),
              );
            },
            tooltip: lang.getText('설정', 'Settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      user['name']!.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user['name']!,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    user['email']!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text('${user['department']} / ${user['position']}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileMenu(
              lang,
              icon: Icons.edit_outlined,
              text: lang.getText('개인정보 수정', 'Edit Profile'),
              onTap: () {
                _showEditProfileDialog(context, lang);
              },
            ),
            _buildProfileMenu(
              lang,
              icon: Icons.lock_outline,
              text: lang.getText('비밀번호 변경', 'Change Password'),
              onTap: () {
                _showChangePasswordDialog(context, lang);
              },
            ),
            _buildProfileMenu(
              lang,
              icon: Icons.settings_outlined,
              text: lang.getText('설정', 'Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SimpleSettingsPage()),
                );
              },
            ),
            const Divider(),
            _buildProfileMenu(
              lang,
              icon: Icons.logout,
              text: lang.getText('로그아웃', 'Logout'),
              onTap: () {
                // TODO: 로그인 페이지로 이동하는 로직 구현
                Navigator.of(context).pop();
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(LanguageProvider lang,
      {required IconData icon,
      required String text,
      required VoidCallback onTap,
      bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      trailing:
          isDestructive ? null : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context, LanguageProvider lang) {
    // 가짜 사용자 데이터
    final user = {
      'name': username,
      'email': '$username@example.com',
      'department': '개발팀',
      'position': '선임 연구원',
    };
    
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    final departmentController = TextEditingController(text: user['department']);
    final positionController = TextEditingController(text: user['position']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('개인정보 수정', 'Edit Profile')),
          content: SingleChildScrollView(
            child: Column(
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
                ),
                TextField(
                  controller: departmentController,
                  decoration: InputDecoration(
                    labelText: lang.getText('부서', 'Department'),
                  ),
                ),
                TextField(
                  controller: positionController,
                  decoration: InputDecoration(
                    labelText: lang.getText('직책', 'Position'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(lang.getText('취소', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: 실제 프로필 업데이트 로직
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lang.getText('프로필이 업데이트되었습니다.', 'Profile updated.')),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Text(lang.getText('저장', 'Save')),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, LanguageProvider lang) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('비밀번호 변경', 'Change Password')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: lang.getText('현재 비밀번호', 'Current Password'),
                ),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: lang.getText('새 비밀번호', 'New Password'),
                ),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: lang.getText('비밀번호 확인', 'Confirm Password'),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(lang.getText('취소', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: 실제 비밀번호 변경 로직
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lang.getText('비밀번호가 변경되었습니다.', 'Password changed.')),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Text(lang.getText('변경', 'Change')),
            ),
          ],
        );
      },
    );
  }
}
