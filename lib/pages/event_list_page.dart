import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/event_service.dart';
import '../services/local_database.dart';
import '../services/app_state_service.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppStateService 변경사항 감지하여 자동 새로고침
    final appState = Provider.of<AppStateService>(context, listen: false);
    appState.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    final appState = Provider.of<AppStateService>(context, listen: false);
    appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    // 이벤트나 프로젝트가 변경되었을 때 자동 새로고침
    _loadEvents();
  }

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

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('이벤트/일정', 'Events/Schedule')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lang.getText('등록된 이벤트가 없습니다.', 'No events registered.'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
          return Card(
            child: ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event['date']?.split('-')[2] ?? '일', // 일(Day)
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      '${event['date']?.split('-')[1] ?? '월'}월',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(event['title'] ?? '제목 없음'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${event['time'] ?? '시간 미정'} @ ${event['location'] ?? '장소 미정'}'),
                  if (event['start_date'] != null && event['end_date'] != null)
                    Text(
                      '${event['start_date']} ~ ${event['end_date']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
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
          );
        },
      ),
        floatingActionButton: FloatingActionButton(
        heroTag: "event_list_fab",
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create_event');
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
          }
        },
        child: const Icon(Icons.add),
        tooltip: lang.getText('새 이벤트 추가', 'Add New Event'),
      ),
    );
  }
}
