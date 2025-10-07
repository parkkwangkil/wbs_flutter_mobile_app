import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/local_database.dart';
import 'create_event_page.dart';

class ProjectDetailPage extends StatefulWidget {
  final Map<String, dynamic> project;
  
  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  List<Map<String, dynamic>> _events = [];
  double _progress = 0.0;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    final events = await LocalDatabase.getEventsByProject(widget.project['id']);
    final progress = await LocalDatabase.getProjectProgress(widget.project['id']);
    final stats = await LocalDatabase.getProjectEventStats(widget.project['id']);
    
    setState(() {
      _events = events;
      _progress = progress;
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project['name'] ?? '프로젝트 상세'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjectData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로젝트 정보 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '프로젝트 정보',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text('설명: ${widget.project['description'] ?? '설명 없음'}'),
                    const SizedBox(height: 8),
                    Text('시작일: ${widget.project['start_date'] ?? '미정'}'),
                    const SizedBox(height: 8),
                    Text('종료일: ${widget.project['end_date'] ?? '미정'}'),
                    const SizedBox(height: 8),
                    Text('상태: ${_getStatusText(widget.project['status'])}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 진행률 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '진행률',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(_progress),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${(_progress * 100).toStringAsFixed(1)}% 완료'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('전체', _stats['total'] ?? 0, Colors.blue),
                        _buildStatItem('완료', _stats['completed'] ?? 0, Colors.green),
                        _buildStatItem('진행중', _stats['in_progress'] ?? 0, Colors.orange),
                        _buildStatItem('대기', _stats['pending'] ?? 0, Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 이벤트 목록
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '프로젝트 이벤트',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateEventPage(
                                  projectId: widget.project['id'],
                                ),
                              ),
                            );
                            if (result != null) {
                              _loadProjectData();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('이벤트 추가'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_events.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('등록된 이벤트가 없습니다.'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getEventColor(event),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Text(event['title'] ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${event['start_date']} ~ ${event['end_date']}'),
                                  Text('${event['time']} @ ${event['location']}'),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(_getEventStatusText(event['status'])),
                                backgroundColor: _getEventStatusColor(event['status']),
                              ),
                              onTap: () {
                                // 이벤트 상세 보기
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label),
      ],
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'in_progress':
        return '진행중';
      case 'completed':
        return '완료';
      case 'on_hold':
        return '보류';
      default:
        return '알 수 없음';
    }
  }

  String _getEventStatusText(String? status) {
    switch (status) {
      case 'completed':
        return '완료';
      case 'in_progress':
        return '진행중';
      case 'pending':
        return '대기';
      default:
        return '알 수 없음';
    }
  }

  Color _getEventStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green.withOpacity(0.2);
      case 'in_progress':
        return Colors.orange.withOpacity(0.2);
      case 'pending':
        return Colors.grey.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color _getEventColor(Map<String, dynamic> event) {
    if (event['color'] != null) {
      try {
        String colorStr = event['color'].toString();
        if (colorStr.startsWith('#')) {
          colorStr = colorStr.substring(1);
        }
        if (colorStr.length == 6) {
          colorStr = 'FF$colorStr';
        }
        return Color(int.parse(colorStr, radix: 16));
      } catch (e) {
        return Colors.blue;
      }
    }
    return Colors.blue;
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }
}