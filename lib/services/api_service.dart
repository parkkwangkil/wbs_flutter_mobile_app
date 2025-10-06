// import 'dart:convert';
// import 'package:http/http.dart' as http;

// 가짜 서버 URL (실제 서버 주소로 변경해야 함)
const String _baseUrl = 'https://api.example.com';

class ApiService {
  // --- 사용자 인증 관련 ---

  // 로그인 요청
  static Future<Map<String, dynamic>> login(String username, String password) async {
    // 실제로는 아래의 코드를 사용하여 서버와 통신해야 합니다.
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/login'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'username': username, 'password': password}),
    // );

    // 여기서는 2초간의 가짜 딜레이와 하드코딩된 응답을 사용합니다.
    await Future.delayed(const Duration(seconds: 2));

    // 사용자 인증 로직
    if (username == 'admin' && password == 'admin123') {
      return {
        'success': true, 
        'token': 'fake-jwt-token-for-admin',
        'user': {
          'id': 'admin_001',
          'username': 'admin',
          'role': 'admin',
          'name': '관리자',
          'email': 'admin@wbs.com'
        }
      };
    } else if (username == 'devops' && password == 'devops123') {
      return {
        'success': true, 
        'token': 'fake-jwt-token-for-devops',
        'user': {
          'id': 'user_001',
          'username': 'devops',
          'role': 'user',
          'name': '개발자',
          'email': 'devops@wbs.com'
        }
      };
    } else {
      return {'success': false, 'message': 'Invalid username or password.'};
    }
  }

  // --- 프로젝트 관련 ---

  // 프로젝트 목록 가져오기
  static Future<List<Map<String, dynamic>>> getProjects() async {
    // 실제 서버 통신 코드
    // final response = await http.get(Uri.parse('$_baseUrl/projects'));
    // if (response.statusCode == 200) {
    //   return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    // } else {
    //   throw Exception('Failed to load projects');
    // }

    // 가짜 데이터 반환
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        "id": "p_001",
        "name": "WBS 모바일 앱 개발",
        "description": "Flutter 기반의 WBS 관리 앱",
        "status": "in_progress",
      },
      {
        "id": "p_002",
        "name": "사내 인트라넷 고도화",
        "description": "레거시 시스템 마이그레이션",
        "status": "on_hold",
      },
      {
        "id": "p_003",
        "name": "2025년 신제품 런칭",
        "description": "마케팅 및 프로모션 기획",
        "status": "completed",
      },
    ];
  }

  // --- 사용자 관련 ---

  // 사용자 목록 가져오기
  static Future<List<Map<String, dynamic>>> getUsers() async {
    // 가짜 데이터 반환
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        "id": "u_001",
        "name": "Admin",
        "email": "admin@wbs.com",
        "role": "admin",
        "status": "online"
      },
      {
        "id": "u_002", 
        "name": "DevOps",
        "email": "devops@wbs.com",
        "role": "user",
        "status": "online"
      },
      {
        "id": "u_003",
        "name": "Designer",
        "email": "designer@wbs.com", 
        "role": "user",
        "status": "away"
      },
      {
        "id": "u_004",
        "name": "Developer",
        "email": "developer@wbs.com",
        "role": "user", 
        "status": "offline"
      },
    ];
  }

  // 여기에 다른 API 호출 메소드(getProjectDetail, createProject 등)를 추가할 수 있습니다.
}
