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
    
    // 가이드 데이터 생성
    await _createGuideProjects();
  }
  
  // DB 가이드용 프로젝트 생성
  static Future<void> _createGuideProjects() async {
    // 프로젝트 가이드 데이터
    final projects = await getProjects();
    if (projects.isEmpty) {
      await saveProjects([
        {
          'id': 'guide_team_001',
          'name': 'WBS 모바일 앱 개발',
          'description': 'Flutter 기반의 WBS 관리 앱 개발 프로젝트',
          'type': 'team',
          'status': 'in_progress',
          'start_date': '2025-01-01',
          'end_date': '2025-03-31',
          'created_at': '2025-01-01',
        },
        {
          'id': 'guide_personal_001',
          'name': '개인 학습 프로젝트',
          'description': 'Flutter 고급 기능 학습 및 개인 포트폴리오 개발',
          'type': 'personal',
          'status': 'in_progress',
          'start_date': '2025-01-15',
          'end_date': '2025-02-15',
          'created_at': '2025-01-15',
        },
      ]);
    }
    
    // 사용자 가이드 데이터
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

  // 팀 멤버 관련 메서드들
  static Future<List<Map<String, dynamic>>> getTeamMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final teamMembersJson = prefs.getString('team_members') ?? '[]';
    return List<Map<String, dynamic>>.from(json.decode(teamMembersJson));
  }

  static Future<void> addTeamMember(Map<String, dynamic> member) async {
    final prefs = await SharedPreferences.getInstance();
    final teamMembers = await getTeamMembers();
    
    // ID가 없으면 생성
    if (member['id'] == null) {
      member['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    teamMembers.add(member);
    await prefs.setString('team_members', json.encode(teamMembers));
  }

  static Future<void> updateTeamMember(String id, Map<String, dynamic> updates) async {
    final prefs = await SharedPreferences.getInstance();
    final teamMembers = await getTeamMembers();
    
    final index = teamMembers.indexWhere((member) => member['id'] == id);
    if (index != -1) {
      teamMembers[index].addAll(updates);
      await prefs.setString('team_members', json.encode(teamMembers));
    }
  }

  static Future<void> deleteTeamMember(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final teamMembers = await getTeamMembers();
    
    teamMembers.removeWhere((member) => member['id'] == id);
    await prefs.setString('team_members', json.encode(teamMembers));
  }

  // 사용자 관리 관련 메서드들 (기존 메서드 확장)
  static Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    final users = await getUsers();
    
    final index = users.indexWhere((user) => user['id'] == id);
    if (index != -1) {
      users[index].addAll(updates);
      await saveUsers(users);
    }
  }

  static Future<void> deleteUser(String id) async {
    final users = await getUsers();
    
    users.removeWhere((user) => user['id'] == id);
    await saveUsers(users);
  }



  // 시스템 설정 관련 메서드들
  static Future<void> saveSystemSettings(Map<String, dynamic> settings) async {
    if (_prefs == null) await initialize();
    
    final String settingsJson = jsonEncode(settings);
    await _prefs!.setString('system_settings', settingsJson);
  }

  static Future<Map<String, dynamic>> getSystemSettings() async {
    if (_prefs == null) await initialize();
    
    final String? settingsJson = _prefs!.getString('system_settings');
    if (settingsJson != null) {
      return Map<String, dynamic>.from(jsonDecode(settingsJson));
    }
    return {
      'auto_backup': true,
      'notifications_enabled': true,
    };
  }

  // 보안 설정 관련 메서드들
  static Future<void> saveSecuritySettings(Map<String, dynamic> settings) async {
    if (_prefs == null) await initialize();
    
    final String settingsJson = jsonEncode(settings);
    await _prefs!.setString('security_settings', settingsJson);
  }

  static Future<Map<String, dynamic>> getSecuritySettings() async {
    if (_prefs == null) await initialize();
    
    final String? settingsJson = _prefs!.getString('security_settings');
    if (settingsJson != null) {
      return Map<String, dynamic>.from(jsonDecode(settingsJson));
    }
    return {
      'ip_restriction': false,
      'time_restriction': false,
      'device_restriction': false,
    };
  }

  // IP 규칙 관련 메서드들
  static Future<void> saveIpRules(List<Map<String, dynamic>> rules) async {
    if (_prefs == null) await initialize();
    
    final String rulesJson = jsonEncode(rules);
    await _prefs!.setString('ip_rules', rulesJson);
  }

  static Future<List<Map<String, dynamic>>> getIpRules() async {
    if (_prefs == null) await initialize();
    
    final String? rulesJson = _prefs!.getString('ip_rules');
    if (rulesJson != null) {
      List<dynamic> rulesList = jsonDecode(rulesJson);
      return rulesList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> addIpRule(Map<String, dynamic> rule) async {
    final rules = await getIpRules();
    rule['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    rule['created_at'] = DateTime.now().toIso8601String();
    rules.add(rule);
    await saveIpRules(rules);
  }

  static Future<void> deleteIpRule(String id) async {
    final rules = await getIpRules();
    rules.removeWhere((rule) => rule['id'] == id);
    await saveIpRules(rules);
  }

  // IP 접근 검증
  static Future<bool> isIpAllowed(String ip) async {
    final rules = await getIpRules();
    final settings = await getSecuritySettings();
    
    // IP 제한이 비활성화되어 있으면 모든 IP 허용
    if (!settings['ip_restriction']) return true;
    
    // 규칙이 없으면 모든 IP 허용
    if (rules.isEmpty) return true;
    
    // 규칙 검사
    for (final rule in rules) {
      final ruleType = rule['type']; // 'allow' or 'block'
      final ruleIp = rule['ip'];
      final isActive = rule['is_active'] ?? true;
      
      if (!isActive) continue;
      
      // 정확한 IP 매치
      if (ruleIp == ip) {
        return ruleType == 'allow';
      }
      
      // CIDR 표기법 지원 (예: 192.168.1.0/24)
      if (ruleIp.contains('/')) {
        if (_isIpInCidr(ip, ruleIp)) {
          return ruleType == 'allow';
        }
      }
    }
    
    // 기본값: 허용되지 않은 IP는 차단
    return false;
  }

  // CIDR 표기법 검사 (간단한 구현)
  static bool _isIpInCidr(String ip, String cidr) {
    try {
      final parts = cidr.split('/');
      final networkIp = parts[0];
      final prefixLength = int.parse(parts[1]);
      
      // 간단한 구현 (실제로는 더 복잡한 네트워크 계산 필요)
      return ip.startsWith(networkIp.split('.').take(3).join('.'));
    } catch (e) {
      return false;
    }
  }

  // 시간 제한 규칙 관련 메서드들
  static Future<void> saveTimeRules(List<Map<String, dynamic>> rules) async {
    if (_prefs == null) await initialize();
    
    final String rulesJson = jsonEncode(rules);
    await _prefs!.setString('time_rules', rulesJson);
  }

  static Future<List<Map<String, dynamic>>> getTimeRules() async {
    if (_prefs == null) await initialize();
    
    final String? rulesJson = _prefs!.getString('time_rules');
    if (rulesJson != null) {
      List<dynamic> rulesList = jsonDecode(rulesJson);
      return rulesList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> addTimeRule(Map<String, dynamic> rule) async {
    final rules = await getTimeRules();
    rule['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    rule['created_at'] = DateTime.now().toIso8601String();
    rules.add(rule);
    await saveTimeRules(rules);
  }

  static Future<void> deleteTimeRule(String id) async {
    final rules = await getTimeRules();
    rules.removeWhere((rule) => rule['id'] == id);
    await saveTimeRules(rules);
  }

  // 시간 접근 검증
  static Future<bool> isTimeAllowed() async {
    final rules = await getTimeRules();
    final settings = await getSecuritySettings();
    
    // 시간 제한이 비활성화되어 있으면 모든 시간 허용
    if (!settings['time_restriction']) return true;
    
    // 규칙이 없으면 모든 시간 허용
    if (rules.isEmpty) return true;
    
    final now = DateTime.now();
    final currentTime = {
      'hour': now.hour,
      'minute': now.minute,
    };
    final currentWeekday = now.weekday; // 1=월요일, 7=일요일
    
    // 규칙 검사
    for (final rule in rules) {
      final isActive = rule['is_active'] ?? true;
      if (!isActive) continue;
      
      final startTime = {
        'hour': rule['start_hour'] ?? 0,
        'minute': rule['start_minute'] ?? 0,
      };
      final endTime = {
        'hour': rule['end_hour'] ?? 23,
        'minute': rule['end_minute'] ?? 59,
      };
      
      final weekdays = List<int>.from(rule['weekdays'] ?? [1, 2, 3, 4, 5, 6, 7]);
      final ruleType = rule['type']; // 'allow' or 'block'
      
      // 요일 체크
      if (!weekdays.contains(currentWeekday)) continue;
      
      // 시간 체크
      if (_isTimeInRange(currentTime, startTime, endTime)) {
        return ruleType == 'allow';
      }
    }
    
    // 기본값: 허용되지 않은 시간은 차단
    return false;
  }

  static bool _isTimeInRange(Map<String, dynamic> current, Map<String, dynamic> start, Map<String, dynamic> end) {
    final currentMinutes = (current['hour'] ?? 0) * 60 + (current['minute'] ?? 0);
    final startMinutes = (start['hour'] ?? 0) * 60 + (start['minute'] ?? 0);
    final endMinutes = (end['hour'] ?? 0) * 60 + (end['minute'] ?? 0);
    
    if (startMinutes <= endMinutes) {
      // 같은 날 내 시간 범위 (예: 09:00-18:00)
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // 자정을 넘나드는 시간 범위 (예: 22:00-06:00)
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  // 디바이스 제한 규칙 관련 메서드들
  static Future<void> saveDeviceRules(List<Map<String, dynamic>> rules) async {
    if (_prefs == null) await initialize();
    
    final String rulesJson = jsonEncode(rules);
    await _prefs!.setString('device_rules', rulesJson);
  }

  static Future<List<Map<String, dynamic>>> getDeviceRules() async {
    if (_prefs == null) await initialize();
    
    final String? rulesJson = _prefs!.getString('device_rules');
    if (rulesJson != null) {
      List<dynamic> rulesList = jsonDecode(rulesJson);
      return rulesList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> addDeviceRule(Map<String, dynamic> rule) async {
    final rules = await getDeviceRules();
    rule['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    rule['created_at'] = DateTime.now().toIso8601String();
    rules.add(rule);
    await saveDeviceRules(rules);
  }

  static Future<void> deleteDeviceRule(String id) async {
    final rules = await getDeviceRules();
    rules.removeWhere((rule) => rule['id'] == id);
    await saveDeviceRules(rules);
  }

  // 디바이스 접근 검증
  static Future<bool> isDeviceAllowed(String deviceId, String deviceType) async {
    final rules = await getDeviceRules();
    final settings = await getSecuritySettings();
    
    // 디바이스 제한이 비활성화되어 있으면 모든 디바이스 허용
    if (!settings['device_restriction']) return true;
    
    // 규칙이 없으면 모든 디바이스 허용
    if (rules.isEmpty) return true;
    
    // 규칙 검사
    for (final rule in rules) {
      final isActive = rule['is_active'] ?? true;
      if (!isActive) continue;
      
      final ruleType = rule['type']; // 'allow' or 'block'
      final ruleDeviceId = rule['device_id'];
      final ruleDeviceType = rule['device_type'];
      
      // 디바이스 ID 매치
      if (ruleDeviceId == deviceId) {
        return ruleType == 'allow';
      }
      
      // 디바이스 타입 매치 (예: 'mobile', 'desktop', 'tablet')
      if (ruleDeviceType == deviceType) {
        return ruleType == 'allow';
      }
    }
    
    // 기본값: 허용되지 않은 디바이스는 차단
    return false;
  }

  // 사용자 설정 관련 메서드들
  static Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    if (_prefs == null) await initialize();
    
    final String settingsJson = jsonEncode(settings);
    await _prefs!.setString('notification_settings', settingsJson);
  }

  static Future<Map<String, dynamic>> getNotificationSettings() async {
    if (_prefs == null) await initialize();
    
    final String? settingsJson = _prefs!.getString('notification_settings');
    if (settingsJson != null) {
      return Map<String, dynamic>.from(jsonDecode(settingsJson));
    }
    return {
      'push_enabled': true,
      'email_enabled': true,
      'project_notifications': true,
      'event_notifications': true,
    };
  }

  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    if (_prefs == null) await initialize();
    
    final String settingsJson = jsonEncode(settings);
    await _prefs!.setString('app_settings', settingsJson);
  }

  static Future<Map<String, dynamic>> getAppSettings() async {
    if (_prefs == null) await initialize();
    
    final String? settingsJson = _prefs!.getString('app_settings');
    if (settingsJson != null) {
      return Map<String, dynamic>.from(jsonDecode(settingsJson));
    }
    return {
      'language': 'ko',
      'dark_mode': false,
      'auto_sync': true,
      'biometric_enabled': false,
      'auto_logout_minutes': 30,
    };
  }

}
