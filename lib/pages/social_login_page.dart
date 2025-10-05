import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/social_service.dart';
import '../services/api_service.dart';
import '../main.dart';

class SocialLoginPage extends StatefulWidget {
  const SocialLoginPage({super.key});

  @override
  State<SocialLoginPage> createState() => _SocialLoginPageState();
}

class SocialLoginSettingsPage extends StatefulWidget {
  const SocialLoginSettingsPage({super.key});

  @override
  State<SocialLoginSettingsPage> createState() => _SocialLoginSettingsPageState();
}

class _SocialLoginSettingsPageState extends State<SocialLoginSettingsPage> {
  final _googleClientIdController = TextEditingController();
  final _naverClientIdController = TextEditingController();
  final _kakaoClientIdController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  void _loadSettings() async {
    // 저장된 설정 불러오기
    final prefs = await SharedPreferences.getInstance();
    _googleClientIdController.text = prefs.getString('google_client_id') ?? 'Google Client ID를 입력하세요';
    _naverClientIdController.text = prefs.getString('naver_client_id') ?? 'Naver Client ID를 입력하세요';
    _kakaoClientIdController.text = prefs.getString('kakao_client_id') ?? 'Kakao Client ID를 입력하세요';
  }
  
  void _saveSettings() async {
    // SharedPreferences에 설정 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('google_client_id', _googleClientIdController.text);
    await prefs.setString('naver_client_id', _naverClientIdController.text);
    await prefs.setString('kakao_client_id', _kakaoClientIdController.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('소셜 로그인 설정이 저장되었습니다')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소셜 로그인 설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '소셜 로그인 API 키 설정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Google 설정
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.login, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('Google 로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _googleClientIdController,
                      decoration: const InputDecoration(
                        labelText: 'Google Client ID',
                        border: OutlineInputBorder(),
                        hintText: 'Google Console에서 발급받은 Client ID',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Google Cloud Console에서 OAuth 2.0 클라이언트 ID를 발급받아 입력하세요.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Naver 설정
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.login, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Naver 로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _naverClientIdController,
                      decoration: const InputDecoration(
                        labelText: 'Naver Client ID',
                        border: OutlineInputBorder(),
                        hintText: 'Naver Developers에서 발급받은 Client ID',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Naver Developers Console에서 애플리케이션을 등록하고 Client ID를 발급받아 입력하세요.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Kakao 설정
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.login, color: Colors.yellow),
                        const SizedBox(width: 8),
                        const Text('Kakao 로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _kakaoClientIdController,
                      decoration: const InputDecoration(
                        labelText: 'Kakao Client ID',
                        border: OutlineInputBorder(),
                        hintText: 'Kakao Developers에서 발급받은 Client ID',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kakao Developers Console에서 애플리케이션을 등록하고 Client ID를 발급받아 입력하세요.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('설정 저장'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 도움말
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '도움말',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Google: https://console.cloud.google.com/\n'
                      '2. Naver: https://developers.naver.com/\n'
                      '3. Kakao: https://developers.kakao.com/',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLoginPageState extends State<SocialLoginPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소셜 로그인'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.group,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            const Text(
              '소셜 계정으로 로그인',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Google, Naver, Kakao 계정으로\n간편하게 로그인하세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            
            // Google 로그인
            _buildSocialButton(
              'Google로 로그인',
              Colors.red,
              Icons.g_mobiledata,
              () => _loginWithProvider('google'),
            ),
            const SizedBox(height: 16),
            
            // Naver 로그인
            _buildSocialButton(
              'Naver로 로그인',
              Colors.green,
              Icons.nat,
              () => _loginWithProvider('naver'),
            ),
            const SizedBox(height: 16),
            
            // Kakao 로그인
            _buildSocialButton(
              'Kakao로 로그인',
              Colors.yellow,
              Icons.chat,
              () => _loginWithProvider('kakao'),
            ),
            
            const SizedBox(height: 32),
            
            if (_isLoading)
              const CircularProgressIndicator()
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, Color color, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginWithProvider(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic>? userData;
      
      switch (provider) {
        case 'google':
          userData = await SocialService.loginWithGoogle();
          break;
        case 'naver':
          userData = await SocialService.loginWithNaver();
          break;
        case 'kakao':
          userData = await SocialService.loginWithKakao();
          break;
      }

      if (userData != null) {
        // 사용자 정보를 ApiService에 저장
        await ApiService.addUser(
          username: userData['username'] ?? userData['email'],
          password: userData['password'] ?? 'social_login',
          email: userData['email'],
          firstName: userData['firstName'] ?? userData['name'],
          lastName: userData['lastName'] ?? '',
          department: userData['department'] ?? 'Social',
        );
        
        // 로그인 성공
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectListPage(currentUser: userData?['username'] ?? userData?['email']),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
