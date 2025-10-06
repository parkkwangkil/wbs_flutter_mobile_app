import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class ProjectDetailPage extends StatelessWidget {
  final Map<String, dynamic> project;
  
  const ProjectDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(project['name'] ?? '프로젝트 상세'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/edit_project',
                arguments: project,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로젝트 기본 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.getText('프로젝트 정보', 'Project Information'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      lang.getText('프로젝트명', 'Project Name'),
                      project['name'] ?? '',
                    ),
                    _buildInfoRow(
                      context,
                      lang.getText('설명', 'Description'),
                      project['description'] ?? '',
                    ),
                    _buildInfoRow(
                      context,
                      lang.getText('상태', 'Status'),
                      _getStatusText(lang, project['status']),
                    ),
                    _buildInfoRow(
                      context,
                      lang.getText('시작일', 'Start Date'),
                      project['start_date'] ?? '',
                    ),
                    _buildInfoRow(
                      context,
                      lang.getText('종료일', 'End Date'),
                      project['end_date'] ?? '',
                    ),
                    _buildInfoRow(
                      context,
                      lang.getText('생성일', 'Created Date'),
                      project['created_at'] ?? '',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 프로젝트 진행률
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.getText('진행률', 'Progress'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _getProgressValue(project['status']),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(project['status']),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_getProgressValue(project['status']) * 100).toInt()}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 팀 멤버 관리 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(lang.getText('팀 멤버 관리 기능은 준비 중입니다.', 'Team management feature is under development.')),
                        ),
                      );
                    },
                    icon: const Icon(Icons.group),
                    label: Text(lang.getText('팀 관리', 'Team Management')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 간트 차트 페이지로 이동
                      Navigator.pushNamed(context, '/gantt_chart');
                    },
                    icon: const Icon(Icons.timeline),
                    label: Text(lang.getText('간트 차트', 'Gantt Chart')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getStatusText(LanguageProvider lang, String? status) {
    switch (status) {
      case 'active':
        return lang.getText('진행 중', 'Active');
      case 'completed':
        return lang.getText('완료', 'Completed');
      case 'on_hold':
        return lang.getText('보류', 'On Hold');
      case 'in_progress':
        return lang.getText('진행 중', 'In Progress');
      default:
        return lang.getText('알 수 없음', 'Unknown');
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'on_hold':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  double _getProgressValue(String? status) {
    switch (status) {
      case 'completed':
        return 1.0;
      case 'active':
      case 'in_progress':
        return 0.6;
      case 'on_hold':
        return 0.3;
      default:
        return 0.0;
    }
  }
}