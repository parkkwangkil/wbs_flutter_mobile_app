import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 어시스턴트'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI 어시스턴트와 대화하여 프로젝트 관리에 도움을 받으세요!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAiCard(
                    context,
                    'Claude AI',
                    'Anthropic의 강력한 AI',
                    Icons.smart_toy,
                    Colors.blue,
                    'https://claude.ai/chat',
                    '프로젝트 계획, 업무 분해, 문서 작성에 특화',
                  ),
                  _buildAiCard(
                    context,
                    'ChatGPT',
                    'OpenAI의 인기 AI',
                    Icons.chat,
                    Colors.green,
                    'https://chat.openai.com/',
                    '다양한 주제의 질문과 답변, 창의적 아이디어',
                  ),
                  _buildAiCard(
                    context,
                    'Gemini',
                    'Google의 AI 어시스턴트',
                    Icons.auto_awesome,
                    Colors.orange,
                    'https://gemini.google.com/',
                    '검색과 정보 분석, 실시간 데이터 활용',
                  ),
                  _buildAiCard(
                    context,
                    'Copilot',
                    'Microsoft의 AI 코딩 어시스턴트',
                    Icons.code,
                    Colors.purple,
                    'https://copilot.microsoft.com/',
                    '코딩, 개발, 기술적 문제 해결',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 사용 팁',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 각 AI는 서로 다른 강점을 가지고 있습니다\n'
                    '• 프로젝트 관리: Claude AI 추천\n'
                    '• 창의적 아이디어: ChatGPT 추천\n'
                    '• 정보 검색: Gemini 추천\n'
                    '• 개발 관련: Copilot 추천',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String url,
    String description,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openAiWebsite(context, title, url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '열기',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAiWebsite(BuildContext context, String aiName, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar(context, '$aiName 웹사이트를 열 수 없습니다.');
      }
    } catch (e) {
      _showErrorSnackBar(context, '오류가 발생했습니다: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
