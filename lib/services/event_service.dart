import 'package:flutter/material.dart';

class EventService {
  static final List<Map<String, dynamic>> _events = [
    {
      'id': '1',
      'title': '주간 정기 회의',
      'date': '2025-10-06',
      'time': '10:00 AM',
      'location': '3층 대회의실',
      'description': '주간 진행 상황 보고 및 다음 주 계획 수립',
      'start_date': '2025-10-06',
      'end_date': '2025-10-06',
      'start_time': '10:00',
      'end_time': '11:00',
    },
    {
      'id': '2',
      'title': 'WBS 앱 1차 데모',
      'date': '2025-10-10',
      'time': '02:00 PM',
      'location': '온라인 (Google Meet)',
      'description': '개발된 기능 시연 및 피드백 수집',
      'start_date': '2025-10-10',
      'end_date': '2025-10-10',
      'start_time': '14:00',
      'end_time': '15:00',
    },
  ];

  static List<Map<String, dynamic>> getEvents() {
    return _events;
  }

  static void addEvent(Map<String, dynamic> event) {
    _events.add(event);
  }

  static void removeEvent(String eventId) {
    _events.removeWhere((event) => event['id'] == eventId);
  }

  static void updateEvent(String eventId, Map<String, dynamic> updatedEvent) {
    final index = _events.indexWhere((event) => event['id'] == eventId);
    if (index != -1) {
      _events[index] = updatedEvent;
    }
  }
}
