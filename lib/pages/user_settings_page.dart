import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../services/local_database.dart';
import '../services/biometric_service.dart';

class UserSettingsPage extends StatefulWidget {
  final String? currentUser;
  
  const UserSettingsPage({super.key, this.currentUser});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  Map<String, dynamic> _userProfile = {};
  Map<String, dynamic> _notificationSettings = {};
  Map<String, dynamic> _appSettings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await LocalDatabase.getUsers();
      final currentUser = users.isNotEmpty ? users.first : {
        'name': '사용자',
        'email': 'user@example.com',
      };
      _userProfile = currentUser;

      _notificationSettings = await LocalDatabase.getNotificationSettings();
      _appSettings = await LocalDatabase.getAppSettings();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(lang.getText('설정', 'Settings')),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Admin 사용자는 관리자 설정을, 일반 사용자는 사용자 설정을 보여줌
    final bool isAdmin = widget.currentUser == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('설정', 'Settings')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 구분 표시
            if (isAdmin) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Text(
                      '관리자 모드',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 프로필 섹션
            _buildSectionHeader(lang.getText('프로필', 'Profile')),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(_userProfile['name'] ?? widget.currentUser ?? '사용자'),
                      subtitle: Text(_userProfile['email'] ?? '${widget.currentUser ?? 'user'}@example.com'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditProfileDialog(context, lang),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 알림 설정 섹션
            _buildSectionHeader(lang.getText('알림 설정', 'Notification Settings')),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(lang.getText('푸시 알림', 'Push Notifications')),
                    subtitle: Text(lang.getText('앱에서 알림을 받습니다', 'Receive notifications from the app')),
                    value: _notificationSettings['push_enabled'] ?? true,
                    onChanged: (value) {
                      setState(() {
                        _notificationSettings['push_enabled'] = value;
                      });
                      _saveNotificationSettings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang.getText('푸시 알림 설정 변경', 'Push notification setting changed'))),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: Text(lang.getText('이메일 알림', 'Email Notifications')),
                    subtitle: Text(lang.getText('이메일로 알림을 받습니다', 'Receive notifications via email')),
                    value: _notificationSettings['email_enabled'] ?? true,
                    onChanged: (value) {
                      setState(() {
                        _notificationSettings['email_enabled'] = value;
                      });
                      _saveNotificationSettings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang.getText('이메일 알림 설정 변경', 'Email notification setting changed'))),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 앱 설정 섹션
            _buildSectionHeader(lang.getText('앱 설정', 'App Settings')),
            Card(
              child: Column(
                children: [
                  Consumer<LanguageProvider>(
                    builder: (context, languageProvider, child) {
                      return ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(lang.getText('언어', 'Language')),
                        subtitle: Text(languageProvider.currentLanguage == 'ko' ? '한국어' : 'English'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showLanguageDialog(context, lang, languageProvider);
                        },
                      );
                    },
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        title: Text(lang.getText('다크 모드', 'Dark Mode')),
                        subtitle: Text(lang.getText('어두운 테마를 사용합니다', 'Use dark theme')),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                          setState(() {
                            _appSettings['dark_mode'] = value;
                          });
                          _saveAppSettings();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(lang.getText('다크 모드 설정 변경', 'Dark mode setting changed'))),
                          );
                        },
                      );
                    },
                  ),
                  SwitchListTile(
                    title: Text(lang.getText('자동 동기화', 'Auto Sync')),
                    subtitle: Text(lang.getText('자동으로 데이터를 동기화합니다', 'Automatically sync data')),
                    value: _appSettings['auto_sync'] ?? true,
                    onChanged: (value) {
                      setState(() {
                        _appSettings['auto_sync'] = value;
                      });
                      _saveAppSettings();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 보안 설정 섹션
            _buildSectionHeader(lang.getText('보안 설정', 'Security Settings')),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(lang.getText('생체 인증', 'Biometric Authentication')),
                    subtitle: Text(lang.getText('지문 또는 얼굴 인식으로 로그인', 'Login with fingerprint or face recognition')),
                    value: _appSettings['biometric_enabled'] ?? false,
                    onChanged: (value) async {
                      if (value) {
                        // 생체 인증 활성화 시 실제 인증 테스트
                        final bool isAvailable = await BiometricService.isBiometricAvailable();
                        if (!isAvailable) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(lang.getText('생체 인증을 사용할 수 없습니다', 'Biometric authentication is not available')),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // 생체 인증 테스트
                        final bool authenticated = await BiometricService.authenticate(
                          localizedReason: lang.getText('생체 인증을 활성화하려면 인증하세요', 'Authenticate to enable biometric authentication'),
                        );

                        if (authenticated) {
                          setState(() {
                            _appSettings['biometric_enabled'] = true;
                          });
                          _saveAppSettings();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(lang.getText('생체 인증이 활성화되었습니다', 'Biometric authentication enabled')),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(lang.getText('생체 인증에 실패했습니다', 'Biometric authentication failed')),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        // 생체 인증 비활성화
                        setState(() {
                          _appSettings['biometric_enabled'] = false;
                        });
                        _saveAppSettings();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang.getText('생체 인증이 비활성화되었습니다', 'Biometric authentication disabled')),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: Text(lang.getText('자동 로그아웃', 'Auto Logout')),
                    subtitle: Text('${_appSettings['auto_logout_minutes'] ?? 30}분'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showAutoLogoutDialog(context, lang),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 계정 관리 섹션
            _buildSectionHeader(lang.getText('계정 관리', 'Account Management')),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.red),
                    title: Text(lang.getText('비밀번호 변경', 'Change Password')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang.getText('비밀번호 변경 기능', 'Change password feature'))),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text(lang.getText('계정 삭제', 'Delete Account')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showDeleteAccountDialog(context, lang),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, LanguageProvider lang) {
    final nameController = TextEditingController(text: _userProfile['name'] ?? '');
    final emailController = TextEditingController(text: _userProfile['email'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('프로필 수정', 'Edit Profile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: lang.getText('이름', 'Name'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: lang.getText('이메일', 'Email'),
                border: const OutlineInputBorder(),
              ),
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
              setState(() {
                _userProfile['name'] = nameController.text;
                _userProfile['email'] = emailController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(lang.getText('프로필이 업데이트되었습니다', 'Profile updated'))),
              );
            },
            child: Text(lang.getText('저장', 'Save')),
          ),
        ],
      ),
    );
  }

  void _showAutoLogoutDialog(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('자동 로그아웃 설정', 'Auto Logout Settings')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang.getText('자동 로그아웃 시간을 선택하세요', 'Select auto logout time')),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: _appSettings['auto_logout_minutes'] ?? 30,
              items: [15, 30, 60, 120, 240].map((minutes) {
                return DropdownMenuItem(
                  value: minutes,
                  child: Text('$minutes분'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _appSettings['auto_logout_minutes'] = value;
                });
                _saveAppSettings();
                Navigator.pop(context);
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
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('계정 삭제', 'Delete Account')),
        content: Text(lang.getText('정말로 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.', 'Are you sure you want to delete your account? This action cannot be undone.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.getText('취소', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(lang.getText('계정 삭제 기능', 'Delete account feature'))),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(lang.getText('삭제', 'Delete')),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNotificationSettings() async {
    try {
      await LocalDatabase.saveNotificationSettings(_notificationSettings);
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider lang, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('언어 선택', 'Select Language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('한국어'),
              value: 'ko',
              groupValue: languageProvider.currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  languageProvider.setLanguage(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lang.getText('언어가 변경되었습니다', 'Language changed'))),
                  );
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: languageProvider.currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  languageProvider.setLanguage(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lang.getText('언어가 변경되었습니다', 'Language changed'))),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.getText('취소', 'Cancel')),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAppSettings() async {
    try {
      await LocalDatabase.saveAppSettings(_appSettings);
    } catch (e) {
      print('Error saving app settings: $e');
    }
  }
}
