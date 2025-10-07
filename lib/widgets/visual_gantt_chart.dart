import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VisualGanttChart extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final DateTime startDate;
  final DateTime endDate;
  final String? projectId;
  
  const VisualGanttChart({
    super.key,
    required this.tasks,
    required this.startDate,
    required this.endDate,
    this.projectId,
  });

  @override
  State<VisualGanttChart> createState() => _VisualGanttChartState();
}

class _VisualGanttChartState extends State<VisualGanttChart> {
  double _scale = 1.0;
  DateTime _viewStartDate = DateTime.now();
  DateTime _viewEndDate = DateTime.now().add(const Duration(days: 30));
  
  @override
  void initState() {
    super.initState();
    _viewStartDate = widget.startDate;
    _viewEndDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 상단 날짜 헤더
          _buildDateHeader(),
          // 간트 차트 본체
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _calculateTotalWidth(),
                child: Column(
                  children: [
                    // 작업 목록과 타임라인
                    ...widget.tasks.map((task) => _buildTaskRow(task)).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final days = _viewEndDate.difference(_viewStartDate).inDays;
    final dayWidth = 30.0 * _scale;
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // 작업명 헤더
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: const Text(
              '작업명',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // 날짜 헤더
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _calculateTotalWidth(),
                child: Row(
                  children: List.generate(days + 1, (index) {
                    final date = _viewStartDate.add(Duration(days: index));
                    return Container(
                      width: dayWidth,
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.grey[200]!)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('M/d').format(date),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('E').format(date),
                            style: TextStyle(fontSize: 8, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskRow(Map<String, dynamic> task) {
    final taskStartDate = DateTime.parse(task['start_date'] ?? DateTime.now().toIso8601String().split('T')[0]);
    final taskEndDate = DateTime.parse(task['end_date'] ?? DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0]);
    final progress = task['progress'] ?? 0.0;
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // 작업명
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  task['title'] ?? '제목 없음',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${DateFormat('M/d').format(taskStartDate)} - ${DateFormat('M/d').format(taskEndDate)}',
                  style: TextStyle(fontSize: 8, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // 간트 차트 바
          Expanded(
            child: Stack(
              children: [
                // 배경 그리드
                _buildBackgroundGrid(),
                // 작업 바
                _buildTaskBar(task, taskStartDate, taskEndDate, progress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGrid() {
    final days = _viewEndDate.difference(_viewStartDate).inDays;
    final dayWidth = 30.0 * _scale;
    
    return SizedBox(
      width: _calculateTotalWidth(),
      child: Row(
        children: List.generate(days + 1, (index) {
          return Container(
            width: dayWidth,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey[200]!)),
              color: index % 7 == 0 ? Colors.grey[100] : Colors.white,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTaskBar(Map<String, dynamic> task, DateTime startDate, DateTime endDate, double progress) {
    final taskStartDay = startDate.difference(_viewStartDate).inDays;
    final taskDuration = endDate.difference(startDate).inDays;
    final dayWidth = 30.0 * _scale;
    
    final leftPosition = taskStartDay * dayWidth;
    final barWidth = (taskDuration + 1) * dayWidth;
    
    return Positioned(
      left: leftPosition,
      child: Container(
        width: barWidth,
        height: 24,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _getTaskColor(task['color'] ?? 'blue'),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Stack(
          children: [
            // 진행률 표시
            if (progress > 0)
              Container(
                width: barWidth * progress,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            // 작업명 표시
            Center(
              child: Text(
                task['title'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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

  double _calculateTotalWidth() {
    final days = _viewEndDate.difference(_viewStartDate).inDays;
    return (days + 1) * 30.0 * _scale;
  }
}
