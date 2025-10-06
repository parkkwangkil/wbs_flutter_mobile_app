import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class DataAnalysisPage extends StatefulWidget {
  const DataAnalysisPage({super.key});

  @override
  State<DataAnalysisPage> createState() => _DataAnalysisPageState();
}

class _DataAnalysisPageState extends State<DataAnalysisPage> {
  String _selectedPeriod = 'week';
  String _selectedMetric = 'tasks';

  // 가짜 분석 데이터
  final Map<String, dynamic> analysisData = {
    'tasks': {
      'completed': 45,
      'in_progress': 12,
      'pending': 8,
      'total': 65,
    },
    'projects': {
      'active': 3,
      'completed': 7,
      'on_hold': 1,
      'total': 11,
    },
    'team': {
      'active_members': 8,
      'inactive_members': 2,
      'total': 10,
    },
    'time': {
      'total_hours': 240,
      'productive_hours': 180,
      'meeting_hours': 60,
    }
  };

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('데이터 분석', 'Data Analysis')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기간 선택
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.getText('분석 기간', 'Analysis Period'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPeriodButton('week', lang.getText('주간', 'Weekly')),
                        const SizedBox(width: 8),
                        _buildPeriodButton('month', lang.getText('월간', 'Monthly')),
                        const SizedBox(width: 8),
                        _buildPeriodButton('year', lang.getText('연간', 'Yearly')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 메트릭 선택
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.getText('분석 항목', 'Analysis Metrics'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMetricButton('tasks', lang.getText('작업', 'Tasks')),
                        const SizedBox(width: 8),
                        _buildMetricButton('projects', lang.getText('프로젝트', 'Projects')),
                        const SizedBox(width: 8),
                        _buildMetricButton('team', lang.getText('팀', 'Team')),
                        const SizedBox(width: 8),
                        _buildMetricButton('time', lang.getText('시간', 'Time')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 분석 결과 표시
            _buildAnalysisResults(lang),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
      child: Text(label),
    );
  }

  Widget _buildMetricButton(String metric, String label) {
    final isSelected = _selectedMetric == metric;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedMetric = metric;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
      child: Text(label),
    );
  }

  Widget _buildAnalysisResults(LanguageProvider lang) {
    final data = analysisData[_selectedMetric];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.getText('분석 결과', 'Analysis Results'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_selectedMetric == 'tasks') _buildTaskAnalysis(data, lang),
            if (_selectedMetric == 'projects') _buildProjectAnalysis(data, lang),
            if (_selectedMetric == 'team') _buildTeamAnalysis(data, lang),
            if (_selectedMetric == 'time') _buildTimeAnalysis(data, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskAnalysis(Map<String, dynamic> data, LanguageProvider lang) {
    return Column(
      children: [
        _buildStatCard(
          lang.getText('완료된 작업', 'Completed Tasks'),
          data['completed'].toString(),
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('진행 중인 작업', 'In Progress Tasks'),
          data['in_progress'].toString(),
          Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('대기 중인 작업', 'Pending Tasks'),
          data['pending'].toString(),
          Colors.grey,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('총 작업', 'Total Tasks'),
          data['total'].toString(),
          Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildProjectAnalysis(Map<String, dynamic> data, LanguageProvider lang) {
    return Column(
      children: [
        _buildStatCard(
          lang.getText('활성 프로젝트', 'Active Projects'),
          data['active'].toString(),
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('완료된 프로젝트', 'Completed Projects'),
          data['completed'].toString(),
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('보류된 프로젝트', 'On Hold Projects'),
          data['on_hold'].toString(),
          Colors.red,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('총 프로젝트', 'Total Projects'),
          data['total'].toString(),
          Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildTeamAnalysis(Map<String, dynamic> data, LanguageProvider lang) {
    return Column(
      children: [
        _buildStatCard(
          lang.getText('활성 멤버', 'Active Members'),
          data['active_members'].toString(),
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('비활성 멤버', 'Inactive Members'),
          data['inactive_members'].toString(),
          Colors.grey,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('총 멤버', 'Total Members'),
          data['total'].toString(),
          Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildTimeAnalysis(Map<String, dynamic> data, LanguageProvider lang) {
    return Column(
      children: [
        _buildStatCard(
          lang.getText('총 작업 시간', 'Total Work Hours'),
          '${data['total_hours']}h',
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('생산적 시간', 'Productive Hours'),
          '${data['productive_hours']}h',
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('회의 시간', 'Meeting Hours'),
          '${data['meeting_hours']}h',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
