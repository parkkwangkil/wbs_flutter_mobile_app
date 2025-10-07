class Event {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final List<String> attendees;
  final String color;
  final bool hasAlarm;
  final int alarmMinutes;
  final int createdBy;
  final DateTime createdAt;
  final String projectId; // 프로젝트 ID 추가

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.location,
    required this.attendees,
    required this.color,
    required this.hasAlarm,
    required this.alarmMinutes,
    required this.createdBy,
    required this.createdAt,
    required this.projectId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : DateTime.now(),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : DateTime.now().add(const Duration(hours: 1)),
      location: json['location'],
      attendees: json['attendees'] != null 
          ? List<String>.from(json['attendees']) 
          : [],
      color: json['color'] ?? 'blue',
      hasAlarm: json['has_alarm'] ?? false,
      alarmMinutes: json['alarm_minutes'] ?? 15,
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      projectId: json['project_id'] ?? 'default',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'location': location,
      'attendees': attendees,
      'color': color,
      'has_alarm': hasAlarm,
      'alarm_minutes': alarmMinutes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'project_id': projectId,
    };
  }

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    List<String>? attendees,
    String? color,
    bool? hasAlarm,
    int? alarmMinutes,
    int? createdBy,
    DateTime? createdAt,
    String? projectId,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      color: color ?? this.color,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      alarmMinutes: alarmMinutes ?? this.alarmMinutes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      projectId: projectId ?? this.projectId,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, startDate: $startDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
