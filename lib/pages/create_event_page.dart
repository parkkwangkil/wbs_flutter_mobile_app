import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

// 이벤트 생성 페이지
class CreateEventPage extends StatefulWidget {
  final Function(Map<String, dynamic>)? onEventCreated;
  
  const CreateEventPage({
    super.key,
    this.onEventCreated,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 전달된 날짜가 있으면 초기값으로 설정
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['selectedDate'] != null) {
      final selectedDate = args['selectedDate'] as DateTime;
      _startDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 9, 0);
      _endDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 17, 0); // 종료 시간을 17시로 설정
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
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime(2020),
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

  void _saveEvent() {
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
        'end_date': _endDate?.toIso8601String().split('T')[0],
        'location': _locationController.text.isNotEmpty ? _locationController.text : '미정',
        'color': '#${_selectedColor.value.toRadixString(16).substring(2)}',
        'created_at': DateTime.now().toIso8601String().split('T')[0],
      };
      
      // 콜백 호출하여 이벤트 목록에 추가
      if (widget.onEventCreated != null) {
        widget.onEventCreated!(newEvent);
      }
      
      // 성공 메시지 표시
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.getText('이벤트가 생성되었습니다.', 'Event created successfully.'))),
      );
      
      // 이전 페이지로 돌아가기
      Navigator.pop(context, newEvent);
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
