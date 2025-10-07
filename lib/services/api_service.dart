import 'local_database.dart';

// 가짜 서버 URL (실제 서버 주소로 변경해야 함)
const String _baseUrl = 'https://api.example.com';

class ApiService {
  // --- 사용자 인증 관련 ---

  // 로그인 요청 (LocalDatabase 연동)
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // LocalDatabase에서 사용자 조회
      final users = await LocalDatabase.getUsers();
      final user = users.firstWhere(
        (u) => u['id'] == username && u['password'] == password,
        orElse: () => <String, dynamic>{},
      );

      if (user.isEmpty) {
        return {'success': false, 'message': 'Invalid username or password.'};
      }

      return {
        'success': true, 
        'token': 'local-token-${user['id']}',
        'user': {
          'id': user['id'],
          'username': user['id'],
          'role': user['role'],
          'name': user['name'],
          'email': user['email']
        }
      };
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // --- 프로젝트 관련 ---

  // 프로젝트 목록 가져오기 (LocalDatabase 연동)
  static Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      return await LocalDatabase.getProjects();
    } catch (e) {
      print('Error loading projects: $e');
      return [];
    }
  }

  // --- 사용자 관련 ---

  // 사용자 목록 가져오기 (LocalDatabase 연동)
  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      return await LocalDatabase.getUsers();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  // 여기에 다른 API 호출 메소드(getProjectDetail, createProject 등)를 추가할 수 있습니다.
}
