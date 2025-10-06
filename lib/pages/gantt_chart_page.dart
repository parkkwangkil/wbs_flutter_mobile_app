import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class GanttChartPage extends StatefulWidget {
  final String projectId;
  const GanttChartPage({super.key, required this.projectId});

  @override
  State<GanttChartPage> createState() => _GanttChartPageState();
}

class _GanttChartPageState extends State<GanttChartPage> {
  // 간트 차트 데이터
  List<Map<String, dynamic>> ganttData = [
    {
      'id': '1',
      'title': '프로젝트 기획',
      'start': 0,
      'end': 4,
      'color': Colors.blue,
      'progress': 0.8,
      'assignee': '김기획',
    },
    {
      'id': '2',
      'title': 'UI/UX 디자인',
      'start': 2,
      'end': 8,
      'color': Colors.green,
      'progress': 0.6,
      'assignee': '이디자인',
    },
    {
      'id': '3',
      'title': '프론트엔드 개발',
      'start': 6,
      'end': 16,
      'color': Colors.orange,
      'progress': 0.4,
      'assignee': '박프론트',
    },
    {
      'id': '4',
      'title': '백엔드 개발',
      'start': 8,
      'end': 18,
      'color': Colors.red,
      'progress': 0.3,
      'assignee': '최백엔드',
    },
    {
      'id': '5',
      'title': '통합 테스트',
      'start': 16,
      'end': 20,
      'color': Colors.purple,
      'progress': 0.1,
      'assignee': '정테스트',
    },
    {
      'id': '6',
      'title': '배포 및 런칭',
      'start': 20,
      'end': 22,
      'color': Colors.teal,
      'progress': 0.0,
      'assignee': '한배포',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  // 프로젝트 데이터 로드
  void _loadProjectData() {
    // 실제 프로젝트 데이터를 로드하는 로직
    // 현재는 가짜 데이터를 사용
  }

  // 프로젝트별 진행률 계산
  double getProjectProgress() {
    if (ganttData.isEmpty) return 0.0;
    double totalProgress = 0.0;
    for (var task in ganttData) {
      totalProgress += (task['progress'] ?? 0.0) as double;
    }
    return totalProgress / ganttData.length;
  }

  // 새 작업 추가 다이얼로그
  void _showAddTaskDialog(BuildContext context, LanguageProvider lang) {
    final titleController = TextEditingController();
    final assigneeController = TextEditingController();
    int startWeek = 0;
    int endWeek = 4;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(lang.getText('새 작업 추가', 'Add New Task')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: lang.getText('작업명', 'Task Name'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: assigneeController,
                      decoration: InputDecoration(
                        labelText: lang.getText('담당자', 'Assignee'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: lang.getText('시작 주', 'Start Week'),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              startWeek = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: lang.getText('종료 주', 'End Week'),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              endWeek = int.tryParse(value) ?? 4;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(lang.getText('색상 선택', 'Select Color')),
                    const SizedBox(height: 8),
                    Wrap(
                      children: [
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.red,
                        Colors.purple,
                        Colors.teal,
                      ].map((color) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(lang.getText('취소', 'Cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      setState(() {
                        ganttData.add({
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'title': titleController.text,
                          'start': startWeek,
                          'end': endWeek,
                          'color': selectedColor,
                          'progress': 0.0,
                          'assignee': assigneeController.text,
                        });
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(lang.getText('작업이 추가되었습니다.', 'Task added successfully.')),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text(lang.getText('추가', 'Add')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    const totalWeeks = 28; // 전체 프로젝트 기간 (주)
    final double weekWidth = 40.0; // 고정된 주 너비

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('간트 차트', 'Gantt Chart')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context, lang),
          ),
        ],
      ),
      body: Column(
        children: [
          // 타임라인 헤더 (주 표시)
          Container(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(totalWeeks, (index) {
                  return Container(
                    width: weekWidth,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade300),
                        bottom: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'W${index + 1}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          
          // 간트 차트 바
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ganttData.map((task) {
                  final duration = task['end'] - task['start'];
                  final progress = task['progress'] as double;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // 작업명
                        Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            task['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // 간트 바
                        Stack(
                          children: [
                            // 배경 바
                            Container(
                              width: duration * weekWidth,
                              height: 30,
                              decoration: BoxDecoration(
                                color: (task['color'] as Color).withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: task['color'] as Color),
                              ),
                            ),
                            // 진행률 바
                            Container(
                              width: (duration * weekWidth) * progress,
                              height: 30,
                              decoration: BoxDecoration(
                                color: task['color'] as Color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // 담당자 표시
                            Positioned(
                              left: 4,
                              top: 4,
                              child: Text(
                                task['assignee'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // 진행률 요약
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.getText('프로젝트 진행률', 'Project Progress'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: getProjectProgress(),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(getProjectProgress() * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}