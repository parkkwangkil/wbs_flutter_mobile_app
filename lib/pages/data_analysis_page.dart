import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/local_database.dart';
import '../services/app_state_service.dart';

class DataAnalysisPage extends StatefulWidget {
  const DataAnalysisPage({super.key});

  @override
  State<DataAnalysisPage> createState() => _DataAnalysisPageState();
}

class _DataAnalysisPageState extends State<DataAnalysisPage> {
  String _selectedPeriod = 'week';
  String _selectedMetric = 'tasks';
  Map<String, dynamic> analysisData = {};
  bool _isLoading = true;
  AppStateService? _appState;

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppStateService 변경사항 감지하여 자동 새로고침
    _appState = Provider.of<AppStateService>(context, listen: false);
    _appState!.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    if (_appState != null) {
      _appState!.removeListener(_onAppStateChanged);
    }
    super.dispose();
  }

  void _onAppStateChanged() {
    // 이벤트나 프로젝트가 변경되었을 때 자동 새로고침
    _loadAnalysisData();
  }

  Future<void> _loadAnalysisData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 실제 데이터베이스에서 데이터 로드
      final events = await LocalDatabase.getEvents();
      final projects = await LocalDatabase.getProjects();
      final ganttTasks = await LocalDatabase.getGanttTasks(null);

      // 이벤트 분석
      final completedEvents = events.where((e) => e['status'] == 'completed').length;
      final inProgressEvents = events.where((e) => e['status'] == 'in_progress').length;
      final pendingEvents = events.where((e) => e['status'] == 'scheduled').length;

      // 프로젝트 분석
      final activeProjects = projects.where((p) => p['status'] == 'in_progress').length;
      final completedProjects = projects.where((p) => p['status'] == 'completed').length;
      final onHoldProjects = projects.where((p) => p['status'] == 'on_hold').length;

      // 시간 분석 (회의 시간 계산)
      int meetingHours = 0;
      for (var event in events) {
        if (event['title']?.toString().toLowerCase().contains('회의') == true) {
          // 이벤트 기간 계산 (간단히 1시간으로 가정)
          meetingHours += 1;
        }
      }

      // 총 작업 시간 (간트 작업 기반)
      int totalWorkHours = ganttTasks.length * 8; // 작업당 8시간 가정
      int productiveHours = (totalWorkHours * 0.75).round(); // 75% 생산성

      setState(() {
        analysisData = {
          'tasks': {
            'completed': completedEvents,
            'in_progress': inProgressEvents,
            'pending': pendingEvents,
            'total': events.length,
          },
          'projects': {
            'active': activeProjects,
            'completed': completedProjects,
            'on_hold': onHoldProjects,
            'total': projects.length,
          },
          'time': {
            'total_hours': totalWorkHours,
            'productive_hours': productiveHours,
            'meeting_hours': meetingHours,
          }
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analysis data: $e');
      setState(() {
        analysisData = {
          'tasks': {'completed': 0, 'in_progress': 0, 'pending': 0, 'total': 0},
          'projects': {'active': 0, 'completed': 0, 'on_hold': 0, 'total': 0},
          'time': {'total_hours': 0, 'productive_hours': 0, 'meeting_hours': 0}
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('데이터 분석', 'Data Analysis')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalysisData,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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
            if (_selectedMetric == 'tasks') _buildTaskAnalysis(analysisData, lang),
            if (_selectedMetric == 'projects') _buildProjectAnalysis(analysisData, lang),
            if (_selectedMetric == 'team') _buildTeamAnalysis(analysisData, lang),
            if (_selectedMetric == 'time') _buildTimeAnalysis(analysisData, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskAnalysis(Map<String, dynamic> data, LanguageProvider lang) {
    if (data.isEmpty || data['tasks'] == null) {
      return const Center(child: Text('데이터가 없습니다'));
    }
    
    final tasks = data['tasks'] as Map<String, dynamic>;
    return Column(
      children: [
        _buildStatCard(
          lang.getText('완료된 작업', 'Completed Tasks'),
          tasks['completed'].toString(),
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('진행 중인 작업', 'In Progress Tasks'),
          tasks['in_progress'].toString(),
          Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('대기 중인 작업', 'Pending Tasks'),
          tasks['pending'].toString(),
          Colors.grey,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('총 작업', 'Total Tasks'),
          tasks['total'].toString(),
          Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildProjectAnalysis(Map<String, dynamic> data, LanguageProvider lang) {
    if (data.isEmpty || data['projects'] == null) {
      return const Center(child: Text('데이터가 없습니다'));
    }
    
    final projects = data['projects'] as Map<String, dynamic>;
    return Column(
      children: [
        _buildStatCard(
          lang.getText('활성 프로젝트', 'Active Projects'),
          projects['active'].toString(),
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('완료된 프로젝트', 'Completed Projects'),
          projects['completed'].toString(),
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('보류된 프로젝트', 'On Hold Projects'),
          projects['on_hold'].toString(),
          Colors.red,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('총 프로젝트', 'Total Projects'),
          projects['total'].toString(),
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
    if (data.isEmpty || data['time'] == null) {
      return const Center(child: Text('데이터가 없습니다'));
    }
    
    final time = data['time'] as Map<String, dynamic>;
    return Column(
      children: [
        _buildStatCard(
          lang.getText('총 작업 시간', 'Total Work Hours'),
          '${time['total_hours']}h',
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('생산적 시간', 'Productive Hours'),
          '${time['productive_hours']}h',
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          lang.getText('회의 시간', 'Meeting Hours'),
          '${time['meeting_hours']}h',
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
