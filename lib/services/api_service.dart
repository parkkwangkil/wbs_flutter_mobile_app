import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Django API 기본 URL (Railway 배포 서버)
  static const String baseUrl = 'http://127.0.0.1:8000'; // 로컬 서버 사용 안함
  
  // 로그인 API
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // 사용자 목록에서 로그인 정보 확인
      final users = await getUsers();
      
      // ID 또는 이메일로 로그인 가능
      final user = users.firstWhere(
        (u) => (u['username'] == username || u['email'] == username) && 
               u['password'] == password,
        orElse: () => {},
      );
      
      if (user.isNotEmpty) {
        return {
          'success': true,
          'message': '로그인 성공',
          'user': user['username'],
        };
      } else {
        return {
          'success': false,
          'message': '아이디/이메일 또는 비밀번호가 올바르지 않습니다.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류: $e',
      };
    }
  }
  
  // 프로젝트 목록 가져오기
  static Future<List<Map<String, dynamic>>> getProjects() async {
    // 로컬 데이터 로드
    await _loadLocalData();
    
    // 기본 프로젝트 + 로컬에 추가된 프로젝트들
    final fallbackProjects = _getFallbackProjects();
    return [...fallbackProjects, ..._localProjects];
  }
  
  // 폴백 프로젝트 데이터
  static List<Map<String, dynamic>> _getFallbackProjects() {
    return [
      {
        'id': 1,
        'title': 'WBS 시스템 개발',
        'description': '웹 기반 업무 분해 구조 시스템',
        'status': 'in_progress',
        'start_date': '2024-01-01',
        'end_date': '2024-12-31',
      },
      {
        'id': 2,
        'title': '개인 업무 관리',
        'description': '개인 일정 및 업무 관리',
        'status': 'completed',
        'start_date': '2024-01-01',
        'end_date': '2024-06-30',
      },
    ];
  }
  
  // 이벤트 목록 가져오기
  static Future<List<Map<String, dynamic>>> getEvents() async {
    // 로컬 데이터 로드
    await _loadLocalData();
    
    // 기본 이벤트 + 로컬에 추가된 이벤트들
    final fallbackEvents = _getFallbackEvents();
    return [...fallbackEvents, ..._localEvents];
  }
  
  // 폴백 이벤트 데이터
  static List<Map<String, dynamic>> _getFallbackEvents() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    
    return [
      // 기간별 이벤트 (파란색 - 프로젝트 A)
      {
        'id': 'project_a_1',
        'title': '프로젝트 A - 개발 단계',
        'description': '웹 애플리케이션 개발 프로젝트',
        'status': 'in_progress',
        'start_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-04',
        'end_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-15',
        'location': '개발팀',
      },
      // 기간별 이벤트 (빨간색 - 프로젝트 B)
      {
        'id': 'project_b_1',
        'title': '프로젝트 B - 테스트 단계',
        'description': '모바일 앱 테스트 프로젝트',
        'status': 'scheduled',
        'start_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-10',
        'end_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-25',
        'location': 'QA팀',
      },
      // 단일 이벤트들
      {
        'id': 'event_1',
        'title': '팀 미팅',
        'description': '주간 팀 미팅',
        'status': 'scheduled',
        'start_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-03',
        'end_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-03',
        'location': '회의실 A',
      },
      {
        'id': 'event_2',
        'title': '프로젝트 리뷰',
        'description': '월간 프로젝트 리뷰',
        'status': 'completed',
        'start_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-20',
        'end_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-20',
        'location': '온라인',
      },
      // 추가 기간별 이벤트 (초록색)
      {
        'id': 'project_c_1',
        'title': '프로젝트 C - 배포 단계',
        'description': '시스템 배포 및 모니터링',
        'status': 'scheduled',
        'start_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-18',
        'end_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-30',
        'location': '운영팀',
      },
      // 테스트용 14일-17일 이벤트
      {
        'id': 'test_range_event',
        'title': '테스트 기간 이벤트',
        'description': '14일부터 17일까지의 테스트 이벤트',
        'status': 'in_progress',
        'start_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-14',
        'end_date': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-17',
        'location': '테스트팀',
      },
    ];
  }
  
  // 사용자 목록 가져오기
  static Future<List<Map<String, dynamic>>> getUsers() async {
    // 로컬 데이터 로드
    await _loadLocalData();
    
    // 기본 사용자 + 로컬에 추가된 사용자들
    final fallbackUsers = _getFallbackUsers();
    return [...fallbackUsers, ..._localUsers];
  }
  
  // 사용자 추가
  // 로컬 사용자 저장소
  static List<Map<String, dynamic>> _localUsers = [];
  static List<Map<String, dynamic>> _localProjects = [];
  static List<Map<String, dynamic>> _localEvents = [];

  // SharedPreferences에서 데이터 로드
  static Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 사용자 데이터 로드
    final usersJson = prefs.getString('local_users');
    if (usersJson != null) {
      _localUsers = List<Map<String, dynamic>>.from(
        jsonDecode(usersJson).map((user) => Map<String, dynamic>.from(user))
      );
    }
    
    // 프로젝트 데이터 로드
    final projectsJson = prefs.getString('local_projects');
    if (projectsJson != null) {
      _localProjects = List<Map<String, dynamic>>.from(
        jsonDecode(projectsJson).map((project) => Map<String, dynamic>.from(project))
      );
    }
    
    // 이벤트 데이터 로드
    final eventsJson = prefs.getString('local_events');
    if (eventsJson != null) {
      _localEvents = List<Map<String, dynamic>>.from(
        jsonDecode(eventsJson).map((event) => Map<String, dynamic>.from(event))
      );
    }
  }

  // SharedPreferences에 데이터 저장
  static Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('local_users', jsonEncode(_localUsers));
    await prefs.setString('local_projects', jsonEncode(_localProjects));
    await prefs.setString('local_events', jsonEncode(_localEvents));
  }

  static Future<Map<String, dynamic>> addUser({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
    required String department,
  }) async {
    // 로컬 데이터 로드
    await _loadLocalData();
    
    // 로컬에서 사용자 추가
    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'department': department,
      'is_staff': false,
      'password': password, // 실제로는 해시화되어야 함
    };
    
    // 로컬 사용자 목록에 추가
    _localUsers.add(newUser);
    
    // 영구 저장
    await _saveLocalData();
    
    return {
      'success': true,
      'message': '사용자가 추가되었습니다.',
      'user': newUser,
    };
  }

  // 프로젝트 추가
  static Future<Map<String, dynamic>> addProject({
    required String title,
    required String description,
    required String status,
    required String color,
  }) async {
    // 로컬 데이터 로드
    await _loadLocalData();
    
    final newProject = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'description': description,
      'status': status,
      'color': color,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    // 로컬 프로젝트 목록에 추가
    _localProjects.add(newProject);
    
    // 영구 저장
    await _saveLocalData();
    
    return {
      'success': true,
      'message': '프로젝트가 추가되었습니다.',
      'project': newProject,
    };
  }

  // 이벤트 추가
  static Future<Map<String, dynamic>> addEvent({
    required String title,
    required String description,
    required String startDate,
    required String? endDate,
    required String status,
    required String location,
    required List<String> attendees,
    required bool hasAlarm,
    required int alarmMinutes,
  }) async {
    // 로컬 데이터 로드
    await _loadLocalData();
    
    final newEvent = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'location': location,
      'attendees': attendees,
      'has_alarm': hasAlarm,
      'alarm_minutes': alarmMinutes,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    // 로컬 이벤트 목록에 추가
    _localEvents.add(newEvent);
    
    // 영구 저장
    await _saveLocalData();
    
    return {
      'success': true,
      'message': '이벤트가 추가되었습니다.',
      'event': newEvent,
    };
  }

  // 사용자 프로필 업데이트
  static Future<Map<String, dynamic>> updateUserProfile({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String department,
  }) async {
    // 로컬 데이터 로드
    await _loadLocalData();
    
    // 로컬 사용자 목록에서 해당 사용자 찾기
    final userIndex = _localUsers.indexWhere((user) => user['username'] == username);
    
    if (userIndex != -1) {
      // 로컬 사용자 업데이트
      _localUsers[userIndex]['first_name'] = firstName;
      _localUsers[userIndex]['last_name'] = lastName;
      _localUsers[userIndex]['email'] = email;
      _localUsers[userIndex]['department'] = department;
    } else {
      // 새 사용자로 추가
      final updatedUser = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'department': department,
        'is_staff': false,
        'password': '', // 비밀번호는 별도 관리
      };
      _localUsers.add(updatedUser);
    }
    
    // 영구 저장
    await _saveLocalData();
    
    return {
      'success': true,
      'message': '프로필이 업데이트되었습니다.',
    };
  }

  // 폴백 사용자 데이터
  static List<Map<String, dynamic>> _getFallbackUsers() {
    return [
      {
        'id': 1,
        'username': 'admin',
        'email': 'admin@example.com',
        'first_name': 'Admin',
        'last_name': 'User',
        'department': '관리팀',
        'is_staff': true,
        'password': 'admin1234',
      },
      {
        'id': 2,
        'username': 'devops',
        'email': 'devops@test.com',
        'first_name': 'DevOps',
        'last_name': 'User',
        'department': '개발팀',
        'is_staff': false,
        'password': 'devops123',
      },
    ];
  }
}
