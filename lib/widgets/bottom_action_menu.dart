import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/language_manager.dart';

class BottomActionMenu extends StatefulWidget {
  final String currentPage;
  final VoidCallback? onLanguageChange;
  final VoidCallback? onThemeChange;
  final VoidCallback? onSettings;
  final VoidCallback? onProfile;
  final VoidCallback? onNotifications;

  const BottomActionMenu({
    super.key,
    required this.currentPage,
    this.onLanguageChange,
    this.onThemeChange,
    this.onSettings,
    this.onProfile,
    this.onNotifications,
  });

  @override
  State<BottomActionMenu> createState() => _BottomActionMenuState();
}

class _BottomActionMenuState extends State<BottomActionMenu> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isMenuOpen ? 200 : 60,
      child: Stack(
        children: [
          // 메뉴 배경
          if (_isMenuOpen)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 메뉴 헤더
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${l10n.settings} - ${widget.currentPage}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _isMenuOpen = false),
                          icon: const Icon(Icons.close),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                  // 메뉴 아이템들
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: [
                          _buildMenuButton(
                            icon: Icons.language,
                            label: l10n.language,
                            onTap: _showLanguageSelector,
                          ),
                          _buildMenuButton(
                            icon: Icons.dark_mode,
                            label: l10n.darkMode,
                            onTap: widget.onThemeChange,
                          ),
                          _buildMenuButton(
                            icon: Icons.notifications,
                            label: l10n.alarm,
                            onTap: widget.onNotifications,
                          ),
                          _buildMenuButton(
                            icon: Icons.person,
                            label: l10n.profile,
                            onTap: widget.onProfile,
                          ),
                          _buildMenuButton(
                            icon: Icons.settings,
                            label: l10n.settings,
                            onTap: widget.onSettings,
                          ),
                          _buildMenuButton(
                            icon: Icons.help,
                            label: '도움말',
                            onTap: _showHelp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // 메뉴 토글 버튼
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  onTap: () => setState(() => _isMenuOpen = !_isMenuOpen),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isMenuOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isMenuOpen ? '메뉴 닫기' : '메뉴 열기',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '언어 선택',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('한국어'),
              trailing: LanguageManager.currentLocale.languageCode == 'ko'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                LanguageManager.setLanguage(const Locale('ko', 'KR'));
                Navigator.pop(context);
                setState(() => _isMenuOpen = false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              trailing: LanguageManager.currentLocale.languageCode == 'en'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                LanguageManager.setLanguage(const Locale('en', 'US'));
                Navigator.pop(context);
                setState(() => _isMenuOpen = false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('도움말'),
        content: const Text('이 앱의 사용법에 대한 도움말입니다.\n\n• 하단 메뉴를 통해 다양한 설정에 접근할 수 있습니다.\n• 언어 전환, 테마 변경, 알림 설정 등을 할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
