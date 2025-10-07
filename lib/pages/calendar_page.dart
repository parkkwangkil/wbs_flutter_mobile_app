import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/language_provider.dart';
import '../services/event_service.dart';
import '../services/local_database.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // AppStateService 구독 제거 - 무한루프 방지
  
  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final events = await LocalDatabase.getEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() {
        _events = [];
        _isLoading = false;
      });
    }
  }

  // 선택된 날짜의 이벤트 필터링
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dayStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final events = _events.where((event) {
      // 단일 날짜 이벤트 (date 필드가 있는 경우)
      if (event['date'] == dayStr) return true;
      
      // 기간 이벤트 (start_date와 end_date가 있는 경우)
      if (event['start_date'] != null && event['end_date'] != null) {
        final startDate = DateTime.parse(event['start_date']);
        final endDate = DateTime.parse(event['end_date']);
        
        // 해당 날짜가 시작일과 종료일 사이에 있는지 확인 (포함)
        return (day.isAtSameMomentAs(startDate) || 
                day.isAtSameMomentAs(endDate) ||
                (day.isAfter(startDate) && day.isBefore(endDate))) ||
               // 또는 시작일과 종료일이 같은 경우
               (startDate.isAtSameMomentAs(endDate) && day.isAtSameMomentAs(startDate));
      }
      
      return false;
    }).toList();
    return events;
  }

  // 이벤트 색상 반환
  Color _getEventColor(Map<String, dynamic> event) {
    if (event['color'] != null) {
      try {
        return Color(int.parse(event['color'].replaceAll('#', '0xFF')));
      } catch (e) {
        return Theme.of(context).primaryColor;
      }
    }
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('캘린더', 'Calendar')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Table Calendar 위젯
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _getEventsForDay(day);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                
                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.take(3).map((event) {
                      final color = _getEventColor(event as Map<String, dynamic>);
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(
                color: Colors.red[400],
              ),
              holidayTextStyle: TextStyle(
                color: Colors.red[400],
              ),
              markersMaxCount: 0, // 커스텀 마커 사용으로 기본 마커 비활성화
              // 선택된 날짜 스타일
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              // 오늘 날짜 스타일
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              // 이벤트가 있는 날짜 스타일
              defaultDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              formatButtonTextStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          // 선택된 날짜 정보
          if (_selectedDay != null)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    lang.getText(
                      '선택된 날짜: ${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일',
                      'Selected: ${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}',
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // 이벤트 생성 페이지로 이동
                      final result = await Navigator.pushNamed(context, '/create_event');
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _events.add(result);
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text(lang.getText('이벤트 추가', 'Add Event')),
                  ),
                ],
              ),
            ),
          // 이벤트 목록
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  _selectedDay != null 
                    ? '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일 일정'
                    : lang.getText('오늘의 일정', 'Today\'s Schedule'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                // 이벤트가 없을 때 메시지 표시
                if (_getEventsForDay(_selectedDay ?? DateTime.now()).isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          lang.getText('선택된 날짜에 일정이 없습니다.', 'No events for selected date.'),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  )
                else
                  ..._getEventsForDay(_selectedDay ?? DateTime.now()).map((event) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: _getEventColor(event),
                            width: 4,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(event['title'] ?? ''),
                        subtitle: Text('${event['time']} @ ${event['location']}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/event_detail',
                            arguments: {
                              'event': event,
                              'currentUser': 'current_user',
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "calendar_fab",
        onPressed: () async {
          // 선택된 날짜가 있으면 해당 날짜로, 없으면 오늘 날짜로 설정
          final selectedDate = _selectedDay ?? DateTime.now();
          final result = await Navigator.pushNamed(
            context, 
            '/create_event',
            arguments: {'selectedDate': selectedDate},
          );
            if (result != null && result is Map<String, dynamic>) {
              setState(() {
                EventService.addEvent(result);
              });
              // 성공 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('이벤트 "${result['title']}"가 생성되었습니다.'),
                  backgroundColor: Colors.green,
                ),
              );
              // 캘린더 새로고침
              setState(() {});
            }
        },
        child: const Icon(Icons.add),
        tooltip: lang.getText('이벤트 추가', 'Add Event'),
      ),
    );
  }
}
