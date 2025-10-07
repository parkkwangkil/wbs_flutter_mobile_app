import 'package:flutter/material.dart';
import 'visual_gantt_chart.dart';
import '../services/local_database.dart';

class PersonalTeamGantt extends StatefulWidget {
  final String? projectId;
  final bool isPersonal;
  
  const PersonalTeamGantt({
    super.key,
    this.projectId,
    this.isPersonal = true,
  });

  @override
  State<PersonalTeamGantt> createState() => _PersonalTeamGanttState();
}

class _PersonalTeamGanttState extends State<PersonalTeamGantt> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didUpdateWidget(PersonalTeamGantt oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 프로젝트 ID가 변경되었을 때 새로고침
    if (oldWidget.projectId != widget.projectId) {
      _loadTasks();
    }
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 프로젝트가 있으면 이벤트와 동기화
      if (widget.projectId != null) {
        await LocalDatabase.syncEventsToGanttTasks(widget.projectId!);
        final allTasks = await LocalDatabase.getGanttTasks(widget.projectId);
        
        // 개인/팀 구분에 따라 필터링
        _tasks = allTasks.where((task) {
          final assignee = task['assignee'] ?? '';
          if (widget.isPersonal) {
            // 개인 WBS: 개인 담당자만 표시
            return assignee.contains('나') || assignee.contains('개인') || assignee.isEmpty;
          } else {
            // 팀 WBS: 팀 담당자만 표시
            return assignee.contains('팀') || assignee.contains('기획팀') || 
                   assignee.contains('개발팀') || assignee.contains('QA팀') ||
                   assignee.contains('디자인팀');
          }
        }).toList();
        
        // 데이터베이스에서 작업을 찾지 못했으면 빈 목록 유지
        // (샘플 데이터 대신 실제 데이터만 표시)
      } else {
        // 프로젝트가 없으면 샘플 데이터 생성
        final now = DateTime.now();
        _tasks = [
          {
            'id': '1',
            'title': '기획',
            'start_date': now.toIso8601String().split('T')[0],
            'end_date': now.add(const Duration(days: 20)).toIso8601String().split('T')[0],
            'color': 'blue',
            'progress': 0.3,
            'assignee': widget.isPersonal ? '나' : '기획팀',
            'project_id': widget.projectId,
          },
          {
            'id': '2',
            'title': '개발',
            'start_date': now.add(const Duration(days: 21)).toIso8601String().split('T')[0],
            'end_date': now.add(const Duration(days: 40)).toIso8601String().split('T')[0],
            'color': 'green',
            'progress': 0.0,
            'assignee': widget.isPersonal ? '나' : '개발팀',
            'project_id': widget.projectId,
          },
          {
            'id': '3',
            'title': '테스트',
            'start_date': now.add(const Duration(days: 41)).toIso8601String().split('T')[0],
            'end_date': now.add(const Duration(days: 50)).toIso8601String().split('T')[0],
            'color': 'orange',
            'progress': 0.0,
            'assignee': widget.isPersonal ? '나' : 'QA팀',
            'project_id': widget.projectId,
          },
        ];
      }

      // 날짜 범위 계산
      if (_tasks.isNotEmpty) {
        final startDates = _tasks.map((task) => DateTime.parse(task['start_date'])).toList();
        final endDates = _tasks.map((task) => DateTime.parse(task['end_date'])).toList();
        
        _startDate = startDates.reduce((a, b) => a.isBefore(b) ? a : b);
        _endDate = endDates.reduce((a, b) => a.isAfter(b) ? a : b);
      }
    } catch (e) {
      print('Error loading gantt tasks: $e');
      _tasks = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _createSampleTasks() {
    final now = DateTime.now();
    return [
      {
        'id': '1',
        'title': '기획',
        'start_date': now.toIso8601String().split('T')[0],
        'end_date': now.add(const Duration(days: 20)).toIso8601String().split('T')[0],
        'color': 'blue',
        'progress': 0.3,
        'assignee': widget.isPersonal ? '나' : '기획팀',
        'project_id': widget.projectId,
      },
      {
        'id': '2',
        'title': '개발',
        'start_date': now.add(const Duration(days: 21)).toIso8601String().split('T')[0],
        'end_date': now.add(const Duration(days: 40)).toIso8601String().split('T')[0],
        'color': 'green',
        'progress': 0.0,
        'assignee': widget.isPersonal ? '나' : '개발팀',
        'project_id': widget.projectId,
      },
      {
        'id': '3',
        'title': '테스트',
        'start_date': now.add(const Duration(days: 41)).toIso8601String().split('T')[0],
        'end_date': now.add(const Duration(days: 50)).toIso8601String().split('T')[0],
        'color': 'orange',
        'progress': 0.0,
        'assignee': widget.isPersonal ? '나' : 'QA팀',
        'project_id': widget.projectId,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 개인/팀 구분 헤더
            Row(
              children: [
                Icon(
                  widget.isPersonal ? Icons.person : Icons.group,
                  color: widget.isPersonal ? Colors.blue : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isPersonal ? '개인 WBS' : '팀 WBS',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_tasks.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.isPersonal ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_tasks.length}개 작업',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isPersonal ? Colors.blue[800] : Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 내용
            Column(
                children: [
                  // 간트 차트
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_tasks.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.timeline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '작업이 없습니다',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  else
                    _buildSimpleGanttChart(),
                  
                  const SizedBox(height: 16),
                  
                  // 작업 목록
                  if (_tasks.isNotEmpty) ...[
                    const Text(
                      '작업 목록',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._tasks.map((task) => _buildTaskItem(task)).toList(),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final startDate = DateTime.parse(task['start_date']);
    final endDate = DateTime.parse(task['end_date']);
    final progress = task['progress'] ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getTaskColor(task['color'] ?? 'blue').withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getTaskColor(task['color'] ?? 'blue').withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // 색상 표시
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getTaskColor(task['color'] ?? 'blue'),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          
          // 작업 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task['assignee']} • ${startDate.month}/${startDate.day} - ${endDate.month}/${endDate.day}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                // 진행률 바
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getTaskColor(task['color'] ?? 'blue'),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(progress * 100).toInt()}% 완료',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleGanttChart() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: const Text(
                    '작업명',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: const Text(
                      '진행률',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 작업 목록
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final progress = task['progress'] ?? 0.0;
                final startDate = DateTime.parse(task['start_date']);
                final endDate = DateTime.parse(task['end_date']);
                
                return Container(
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      // 작업명
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              task['title'],
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${startDate.month}/${startDate.day} - ${endDate.month}/${endDate.day}',
                              style: TextStyle(fontSize: 7, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      // 진행률 바
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getTaskColor(task['color'] ?? 'blue'),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(String colorStr) {
    switch (colorStr.toLowerCase()) {
      case 'red': return Colors.red[400]!;
      case 'green': return Colors.green[400]!;
      case 'blue': return Colors.blue[400]!;
      case 'orange': return Colors.orange[400]!;
      case 'purple': return Colors.purple[400]!;
      case 'yellow': return Colors.yellow[600]!;
      case 'pink': return Colors.pink[400]!;
      case 'teal': return Colors.teal[400]!;
      default: return Colors.blue[400]!;
    }
  }
}
