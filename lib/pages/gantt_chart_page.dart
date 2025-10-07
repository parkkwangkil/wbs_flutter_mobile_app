import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/local_database.dart';
import '../widgets/personal_team_gantt.dart';
import 'create_event_page.dart';

class GanttChartPage extends StatefulWidget {
  final String? projectId;
  const GanttChartPage({super.key, this.projectId});

  @override
  State<GanttChartPage> createState() => _GanttChartPageState();
}

class _GanttChartPageState extends State<GanttChartPage> {
  List<Map<String, dynamic>> ganttData = [];
  bool _isLoading = true;
  String? _selectedProjectId;
  List<Map<String, dynamic>> _projects = [];
  int _refreshKey = 0; // 새로고침을 위한 키

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
    _loadProjects();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 페이지가 다시 포커스될 때 프로젝트 목록 새로고침
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      // 샘플 프로젝트 생성 (데이터가 없을 경우)
      await LocalDatabase.createSampleProjects();
      final projects = await LocalDatabase.getProjects();
      setState(() {
        _projects = projects;
        if (_selectedProjectId == null && projects.isNotEmpty) {
          _selectedProjectId = projects.first['id']?.toString();
        }
      });
      if (_selectedProjectId != null) {
        _loadProjectEvents();
      }
    } catch (e) {
      print('Error loading projects: $e');
    }
  }

  Future<void> _loadProjectEvents() async {
    if (_selectedProjectId == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 이벤트와 간트 차트 작업 동기화
      await LocalDatabase.syncEventsToGanttTasks(_selectedProjectId!);
      
      // 간트 차트 작업 가져오기
      final tasks = await LocalDatabase.getGanttTasks(_selectedProjectId!);
      
      // 간트차트 형식으로 변환
      final now = DateTime.now();
      ganttData = tasks.map((task) {
        final startDate = DateTime.parse(task['start_date'] ?? now.toIso8601String().split('T')[0]);
        final endDate = DateTime.parse(task['end_date'] ?? now.add(const Duration(days: 1)).toIso8601String().split('T')[0]);
        final startDay = startDate.difference(now).inDays;
        final duration = endDate.difference(startDate).inDays;
        
        return {
          'id': task['id'],
          'title': task['title'] ?? '제목 없음',
          'start': startDay,
          'end': startDay + duration,
          'color': _getColorFromString(task['color'] ?? 'blue'),
          'progress': task['progress'] ?? 0.0,
          'assignee': task['assignee'] ?? '담당자',
        };
      }).toList();
    } catch (e) {
      print('Error loading project events: $e');
      ganttData = [];
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Color _getColorFromString(String colorStr) {
    switch (colorStr.toLowerCase()) {
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(lang.getText('간트 차트', 'Gantt Chart')),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedProjectId != null 
            ? lang.getText('간트 차트 - 프로젝트 $_selectedProjectId', 'Gantt Chart - Project $_selectedProjectId')
            : lang.getText('간트 차트', 'Gantt Chart')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _loadProjects();
            },
            tooltip: lang.getText('새로고침', 'Refresh'),
          ),
          if (_projects.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.folder),
              onSelected: (String projectId) {
                setState(() {
                  _selectedProjectId = projectId;
                });
                _loadProjectEvents();
              },
              itemBuilder: (BuildContext context) {
                return _projects.map((project) {
                  return PopupMenuItem<String>(
                    value: project['id']?.toString() ?? '',
                    child: Text(project['name'] ?? '제목 없음'),
                  );
                }).toList();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 개인 WBS
            PersonalTeamGantt(
              key: ValueKey('personal_${_selectedProjectId}_$_refreshKey'),
              projectId: _selectedProjectId,
              isPersonal: true,
            ),
            
            const SizedBox(height: 16),
            
            // 팀 WBS
            PersonalTeamGantt(
              key: ValueKey('team_${_selectedProjectId}_$_refreshKey'),
              projectId: _selectedProjectId,
              isPersonal: false,
            ),
            
            const SizedBox(height: 16),
            
          ],
        ),
      ),
      floatingActionButton: _selectedProjectId != null
          ? FloatingActionButton(
              heroTag: "gantt_fab",
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(
                      projectId: _selectedProjectId!,
                    ),
                  ),
                );
                if (result != null) {
                  _loadProjectEvents();
                  // PersonalTeamGantt 위젯들 강제 새로고침
                  setState(() {
                    _refreshKey++;
                  });
                }
              },
              child: const Icon(Icons.add),
              tooltip: lang.getText('이벤트 추가', 'Add Event'),
            )
          : null,
    );
  }
}