import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EventDetailPage extends StatefulWidget {
  final Map<String, dynamic> event;
  final String? currentUser;
  
  const EventDetailPage({
    super.key,
    required this.event,
    this.currentUser,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // 알람 관련 변수
  bool _hasAlarm = false;
  int _alarmMinutes = 15; // 기본 15분 전 알람
  List<String> _attendees = []; // 참석자 목록
  final TextEditingController _attendeeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event['title']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.event['description']?.toString() ?? '');
    _selectedStatus = widget.event['status']?.toString() ?? 'scheduled';
    _startDate = widget.event['start_date'] != null 
        ? DateTime.tryParse(widget.event['start_date'].toString()) 
        : null;
    _endDate = widget.event['end_date'] != null 
        ? DateTime.tryParse(widget.event['end_date'].toString()) 
        : null;
    
    // 알람 및 참석자 정보 로드
    _hasAlarm = widget.event['has_alarm'] ?? false;
    _alarmMinutes = widget.event['alarm_minutes'] ?? 15;
    _attendees = List<String>.from(widget.event['attendees'] ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _attendeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '이벤트 편집' : '이벤트 상세'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteEvent();
              },
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                _saveEvent();
              },
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isEditing = false;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                    const Text(
                      '이벤트 제목',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isEditing
                        ? TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '이벤트 제목을 입력하세요',
                            ),
                          )
                        : Text(
                            widget.event['title']?.toString() ?? '제목 없음',
                            style: const TextStyle(fontSize: 18),
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
                    isEditing
                        ? TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '이벤트 설명을 입력하세요',
                            ),
                          )
                        : Text(
                            widget.event['description']?.toString() ?? '설명 없음',
                            style: const TextStyle(fontSize: 16),
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
                    isEditing
                        ? DropdownButton<String>(
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
                          )
                        : Row(
                            children: [
                              Icon(
                                _getStatusIcon(widget.event['status']?.toString() ?? 'scheduled'),
                                color: _getStatusColor(widget.event['status']?.toString() ?? 'scheduled'),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusText(widget.event['status']?.toString() ?? 'scheduled'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _getStatusColor(widget.event['status']?.toString() ?? 'scheduled'),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 이벤트 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '이벤트 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('시작일', _startDate != null 
                        ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
                        : '미정'),
                    _buildInfoRow('종료일', _endDate != null 
                        ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
                        : '미정'),
                    _buildInfoRow('생성일', widget.event['created_at']?.toString() ?? '미정'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 알람 설정
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '알람 설정',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Switch(
                          value: _hasAlarm,
                          onChanged: (value) {
                            setState(() {
                              _hasAlarm = value;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(_hasAlarm ? '알람 활성화' : '알람 비활성화'),
                      ],
                    ),
                    if (_hasAlarm) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('알람 시간: '),
                          DropdownButton<int>(
                            value: _alarmMinutes,
                            items: const [
                              DropdownMenuItem(value: 5, child: Text('5분 전')),
                              DropdownMenuItem(value: 15, child: Text('15분 전')),
                              DropdownMenuItem(value: 30, child: Text('30분 전')),
                              DropdownMenuItem(value: 60, child: Text('1시간 전')),
                              DropdownMenuItem(value: 1440, child: Text('1일 전')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _alarmMinutes = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 참석자 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '참석자',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addAttendee,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_attendees.isEmpty)
                      const Text(
                        '참석자가 없습니다.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ..._attendees.map((attendee) => ListTile(
                        leading: const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 16),
                        ),
                        title: Text(attendee),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => _removeAttendee(attendee),
                        ),
                      )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 액션 버튼들
            if (!isEditing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAlarmSettings();
                      },
                      icon: const Icon(Icons.notifications),
                      label: const Text('알림 설정'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAttendeeManagement();
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('참석자 관리'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      case 'scheduled':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'scheduled':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return '완료';
      case 'in_progress':
        return '진행 중';
      case 'scheduled':
        return '예정';
      case 'cancelled':
        return '취소';
      default:
        return '알 수 없음';
    }
  }

  void _saveEvent() {
    // 이벤트 저장 로직
    setState(() {
      isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이벤트가 저장되었습니다.')),
    );
  }

  void _addAttendee() async {
    // 등록된 팀원 목록 가져오기
    final teamMembers = await ApiService.getUsers();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedMembers = <String>{};
          
          return AlertDialog(
            title: const Text('참석자 추가'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // 수동 입력 옵션
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '수동 입력',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _attendeeController,
                            decoration: const InputDecoration(
                              labelText: '참석자 이름',
                              hintText: '홍길동',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_attendeeController.text.isNotEmpty) {
                                setState(() {
                                  _attendees.add(_attendeeController.text);
                                });
                                _attendeeController.clear();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('참석자가 추가되었습니다.')),
                                );
                              }
                            },
                            child: const Text('수동 추가'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 팀원 목록에서 선택
                  const Text(
                    '등록된 팀원에서 선택',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: teamMembers.length,
                      itemBuilder: (context, index) {
                        final member = teamMembers[index];
                        final memberName = '${member['first_name']} ${member['last_name']}';
                        final isSelected = selectedMembers.contains(memberName);
                        
                        return CheckboxListTile(
                          title: Text(memberName),
                          subtitle: Text('${member['username']} (${member['department']})'),
                          value: isSelected,
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedMembers.add(memberName);
                              } else {
                                selectedMembers.remove(memberName);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _attendeeController.clear();
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedMembers.isNotEmpty) {
                    setState(() {
                      _attendees.addAll(selectedMembers);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${selectedMembers.length}명의 참석자가 추가되었습니다.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('참석자를 선택해주세요.')),
                    );
                  }
                },
                child: const Text('선택 추가'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _removeAttendee(String attendee) {
    setState(() {
      _attendees.remove(attendee);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$attendee 참석자가 제거되었습니다.')),
    );
  }

  void _showAlarmSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('알림 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('알림 활성화'),
                  Switch(
                    value: _hasAlarm,
                    onChanged: (value) {
                      setDialogState(() {
                        _hasAlarm = value;
                      });
                    },
                  ),
                ],
              ),
              if (_hasAlarm) ...[
                const SizedBox(height: 16),
                const Text('알림 시간'),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  value: _alarmMinutes,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5분 전')),
                    DropdownMenuItem(value: 15, child: Text('15분 전')),
                    DropdownMenuItem(value: 30, child: Text('30분 전')),
                    DropdownMenuItem(value: 60, child: Text('1시간 전')),
                    DropdownMenuItem(value: 1440, child: Text('1일 전')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _alarmMinutes = value!;
                    });
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // 알람 설정 저장
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('알림 설정이 저장되었습니다.')),
                );
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttendeeManagement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('참석자 관리'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('참석자 목록'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.pop(context);
                      _addAttendee();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_attendees.isEmpty)
                const Text(
                  '참석자가 없습니다.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ..._attendees.map((attendee) => ListTile(
                  leading: const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 16),
                  ),
                  title: Text(attendee),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _attendees.remove(attendee);
                      });
                    },
                  ),
                )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이벤트 삭제'),
        content: const Text('이 이벤트를 삭제하시겠습니까?\n삭제된 이벤트는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 이벤트 상세 페이지 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이벤트가 삭제되었습니다.')),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
