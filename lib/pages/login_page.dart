import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/local_database.dart';
import '../services/biometric_service.dart';
import '../providers/language_provider.dart';
import 'main_navigation_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 생체 인증 로그인
  Future<void> _biometricLogin() async {
    try {
      // 생체 인증 설정 확인
      final appSettings = await LocalDatabase.getAppSettings();
      if (appSettings['biometric_enabled'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Provider.of<LanguageProvider>(context, listen: false)
                .getText('생체 인증이 활성화되지 않았습니다', 'Biometric authentication is not enabled')),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 생체 인증 실행
      final bool authenticated = await BiometricService.authenticate(
        localizedReason: Provider.of<LanguageProvider>(context, listen: false)
            .getText('생체 인증으로 로그인하세요', 'Authenticate to login'),
      );

      if (authenticated) {
        // 기본 사용자로 로그인 (실제 앱에서는 저장된 사용자 정보 사용)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationPage(currentUser: 'test'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Provider.of<LanguageProvider>(context, listen: false)
                .getText('생체 인증에 실패했습니다', 'Biometric authentication failed')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Provider.of<LanguageProvider>(context, listen: false)
              .getText('생체 인증 중 오류가 발생했습니다', 'Error during biometric authentication')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _performLogin() async {
    // 키보드를 내립니다.
    FocusScope.of(context).unfocus();

    final lang = Provider.of<LanguageProvider>(context, listen: false);
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.getText('사용자명과 비밀번호를 입력해주세요.', 'Please enter username and password.'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(username, password);

      if (!mounted) return;

      if (result['success']) {
        // 로그인 성공 시 메인 네비게이션 페이지로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainNavigationPage(currentUser: username),
          ),
        );
      } else {
        // 로그인 실패 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.getText(result['message'], 'Invalid username or password.')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // 에러 발생 시 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.getText('로그인 중 오류가 발생했습니다.', 'An error occurred during login.')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 언어 설정에 접근합니다.
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getText('로그인', 'Login')),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    languageProvider.getText('WBS 프로젝트 관리', 'WBS Project Management'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 48),
                  // 사용자명 입력 필드
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: languageProvider.getText('사용자명', 'Username'),
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  // 비밀번호 입력 필드
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: languageProvider.getText('비밀번호', 'Password'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _performLogin(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    languageProvider.getText('테스트 계정: test / 1111', 'Test Account: test / 1111'),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  // 로그인 버튼
                  ElevatedButton(
                    onPressed: _isLoading ? null : _performLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(languageProvider.getText('로그인', 'Login')),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(languageProvider.getText('또는', 'OR')),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 생체 인증 로그인 버튼
                  FutureBuilder<bool>(
                    future: BiometricService.isBiometricAvailable(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      
                      if (snapshot.data == true) {
                        return Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await _biometricLogin();
                              },
                              icon: const Icon(Icons.fingerprint),
                              label: Text(languageProvider.getText('생체 인증으로 로그인', 'Login with Biometric')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // 소셜 로그인 버튼
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: Text(languageProvider.getText('소셜 계정으로 로그인', 'Login with Social Account')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  )
                ],
              ),
            ),
          ),
          // 로딩 중일 때 표시될 화면
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
