import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/local_database.dart';
import '../services/app_state_service.dart';
import 'admin_security_page.dart';
import 'data_analysis_page.dart';
import 'team_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> users = [];
  bool _isLoading = true;
  Map<String, dynamic> _systemSettings = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadSystemSettings();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userList = await LocalDatabase.getUsers();
      setState(() {
        users = userList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        users = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSystemSettings() async {
    try {
      final settings = await LocalDatabase.getSystemSettings();
      setState(() {
        _systemSettings = settings;
      });
    } catch (e) {
      print('Error loading system settings: $e');
    }
  }

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
            icon: Icons.group_outlined,
            title: lang.getText('팀 관리', 'Team Management'),
            subtitle: lang.getText('팀원 추가, 수정, 삭제 관리', 'Manage team members - add, edit, delete'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeamPage(projectId: 'admin')),
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
                value: _systemSettings['auto_backup'] ?? true,
                onChanged: (value) {
                  setState(() {
                    _systemSettings['auto_backup'] = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text(lang.getText('알림 활성화', 'Enable Notifications')),
                subtitle: Text(lang.getText('시스템 알림을 활성화합니다', 'Enable system notifications')),
                value: _systemSettings['notifications_enabled'] ?? true,
                onChanged: (value) {
                  setState(() {
                    _systemSettings['notifications_enabled'] = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.getText('닫기', 'Close')),
            ),
            ElevatedButton(
              onPressed: () async {
                await LocalDatabase.saveSystemSettings(_systemSettings);
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
              onPressed: () async {
                if (nameController.text.isNotEmpty && 
                    emailController.text.isNotEmpty && 
                    passwordController.text.isNotEmpty) {
                  try {
                    final newUser = {
                      'name': nameController.text,
                      'email': emailController.text,
                      'password': passwordController.text,
                      'role': 'user',
                      'status': 'offline',
                      'created_at': DateTime.now().toIso8601String(),
                    };
                    
                    await LocalDatabase.addUser(newUser);
                    await _loadUsers();
                    Provider.of<AppStateService>(context, listen: false).notifyListeners();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(lang.getText('사용자가 추가되었습니다.', 'User added.')),
                      ),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(lang.getText('사용자 추가에 실패했습니다.', 'Failed to add user.')),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lang.getText('모든 필드를 입력해주세요.', 'Please fill in all fields.')),
                      backgroundColor: Colors.red,
                    ),
                  );
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
            height: 400,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              lang.getText('사용자가 없습니다', 'No users'),
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(user['name']?.substring(0, 1).toUpperCase() ?? 'U'),
                            ),
                            title: Text(user['name'] ?? 'Unknown'),
                            subtitle: Text(user['email'] ?? 'No email'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user['role'] == 'admin' 
                                      ? Icons.admin_panel_settings 
                                      : Icons.person,
                                  color: user['role'] == 'admin' ? Colors.red : Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _deleteUser(context, lang, user);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(lang.getText('삭제', 'Delete')),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
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

  Future<void> _deleteUser(BuildContext context, LanguageProvider lang, Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('사용자 삭제', 'Delete User')),
        content: Text('${user['name']}님을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang.getText('취소', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(lang.getText('삭제', 'Delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await LocalDatabase.deleteUser(user['id']);
        await _loadUsers();
        Provider.of<AppStateService>(context, listen: false).notifyListeners();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.getText('사용자가 삭제되었습니다.', 'User deleted.')),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.getText('사용자 삭제에 실패했습니다.', 'Failed to delete user.')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


}
