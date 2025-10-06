import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/social_service.dart';
import '../providers/language_provider.dart';
import 'project_list_page.dart';

class SocialLoginPage extends StatefulWidget {
  const SocialLoginPage({super.key});

  @override
  State<SocialLoginPage> createState() => _SocialLoginPageState();
}

class _SocialLoginPageState extends State<SocialLoginPage> {
  bool _isLoading = false;
  String? _loadingPlatform;

  Future<void> _performSocialLogin(Future<Map<String, dynamic>> loginFuture, String platform) async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _loadingPlatform = platform;
    });

    try {
      final result = await loginFuture;

      if (!mounted) return;

      if (result['success']) {
        final user = result['user'] as Map<String, dynamic>;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => ProjectListPage(currentUser: user['name'])),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? lang.getText('로그인에 실패했습니다.', 'Login failed.')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.getText('오류가 발생했습니다.', 'An error occurred.')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingPlatform = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('소셜 계정으로 로그인', 'Login with Social Account')),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSocialButton(
                  platform: 'Google',
                  onPressed: () => _performSocialLogin(SocialService.loginWithGoogle(), 'Google'),
                  iconPath: 'assets/google_logo.png', // 가상 경로, 실제 이미지 파일 추가 필요
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  lang: lang,
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  platform: 'Naver',
                  onPressed: () => _performSocialLogin(SocialService.loginWithNaver(), 'Naver'),
                  iconPath: 'assets/naver_logo.png', // 가상 경로
                  backgroundColor: const Color(0xFF03C75A),
                  textColor: Colors.white,
                  lang: lang,
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  platform: 'Kakao',
                  onPressed: () => _performSocialLogin(SocialService.loginWithKakao(), 'Kakao'),
                  iconPath: 'assets/kakao_logo.png', // 가상 경로
                  backgroundColor: const Color(0xFFFFE812),
                  textColor: Colors.black,
                  lang: lang,
                ),
              ],
            ),
          ),
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

  Widget _buildSocialButton({
    required String platform,
    required VoidCallback onPressed,
    required String iconPath,
    required Color backgroundColor,
    required Color textColor,
    required LanguageProvider lang,
  }) {
    final isThisLoading = _isLoading && _loadingPlatform == platform;

    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isThisLoading
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset(iconPath, height: 24), // 실제 이미지 사용 시 주석 해제
                Icon(platform == 'Google' ? Icons.g_mobiledata : platform == 'Naver' ? Icons.near_me : Icons.chat_bubble, size: 24), // 임시 아이콘
                const SizedBox(width: 12),
                Text(lang.getText('$platform 계정으로 계속하기', 'Continue with $platform')),
              ],
            ),
    );
  }
}
