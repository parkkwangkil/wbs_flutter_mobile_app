import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../providers/language_provider.dart';
// import 'project_list_page.dart';
import 'main_navigation_page.dart';
import 'social_login_page.dart'; // 소셜 로그인 페이지를 임포트합니다.

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
                    languageProvider.getText('테스트 계정: devops / devops123', 'Test Account: devops / devops123'),
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
                  // 소셜 로그인 버튼
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SocialLoginPage()),
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
