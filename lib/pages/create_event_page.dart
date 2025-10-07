import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/local_database.dart';
import '../services/app_state_service.dart';

// 이벤트 생성 페이지
class CreateEventPage extends StatefulWidget {
  final Function(Map<String, dynamic>)? onEventCreated;
  final String? projectId; // 프로젝트 ID 추가
  
  const CreateEventPage({
    super.key,
    this.onEventCreated,
    this.projectId,
  });

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedStatus = 'scheduled';
  DateTime? _startDate;
  DateTime? _endDate;
  final _locationController = TextEditingController();
  Color _selectedColor = Colors.blue;
  String _selectedAssignee = '나'; // 담당자 선택
  List<Map<String, dynamic>> _projects = [];
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
    _loadProjects();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 전달된 날짜가 있으면 초기값으로 설정 (한 번만)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['selectedDate'] != null && _startDate == null) {
      final selectedDate = args['selectedDate'] as DateTime;
      // 고정값 제거 - 선택된 날짜를 기준으로 동적 설정
      _startDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 9, 0);
      _endDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 17, 0);
    } else if (_startDate == null) {
      // 전달된 날짜가 없으면 현재 날짜 기준으로 설정
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, now.day, 9, 0);
      _endDate = DateTime(now.year, now.month, now.day, 17, 0);
    }
  }

  Future<void> _loadProjects() async {
    try {
      // 샘플 프로젝트 생성 (데이터가 없을 경우)
      final projects = await LocalDatabase.getProjects();
      setState(() {
        _projects = projects;
        if (_selectedProjectId == null && projects.isNotEmpty) {
          _selectedProjectId = projects.first['id']?.toString();
        }
      });
    } catch (e) {
      print('Error loading projects: $e');
      setState(() {
        _projects = [];
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('새 이벤트', 'New Event')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEvent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로젝트 선택
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.getText('프로젝트 선택', 'Select Project'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _projects.isEmpty ? null : _selectedProjectId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '프로젝트를 선택하세요',
                        ),
                        items: _projects.isEmpty 
                          ? [DropdownMenuItem<String>(value: '', child: Text('프로젝트가 없습니다'))]
                          : _projects.map((project) {
                              return DropdownMenuItem<String>(
                                value: project['id']?.toString() ?? '',
                                child: Text(project['name'] ?? '제목 없음'),
                              );
                            }).toList(),
                        onChanged: _projects.isEmpty ? null : (String? value) {
                          setState(() {
                            _selectedProjectId = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // 이벤트 제목
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.getText('이벤트 제목 *', 'Event Title *'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '이벤트 제목을 입력하세요',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이벤트 제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 이벤트 설명
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이벤트 설명',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '이벤트 설명을 입력하세요',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 이벤트 상태
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이벤트 상태',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'scheduled',
                            child: Text('예정'),
                          ),
                          DropdownMenuItem(
                            value: 'in_progress',
                            child: Text('진행 중'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('완료'),
                          ),
                          DropdownMenuItem(
                            value: 'cancelled',
                            child: Text('취소'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 이벤트 색상
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이벤트 색상',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _getColorName(_selectedColor),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showColorPicker,
                            icon: const Icon(Icons.palette),
                            label: const Text('색상 선택'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 미리보기 색상 옵션들
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _getColorOptions().map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedColor == color 
                                    ? Colors.black 
                                    : Colors.grey.shade300,
                                  width: _selectedColor == color ? 3 : 1,
                                ),
                              ),
                              child: _selectedColor == color
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 시작일
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '시작일',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: Text(
                          _startDate == null 
                            ? '시작일을 선택하세요' 
                            : '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 종료일
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '종료일',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: Text(
                          _endDate == null 
                            ? '종료일을 선택하세요' 
                            : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? _startDate ?? DateTime.now(),
                            firstDate: _startDate != null ? _startDate! : DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 장소
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '장소',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '이벤트 장소를 입력하세요',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 담당자 선택
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '담당자',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedAssignee,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: '나', child: Text('나 (개인)')),
                          DropdownMenuItem(value: '기획팀', child: Text('기획팀')),
                          DropdownMenuItem(value: '개발팀', child: Text('개발팀')),
                          DropdownMenuItem(value: '디자인팀', child: Text('디자인팀')),
                          DropdownMenuItem(value: 'QA팀', child: Text('QA팀')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAssignee = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveEvent,
                  icon: const Icon(Icons.save),
                  label: const Text('이벤트 생성'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      // 이벤트 생성 로직
      final newEvent = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'description': _descriptionController.text,
        'status': _selectedStatus,
        'date': _startDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        'time': '${_startDate?.hour.toString().padLeft(2, '0') ?? '09'}:${_startDate?.minute.toString().padLeft(2, '0') ?? '00'} - ${_endDate?.hour.toString().padLeft(2, '0') ?? '17'}:${_endDate?.minute.toString().padLeft(2, '0') ?? '00'}',
        'start_time': '${_startDate?.hour.toString().padLeft(2, '0') ?? '09'}:${_startDate?.minute.toString().padLeft(2, '0') ?? '00'}',
        'end_time': '${_endDate?.hour.toString().padLeft(2, '0') ?? '10'}:${_endDate?.minute.toString().padLeft(2, '0') ?? '00'}',
        'start_date': _startDate?.toIso8601String().split('T')[0],
        'end_date': _endDate?.toIso8601String().split('T')[0] ?? _startDate?.toIso8601String().split('T')[0],
        'location': _locationController.text.isNotEmpty ? _locationController.text : '미정',
        'color': '#${_selectedColor.value.toRadixString(16).substring(2)}',
        'created_at': DateTime.now().toIso8601String().split('T')[0],
        'project_id': _selectedProjectId ?? widget.projectId ?? 'default', // 프로젝트 ID 추가
        'assignee': _selectedAssignee, // 담당자 추가
      };
      
      try {
        // 실제 데이터베이스에 저장
        await LocalDatabase.addEvent(newEvent);
        
        // AppStateService에 이벤트 추가
        final appState = Provider.of<AppStateService>(context, listen: false);
        appState.addEvent(newEvent);
        
        // 성공 메시지 표시
        final lang = Provider.of<LanguageProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.getText('이벤트가 생성되었습니다.', 'Event created successfully.')),
            backgroundColor: Colors.green,
          ),
        );
        
        // 이전 페이지로 돌아가기 (새로고침 신호 포함)
        Navigator.pop(context, {'success': true, 'event': newEvent});
      } catch (e) {
        // 오류 메시지 표시
        final lang = Provider.of<LanguageProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.getText('이벤트 생성에 실패했습니다.', 'Failed to create event.')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 색상 옵션 목록
  List<Color> _getColorOptions() {
    return [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.brown,
    ];
  }

  // 색상 이름 반환
  String _getColorName(Color color) {
    if (color == Colors.blue) return '파란색';
    if (color == Colors.red) return '빨간색';
    if (color == Colors.green) return '초록색';
    if (color == Colors.orange) return '주황색';
    if (color == Colors.purple) return '보라색';
    if (color == Colors.teal) return '청록색';
    if (color == Colors.pink) return '분홍색';
    if (color == Colors.indigo) return '남색';
    if (color == Colors.amber) return '호박색';
    if (color == Colors.cyan) return '하늘색';
    if (color == Colors.lime) return '라임색';
    if (color == Colors.brown) return '갈색';
    return '기본색';
  }

  // 색상 선택 다이얼로그
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('색상 선택'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _getColorOptions().length,
            itemBuilder: (context, index) {
              final color = _getColorOptions()[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.black : Colors.grey,
                      width: _selectedColor == color ? 3 : 1,
                    ),
                  ),
                  child: _selectedColor == color
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}
