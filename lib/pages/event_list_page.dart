import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/event_service.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  // 이벤트 서비스 사용
  List<Map<String, dynamic>> get events => EventService.getEvents();

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('이벤트/일정', 'Events/Schedule')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
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
