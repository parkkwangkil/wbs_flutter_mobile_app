import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class WbsPage extends StatelessWidget {
  final String projectId;
  const WbsPage({super.key, required this.projectId});

  // 가짜 WBS 데이터
  final List<Map<String, dynamic>> wbsData = const [
    {
      'id': '1',
      'title': '기획',
      'level': 0,
      'progress': 1.0,
      'assignee': 'PM'
    },
    {
      'id': '1.1',
      'title': '요구사항 정의',
      'level': 1,
      'progress': 1.0,
      'assignee': 'PM'
    },
    {
      'id': '2',
      'title': '디자인',
      'level': 0,
      'progress': 0.8,
      'assignee': '디자이너'
    },
    {
      'id': '2.1',
      'title': '와이어프레임',
      'level': 1,
      'progress': 1.0,
      'assignee': '디자이너'
    },
    {
      'id': '2.2',
      'title': 'UI/UX 디자인',
      'level': 1,
      'progress': 0.6,
      'assignee': '디자이너'
    },
    {
      'id': '3',
      'title': '개발',
      'level': 0,
      'progress': 0.4,
      'assignee': '개발자'
    },
    {
      'id': '3.1',
      'title': '백엔드 API 개발',
      'level': 1,
      'progress': 0.7,
      'assignee': '백엔드'
    },
    {
      'id': '3.2',
      'title': '모바일 앱 개발 (Flutter)',
      'level': 1,
      'progress': 0.1,
      'assignee': '프론트'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('WBS - 프로젝트 $projectId', 'WBS - Project $projectId')),
      ),
      body: ListView.builder(
        itemCount: wbsData.length,
        itemBuilder: (context, index) {
          final item = wbsData[index];
          final level = item['level'] as int;
          final progress = item['progress'] as double;

          return ListTile(
            contentPadding: EdgeInsets.only(left: 16.0 + (level * 24.0), right: 16.0),
            leading: Text(item['id'], style: const TextStyle(color: Colors.grey)),
            title: Text(item['title']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress < 0.3 ? Colors.red : progress < 0.7 ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${lang.getText('담당', 'Assignee')}: ${item['assignee']} / ${lang.getText('진척도', 'Progress')}: ${(progress * 100).toInt()}%'),
              ],
            ),
            onTap: () {
              // TODO: 작업 상세 보기 또는 수정 다이얼로그 표시
            },
          );
        },
      ),
    );
  }
}
