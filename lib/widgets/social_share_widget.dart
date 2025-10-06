import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class SocialShareWidget extends StatelessWidget {
  final String contentToShare;

  const SocialShareWidget({
    super.key,
    required this.contentToShare,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              lang.getText('결과 공유하기', 'Share Results'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              contentToShare,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareButton(
                  context,
                  icon: Icons.share, // 실제로는 각 소셜 아이콘 사용
                  label: 'Facebook',
                  onTap: () {
                    // TODO: Facebook 공유 로직 구현
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Facebook으로 공유: $contentToShare')));
                  },
                ),
                _buildShareButton(
                  context,
                  icon: Icons.chat_bubble,
                  label: 'Kakao',
                  onTap: () {
                    // TODO: Kakao 공유 로직 구현
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Kakao로 공유: $contentToShare')));
                  },
                ),
                _buildShareButton(
                  context,
                  icon: Icons.link,
                  label: lang.getText('링크 복사', 'Copy Link'),
                  onTap: () {
                    // TODO: 클립보드에 링크 복사 로직 구현
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(lang.getText(
                            '링크가 복사되었습니다.', 'Link copied to clipboard.'))));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
