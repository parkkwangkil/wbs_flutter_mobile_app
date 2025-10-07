import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabase {
  static SharedPreferences? _prefs;
  
  
  // 프로젝트 관련 메서드들
  static Future<List<Map<String, dynamic>>> getProjects() async {
    if (_prefs == null) await initialize();
    
    final String? projectsJson = _prefs!.getString('projects');
    if (projectsJson != null) {
      List<dynamic> projectsList = jsonDecode(projectsJson);
      return projectsList.cast<Map<String, dynamic>>();
    }
    return [];
  }
  
  static Future<void> saveProjects(List<Map<String, dynamic>> projects) async {
    if (_prefs == null) await initialize();
    
    final String projectsJson = jsonEncode(projects);
    await _prefs!.setString('projects', projectsJson);
  }
  
  static Future<void> addProject(Map<String, dynamic> project) async {
    final projects = await getProjects();
    projects.add(project);
    await saveProjects(projects);
  }
  
  static Future<void> updateProject(String id, Map<String, dynamic> updatedProject) async {
    final projects = await getProjects();
    final index = projects.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      projects[index] = updatedProject;
      await saveProjects(projects);
    }
  }
  
  static Future<void> deleteProject(String id) async {
    final projects = await getProjects();
    projects.removeWhere((p) => p['id'] == id);
    await saveProjects(projects);
  }
  
  // 테스트용 샘플 프로젝트 생성
  static Future<void> createSampleProjects() async {
    final projects = await getProjects();
    if (projects.isEmpty) {
      final sampleProjects = [
        {
          'id': '1',
          'name': 'WBS 모바일 앱 개발',
          'description': '프로젝트 관리 모바일 애플리케이션 개발',
          'status': 'in_progress',
          'start_date': '2025-10-01',
          'end_date': '2025-12-31',
          'created_at': DateTime.now().toIso8601String().split('T')[0],
        },
        {
          'id': '2',
          'name': 'UI/UX 디자인',
          'description': '사용자 인터페이스 및 사용자 경험 디자인',
          'status': 'completed',
          'start_date': '2025-09-01',
          'end_date': '2025-09-30',
          'created_at': DateTime.now().toIso8601String().split('T')[0],
        },
        {
          'id': '3',
          'name': '백엔드 API 개발',
          'description': '서버 사이드 API 및 데이터베이스 설계',
          'status': 'on_hold',
          'start_date': '2025-10-15',
          'end_date': '2025-11-30',
          'created_at': DateTime.now().toIso8601String().split('T')[0],
        },
      ];
      await saveProjects(sampleProjects);
    }
  }
  
  // 프로젝트 진행률 계산
  static Future<double> getProjectProgress(String projectId) async {
    final events = await getEventsByProject(projectId);
    if (events.isEmpty) return 0.0;
    
    final completedEvents = events.where((event) => event['status'] == 'completed').length;
    return completedEvents / events.length;
  }
  
  // 프로젝트별 이벤트 통계
  static Future<Map<String, int>> getProjectEventStats(String projectId) async {
    final events = await getEventsByProject(projectId);
    return {
      'total': events.length,
      'completed': events.where((e) => e['status'] == 'completed').length,
      'in_progress': events.where((e) => e['status'] == 'in_progress').length,
      'pending': events.where((e) => e['status'] == 'pending').length,
    };
  }
  
  // 이벤트 관련 메서드들 (프로젝트 중심)
  static Future<List<Map<String, dynamic>>> getEvents() async {
    if (_prefs == null) await initialize();
    
    final String? eventsJson = _prefs!.getString('events');
    if (eventsJson != null) {
      List<dynamic> eventsList = jsonDecode(eventsJson);
      return eventsList.cast<Map<String, dynamic>>();
    }
    return [];
  }
  
  // 특정 프로젝트의 이벤트들 가져오기
  static Future<List<Map<String, dynamic>>> getEventsByProject(String projectId) async {
    final allEvents = await getEvents();
    return allEvents.where((event) => event['project_id'] == projectId).toList();
  }
  
  static Future<void> saveEvents(List<Map<String, dynamic>> events) async {
    if (_prefs == null) await initialize();
    
    final String eventsJson = jsonEncode(events);
    await _prefs!.setString('events', eventsJson);
  }
  
  static Future<void> addEvent(Map<String, dynamic> event) async {
    final events = await getEvents();
    events.add(event);
    await saveEvents(events);
  }
  
  static Future<void> updateEvent(String id, Map<String, dynamic> updatedEvent) async {
    final events = await getEvents();
    final index = events.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      events[index] = updatedEvent;
      await saveEvents(events);
    }
  }
  
  static Future<void> deleteEvent(String id) async {
    final events = await getEvents();
    events.removeWhere((e) => e['id'] == id);
    await saveEvents(events);
  }
  
  // 사용자 관련 메서드들
  static Future<List<Map<String, dynamic>>> getUsers() async {
    if (_prefs == null) await initialize();
    
    final String? usersJson = _prefs!.getString('users');
    if (usersJson != null) {
      List<dynamic> usersList = jsonDecode(usersJson);
      return usersList.cast<Map<String, dynamic>>();
    }
    return [];
  }
  
  static Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    if (_prefs == null) await initialize();
    
    final String usersJson = jsonEncode(users);
    await _prefs!.setString('users', usersJson);
  }
  
  static Future<void> addUser(Map<String, dynamic> user) async {
    final users = await getUsers();
    users.add(user);
    await saveUsers(users);
  }
  
  // 할 일 관련 메서드들
  static Future<List<Map<String, dynamic>>> getTodos() async {
    if (_prefs == null) await initialize();
    
    final String? todosJson = _prefs!.getString('todos');
    if (todosJson != null) {
      List<dynamic> todosList = jsonDecode(todosJson);
      return todosList.cast<Map<String, dynamic>>();
    }
    return [];
  }
  
  static Future<void> saveTodos(List<Map<String, dynamic>> todos) async {
    if (_prefs == null) await initialize();
    
    final String todosJson = jsonEncode(todos);
    await _prefs!.setString('todos', todosJson);
  }
  
  static Future<void> addTodo(Map<String, dynamic> todo) async {
    final todos = await getTodos();
    todos.add(todo);
    await saveTodos(todos);
  }
  
  static Future<void> updateTodo(String id, Map<String, dynamic> updatedTodo) async {
    final todos = await getTodos();
    final index = todos.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      todos[index] = updatedTodo;
      await saveTodos(todos);
    }
  }
  
  static Future<void> deleteTodo(String id) async {
    final todos = await getTodos();
    todos.removeWhere((t) => t['id'] == id);
    await saveTodos(todos);
  }
  
  // 모든 데이터 초기화
  static Future<void> clearAllData() async {
    if (_prefs == null) await initialize();
    
    await _prefs!.remove('projects');
    await _prefs!.remove('events');
    await _prefs!.remove('users');
    await _prefs!.remove('todos');
  }
  
  // 초기 샘플 데이터 생성
  static Future<void> initializeSampleData() async {
    // 프로젝트 샘플 데이터
    final projects = await getProjects();
    if (projects.isEmpty) {
      await saveProjects([
        {
          'id': 'p_001',
          'name': 'WBS 모바일 앱 개발',
          'description': 'Flutter 기반의 WBS 관리 앱',
          'status': 'in_progress',
          'start_date': '2025-01-01',
          'end_date': '2025-03-31',
          'created_at': '2025-01-01',
        },
        {
          'id': 'p_002',
          'name': '사내 인트라넷 고도화',
          'description': '레거시 시스템 마이그레이션',
          'status': 'on_hold',
          'start_date': '2025-02-01',
          'end_date': '2025-06-30',
          'created_at': '2025-01-15',
        },
        {
          'id': 'p_003',
          'name': '2025년 신제품 런칭',
          'description': '마케팅 및 프로모션 기획',
          'status': 'completed',
          'start_date': '2024-10-01',
          'end_date': '2024-12-31',
          'created_at': '2024-09-15',
        },
      ]);
    }
    
    // 이벤트 샘플 데이터 (프로젝트 중심)
    final events = await getEvents();
    if (events.isEmpty) {
      await saveEvents([
        // WBS 모바일 앱 개발 프로젝트의 이벤트들
        {
          'id': 'e_001',
          'project_id': 'p_001',
          'title': '프로젝트 기획 회의',
          'description': 'WBS 앱 개발 프로젝트 기획 및 일정 수립',
          'date': '2025-01-06',
          'time': '10:00 AM',
          'location': '3층 대회의실',
          'start_date': '2025-01-06',
          'end_date': '2025-01-06',
          'start_time': '10:00',
          'end_time': '11:00',
          'color': '#2196F3',
          'status': 'completed',
          'created_at': '2025-01-01',
        },
        {
          'id': 'e_002',
          'project_id': 'p_001',
          'title': 'UI/UX 설계',
          'description': '앱 인터페이스 및 사용자 경험 설계',
          'date': '2025-01-10',
          'time': '02:00 PM',
          'location': '디자인팀 사무실',
          'start_date': '2025-01-10',
          'end_date': '2025-01-12',
          'start_time': '14:00',
          'end_time': '17:00',
          'color': '#4CAF50',
          'status': 'completed',
          'created_at': '2025-01-01',
        },
        {
          'id': 'e_003',
          'project_id': 'p_001',
          'title': '개발 시작',
          'description': 'Flutter 기반 앱 개발 시작',
          'date': '2025-01-15',
          'time': '09:00 AM',
          'location': '개발팀 사무실',
          'start_date': '2025-01-15',
          'end_date': '2025-01-25',
          'start_time': '09:00',
          'end_time': '18:00',
          'color': '#FF9800',
          'status': 'in_progress',
          'created_at': '2025-01-01',
        },
        {
          'id': 'e_004',
          'project_id': 'p_001',
          'title': '테스트 및 디버깅',
          'description': '앱 테스트 및 버그 수정',
          'date': '2025-01-20',
          'time': '03:00 PM',
          'location': 'QA팀 사무실',
          'start_date': '2025-01-20',
          'end_date': '2025-01-22',
          'start_time': '15:00',
          'end_time': '17:00',
          'color': '#9C27B0',
          'status': 'pending',
          'created_at': '2025-01-01',
        },
        // 사내 인트라넷 고도화 프로젝트의 이벤트들
        {
          'id': 'e_005',
          'project_id': 'p_002',
          'title': '레거시 시스템 분석',
          'description': '기존 시스템 분석 및 마이그레이션 계획 수립',
          'date': '2025-02-01',
          'time': '10:00 AM',
          'location': 'IT팀 사무실',
          'start_date': '2025-02-01',
          'end_date': '2025-02-05',
          'start_time': '10:00',
          'end_time': '17:00',
          'color': '#607D8B',
          'status': 'pending',
          'created_at': '2025-01-01',
        },
      ]);
    }
    

  // 사용자 샘플 데이터
    final users = await getUsers();
    if (users.isEmpty) {
      await saveUsers([
        {
          'id': 'admin',
          'name': 'Admin',
          'email': 'admin@wbs.com',
          'password': '1111',
          'role': 'admin',
          'status': 'online',
          'created_at': '2025-01-01',
        },
        {
          'id': 'test',
          'name': 'Test User',
          'email': 'test@wbs.com',
          'password': '1111',
          'role': 'user',
          'status': 'online',
          'created_at': '2025-01-01',
        },
      ]);
    }
    
    // 할 일 샘플 데이터
    final todos = await getTodos();
    if (todos.isEmpty) {
      await saveTodos([
        {
          'id': 't_001',
          'title': 'WBS 앱 개발 완료',
          'completed': false,
          'created_at': '2025-01-01',
        },
        {
          'id': 't_002',
          'title': '회의록 작성',
          'completed': true,
          'created_at': '2025-01-01',
        },
        {
          'id': 't_003',
          'title': '이메일 회신',
          'completed': false,
          'created_at': '2025-01-01',
        },
      ]);
    }
  }
  
  // 간트 차트 작업 관련 메서드들
  static Future<List<Map<String, dynamic>>> getGanttTasks(String? projectId) async {
    if (_prefs == null) await initialize();
    
    final String? tasksJson = _prefs!.getString('gantt_tasks');
    if (tasksJson != null) {
      List<dynamic> tasksList = jsonDecode(tasksJson);
      List<Map<String, dynamic>> allTasks = tasksList.cast<Map<String, dynamic>>();
      
      if (projectId != null) {
        return allTasks.where((task) => task['project_id'] == projectId).toList();
      }
      return allTasks;
    }
    return [];
  }
  
  static Future<void> saveGanttTasks(List<Map<String, dynamic>> tasks) async {
    if (_prefs == null) await initialize();
    
    final String tasksJson = jsonEncode(tasks);
    await _prefs!.setString('gantt_tasks', tasksJson);
  }
  
  static Future<void> addGanttTask(Map<String, dynamic> task) async {
    final tasks = await getGanttTasks(null);
    tasks.add(task);
    await saveGanttTasks(tasks);
  }
  
  static Future<void> updateGanttTask(String id, Map<String, dynamic> updatedTask) async {
    final tasks = await getGanttTasks(null);
    final index = tasks.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveGanttTasks(tasks);
    }
  }
  
  static Future<void> deleteGanttTask(String id) async {
    final tasks = await getGanttTasks(null);
    tasks.removeWhere((t) => t['id'] == id);
    await saveGanttTasks(tasks);
  }
  
  // 이벤트를 간트 차트 작업으로 변환
  static Future<void> syncEventsToGanttTasks(String projectId) async {
    final events = await getEventsByProject(projectId);
    final existingTasks = await getGanttTasks(projectId);
    
    // 기존 작업 ID 목록
    final existingTaskIds = existingTasks.map((t) => t['id']).toSet();
    
    for (final event in events) {
      final taskId = 'task_${event['id']}';
      
      // 이미 존재하는 작업이면 업데이트, 없으면 새로 생성
      if (existingTaskIds.contains(taskId)) {
        await updateGanttTask(taskId, {
          'id': taskId,
          'title': event['title'] ?? '제목 없음',
          'start_date': event['start_date'] ?? DateTime.now().toIso8601String().split('T')[0],
          'end_date': event['end_date'] ?? DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0],
          'color': event['color'] ?? 'blue',
          'progress': 0.0,
          'assignee': event['assignee'] ?? '담당자',
          'project_id': projectId,
          'event_id': event['id'],
          'created_at': DateTime.now().toIso8601String().split('T')[0],
        });
      } else {
        await addGanttTask({
          'id': taskId,
          'title': event['title'] ?? '제목 없음',
          'start_date': event['start_date'] ?? DateTime.now().toIso8601String().split('T')[0],
          'end_date': event['end_date'] ?? DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0],
          'color': event['color'] ?? 'blue',
          'progress': 0.0,
          'assignee': event['assignee'] ?? '담당자',
          'project_id': projectId,
          'event_id': event['id'],
          'created_at': DateTime.now().toIso8601String().split('T')[0],
        });
      }
    }
  }
  
  // 채팅 관련 메서드들
  static Future<List<Map<String, dynamic>>> getChatRooms() async {
    if (_prefs == null) await initialize();
    
    final String? roomsJson = _prefs!.getString('chat_rooms');
    if (roomsJson != null) {
      List<dynamic> roomsList = jsonDecode(roomsJson);
      return roomsList.cast<Map<String, dynamic>>();
    }
    return [];
  }
  
  static Future<void> saveChatRooms(List<Map<String, dynamic>> rooms) async {
    if (_prefs == null) await initialize();
    
    final String roomsJson = jsonEncode(rooms);
    await _prefs!.setString('chat_rooms', roomsJson);
  }
  
  static Future<void> addChatRoom(Map<String, dynamic> room) async {
    final rooms = await getChatRooms();
    rooms.add(room);
    await saveChatRooms(rooms);
  }
  
  static Future<void> updateChatRoom(String id, Map<String, dynamic> updatedRoom) async {
    final rooms = await getChatRooms();
    final index = rooms.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      rooms[index] = updatedRoom;
      await saveChatRooms(rooms);
    }
  }
  
  static Future<void> deleteChatRoom(String id) async {
    final rooms = await getChatRooms();
    rooms.removeWhere((r) => r['id'] == id);
    await saveChatRooms(rooms);
  }
  
  // 채팅 메시지 관련 메서드들
  static Future<List<Map<String, dynamic>>> getChatMessages(String roomId) async {
    if (_prefs == null) await initialize();
    
    final String? messagesJson = _prefs!.getString('chat_messages_$roomId');
    if (messagesJson != null) {
      List<dynamic> messagesList = jsonDecode(messagesJson);
      return messagesList.cast<Map<String, dynamic>>();
    }
    return [];
  }
  
  static Future<void> saveChatMessages(String roomId, List<Map<String, dynamic>> messages) async {
    if (_prefs == null) await initialize();
    
    final String messagesJson = jsonEncode(messages);
    await _prefs!.setString('chat_messages_$roomId', messagesJson);
  }
  
  static Future<void> addChatMessage(String roomId, Map<String, dynamic> message) async {
    final messages = await getChatMessages(roomId);
    messages.add(message);
    await saveChatMessages(roomId, messages);
  }
  
  // 채팅방 참여자 관리
  static Future<void> addChatRoomMember(String roomId, String userId) async {
    final rooms = await getChatRooms();
    final roomIndex = rooms.indexWhere((r) => r['id'] == roomId);
    if (roomIndex != -1) {
      List<dynamic> members = rooms[roomIndex]['members'] ?? [];
      if (!members.contains(userId)) {
        members.add(userId);
        rooms[roomIndex]['members'] = members;
        await saveChatRooms(rooms);
      }
    }
  }
  
  static Future<void> removeChatRoomMember(String roomId, String userId) async {
    final rooms = await getChatRooms();
    final roomIndex = rooms.indexWhere((r) => r['id'] == roomId);
    if (roomIndex != -1) {
      List<dynamic> members = rooms[roomIndex]['members'] ?? [];
      members.remove(userId);
      rooms[roomIndex]['members'] = members;
      await saveChatRooms(rooms);
    }
  }
  
  // 데이터베이스 초기화 함수
  static Future<void> initialize() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    
    // 샘플 데이터 생성
    await _createSampleData();
  }
  
  // 샘플 데이터 생성
  static Future<void> _createSampleData() async {
    // 프로젝트 샘플 데이터
    final projects = await getProjects();
    if (projects.isEmpty) {
      await saveProjects([
        {
          'id': 'p_001',
          'name': 'WBS 모바일 앱 개발',
          'description': 'Flutter 기반의 WBS 관리 앱',
          'type': 'team', // 개인/팀 구분
          'status': 'in_progress',
          'start_date': '2025-01-01',
          'end_date': '2025-03-31',
          'created_at': '2025-01-01',
        },
        {
          'id': 'p_002',
          'name': '사내 인트라넷 고도화',
          'description': '레거시 시스템 마이그레이션',
          'type': 'team', // 개인/팀 구분
          'status': 'on_hold',
          'start_date': '2025-02-01',
          'end_date': '2025-06-30',
          'created_at': '2025-01-01',
        },
        {
          'id': 'p_003',
          'name': '개인 학습 프로젝트',
          'description': 'Flutter 고급 기능 학습',
          'type': 'personal', // 개인 프로젝트
          'status': 'in_progress',
          'start_date': '2025-01-15',
          'end_date': '2025-02-15',
          'created_at': '2025-01-15',
        },
      ]);
    }
    
    // 사용자 샘플 데이터
    final users = await getUsers();
    if (users.isEmpty) {
      await saveUsers([
        {
          'id': 'admin',
          'name': 'Admin',
          'email': 'admin@wbs.com',
          'password': '1111',
          'role': 'admin',
          'status': 'online',
          'created_at': '2025-01-01',
        },
        {
          'id': 'test',
          'name': 'Test User',
          'email': 'test@wbs.com',
          'password': '1111',
          'role': 'user',
          'status': 'online',
          'created_at': '2025-01-01',
        },
      ]);
    }
  }
}
