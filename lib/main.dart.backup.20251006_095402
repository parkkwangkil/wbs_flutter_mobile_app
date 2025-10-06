import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'services/api_service.dart';
import 'dart:async';
import 'pages/subscription_page.dart';
import 'pages/admin_security_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/social_service.dart';
import 'widgets/social_share_widget.dart';
import 'pages/social_login_page.dart';

// 언어 관리 클래스
class LanguageManager {
  static String _currentLanguage = 'ko';
  static final ValueNotifier<String> _languageNotifier = ValueNotifier<String>(_currentLanguage);
  
  static String get currentLanguage => _currentLanguage;
  static ValueNotifier<String> get languageNotifier => _languageNotifier;
  
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'ko';
    _languageNotifier.value = _currentLanguage;
  }
  
  static Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    _languageNotifier.value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }
  
  static String getText(String ko, String en) {
    return _currentLanguage == 'ko' ? ko : en;
  }
}

// 테마 관리 클래스
class ThemeManager {
  static bool _isDarkMode = false;
  static ValueNotifier<bool> themeNotifier = ValueNotifier<bool>(_isDarkMode);

  static bool get isDarkMode => _isDarkMode;

  static void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    themeNotifier.value = _isDarkMode;
  }

  static void setTheme(bool isDark) {
    _isDarkMode = isDark;
    themeNotifier.value = _isDarkMode;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      brightness: Brightness.light,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      brightness: Brightness.dark,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageManager.initialize();
  runApp(const WBSApp());
}

// 알림 관리자
class NotificationManager {
  static final List<Map<String, dynamic>> _notifications = [];
  static final StreamController<List<Map<String, dynamic>>> _notificationController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();

  static Stream<List<Map<String, dynamic>>> get notificationStream => _notificationController.stream;

  static void addNotification({
    required String title,
    required String message,
    required String type, // 'info', 'warning', 'success', 'error'
    DateTime? scheduledTime,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'type': type,
      'scheduledTime': scheduledTime ?? DateTime.now(),
      'isRead': false,
    };
    
    _notifications.insert(0, notification);
    _notificationController.add(_notifications);
  }

  static void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      _notificationController.add(_notifications);
    }
  }

  static void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _notificationController.add(_notifications);
  }

  static List<Map<String, dynamic>> get notifications => _notifications;
  static int get unreadCount => _notifications.where((n) => !n['isRead']).length;
}

// 메시지 관리자
class MessageManager {
  static final List<Map<String, dynamic>> _messages = [];
  static final List<Map<String, dynamic>> _chatRooms = [];
  static final StreamController<List<Map<String, dynamic>>> _messageController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();
  static final StreamController<List<Map<String, dynamic>>> _chatRoomController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();

  static Stream<List<Map<String, dynamic>>> get messageStream => _messageController.stream;
  static Stream<List<Map<String, dynamic>>> get chatRoomStream => _chatRoomController.stream;
  static List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);
  static List<Map<String, dynamic>> get chatRooms => List.unmodifiable(_chatRooms);

  static void initializeDefaultChatRooms() {
    if (_chatRooms.isEmpty) {
      _chatRooms.addAll([
        {
          'id': 'general',
          'name': '일반 채팅',
          'description': '전체 팀원과의 일반적인 대화',
          'type': 'group',
          'participants': ['admin', 'devops'],
          'lastMessage': '안녕하세요! 프로젝트 관리 시스템에 오신 것을 환영합니다.',
          'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)),
          'unreadCount': 0,
        },
        {
          'id': 'project_updates',
          'name': '프로젝트 업데이트',
          'description': '프로젝트 진행 상황 공유',
          'type': 'group',
          'participants': ['admin', 'devops'],
          'lastMessage': '새로운 기능이 추가되었습니다.',
          'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 30)),
          'unreadCount': 2,
        },
        {
          'id': 'admin_devops',
          'name': 'Admin ↔ DevOps',
          'description': '개인 메시지',
          'type': 'private',
          'participants': ['admin', 'devops'],
          'lastMessage': '시스템 설정을 확인해주세요.',
          'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 15)),
          'unreadCount': 1,
        },
      ]);
    }
    // 항상 스트림에 데이터 전송
    _chatRoomController.add(List.unmodifiable(_chatRooms));
  }

  static void sendMessage(String chatRoomId, String sender, String content, {String? replyTo}) {
    final message = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'chatRoomId': chatRoomId,
      'sender': sender,
      'content': content,
      'timestamp': DateTime.now(),
      'isRead': false,
      'replyTo': replyTo,
    };
    
    _messages.insert(0, message);
    _messageController.add(List.unmodifiable(_messages));
    
    // 채팅방의 마지막 메시지 업데이트
    final chatRoomIndex = _chatRooms.indexWhere((room) => room['id'] == chatRoomId);
    if (chatRoomIndex != -1) {
      _chatRooms[chatRoomIndex]['lastMessage'] = content;
      _chatRooms[chatRoomIndex]['lastMessageTime'] = DateTime.now();
      _chatRoomController.add(List.unmodifiable(_chatRooms));
    }
  }

  static List<Map<String, dynamic>> getMessagesForChatRoom(String chatRoomId) {
    return _messages.where((message) => message['chatRoomId'] == chatRoomId).toList();
  }

  static void markMessagesAsRead(String chatRoomId, String currentUser) {
    for (var message in _messages) {
      if (message['chatRoomId'] == chatRoomId && 
          message['sender'] != currentUser && 
          !message['isRead']) {
        message['isRead'] = true;
      }
    }
    _messageController.add(List.unmodifiable(_messages));
    
    // 채팅방의 읽지 않은 메시지 수 업데이트
    final chatRoomIndex = _chatRooms.indexWhere((room) => room['id'] == chatRoomId);
    if (chatRoomIndex != -1) {
      final unreadCount = _messages.where((message) => 
          message['chatRoomId'] == chatRoomId && 
          message['sender'] != currentUser && 
          !message['isRead']).length;
      _chatRooms[chatRoomIndex]['unreadCount'] = unreadCount;
      _chatRoomController.add(List.unmodifiable(_chatRooms));
    }
  }

  static void createChatRoom(String name, String description, List<String> participants, {String type = 'group'}) {
    final chatRoom = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'description': description,
      'type': type,
      'participants': participants,
      'lastMessage': '',
      'lastMessageTime': DateTime.now(),
      'unreadCount': 0,
    };
    
    _chatRooms.insert(0, chatRoom);
    _chatRoomController.add(List.unmodifiable(_chatRooms));
  }
}

class WBSApp extends StatelessWidget {
  const WBSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, isDarkMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: LanguageManager.languageNotifier,
          builder: (context, language, child) {
            return MaterialApp(
              title: LanguageManager.getText('WBS 프로젝트 관리', 'WBS Project Management'),
              theme: isDarkMode ? ThemeManager.darkTheme : ThemeManager.lightTheme,
              home: const LoginPage(),
            );
          },
        );
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _currentUser;

  Future<void> _performLogin() async {
    // 실제 API 로그인
    String username = _usernameController.text;
    String password = _passwordController.text;
    
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용자명과 비밀번호를 입력해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Django API로 로그인 시도
      final result = await ApiService.login(username, password);
      
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();
      
      if (result['success']) {
        // 로그인 성공
        setState(() {
          _currentUser = username;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectListPage(currentUser: _currentUser),
          ),
        );
      } else {
        // 로그인 실패
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageManager.getText('WBS 프로젝트 관리', 'WBS Project Management')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.work,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'WBS 프로젝트 관리',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '사용자명 또는 이메일',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
                onSubmitted: (value) {
                  // 다음 필드로 포커스 이동
                  FocusScope.of(context).nextFocus();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  // 엔터키로 로그인 실행
                  _performLogin();
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _performLogin,
                  child: const Text('로그인'),
                ),
              ),
              const SizedBox(height: 16),
              const Text('테스트 계정: devops / devops123'),
              const SizedBox(height: 32),
              const Text(
                '또는',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              // 소셜 로그인 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Google 로그인
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SocialLoginPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  // Naver 로그인
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SocialLoginPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Naver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  // Kakao 로그인
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SocialLoginPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Kakao'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectListPage extends StatefulWidget {
  final String? currentUser;
  const ProjectListPage({super.key, this.currentUser});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  List<Map<String, dynamic>> projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final projectList = await ApiService.getProjects();
      setState(() {
        projects = projectList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로젝트 목록을 불러오는데 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: NotificationManager.notificationStream,
            builder: (context, snapshot) {
              final notifications = NotificationManager.notifications;
              
              if (notifications.isEmpty) {
                return const Center(
                  child: Text('알림이 없습니다.'),
                );
              }
              
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    color: notification['isRead'] ? Colors.grey[100] : Colors.blue[50],
                    child: ListTile(
                      leading: Icon(
                        _getNotificationIcon(notification['type']),
                        color: _getNotificationColor(notification['type']),
                      ),
                      title: Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notification['message']),
                      trailing: Text(
                        _formatTime(notification['scheduledTime']),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        NotificationManager.markAsRead(notification['id']);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              NotificationManager.markAllAsRead();
            },
            child: const Text('모두 읽음'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageManager.getText('프로젝트 목록', 'Project List')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 알림 아이콘
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: NotificationManager.notificationStream,
            builder: (context, snapshot) {
              final unreadCount = NotificationManager.unreadCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      _showNotificationsDialog();
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // 새 프로젝트 생성 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateProjectPage(
                    currentUser: widget.currentUser,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // 사용자 프로필 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(currentUser: widget.currentUser),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 로그아웃 후 로그인 페이지로 이동
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : projects.isEmpty
              ? const Center(
                  child: Text('프로젝트가 없습니다.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getProjectColor(project['color'] ?? 'blue'),
                          child: Text(
                            project['title'][0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(project['title']),
                        subtitle: Text(project['description']),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectDetailPage(
                                      project: project,
                                      currentUser: widget.currentUser,
                                    ),
                                  ),
                                );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateProjectPage(
                currentUser: widget.currentUser,
              ),
            ),
          ).then((newProject) {
            if (newProject != null) {
              _loadProjects(); // 프로젝트 목록 새로고침
            }
          });
        },
        child: const Icon(Icons.add),
        tooltip: '새 프로젝트 생성',
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: LanguageManager.getText('프로젝트', 'Projects'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: LanguageManager.getText('이벤트', 'Events'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: LanguageManager.getText('캘린더', 'Calendar'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: LanguageManager.getText('WBS', 'WBS'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: LanguageManager.getText('팀', 'Team'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: LanguageManager.getText('메시지', 'Messages'),
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: LanguageManager.getText('설정', 'Settings'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timeline),
          label: LanguageManager.getText('간트차트', 'Gantt Chart'),
        ),
        ],
        onTap: (index) {
          // 네비게이션 처리
          switch (index) {
            case 0:
              // 이미 프로젝트 페이지에 있음
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventListPage(),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarPage(),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WBSPage(),
                ),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeamPage(),
                ),
              );
              break;
            case 5:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MessagePage(),
                ),
              );
              break;
            case 6:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
              break;
            case 7: // Gantt Chart
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GanttChartPage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  Color _getProjectColor(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}

class ProfilePage extends StatefulWidget {
  final String? currentUser;
  const ProfilePage({super.key, this.currentUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (widget.currentUser != null) {
      try {
        final users = await ApiService.getUsers();
        final user = users.firstWhere(
          (u) => u['username'] == widget.currentUser || u['email'] == widget.currentUser,
          orElse: () => {},
        );
        if (user.isNotEmpty) {
          setState(() {
            userInfo = user;
          });
        }
      } catch (e) {
        print('사용자 정보 로드 실패: $e');
      }
    }
  }

  void _showEditProfileDialog() {
    final firstNameController = TextEditingController(text: userInfo?['first_name'] ?? '');
    final lastNameController = TextEditingController(text: userInfo?['last_name'] ?? '');
    final emailController = TextEditingController(text: userInfo?['email'] ?? '');
    final departmentController = TextEditingController(text: userInfo?['department'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 편집'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  hintText: '홍길동',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: '성',
                  hintText: '김',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: 'user@example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(
                  labelText: '부서',
                  hintText: '개발팀',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 프로필 정보 업데이트
              if (userInfo != null) {
                try {
                  // API를 통해 프로필 업데이트
                  final result = await ApiService.updateUserProfile(
                    username: userInfo!['username'],
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    email: emailController.text,
                    department: departmentController.text,
                  );
                  
                  if (result['success']) {
                    // 로컬 상태 업데이트
                    setState(() {
                      userInfo!['first_name'] = firstNameController.text;
                      userInfo!['last_name'] = lastNameController.text;
                      userInfo!['email'] = emailController.text;
                      userInfo!['department'] = departmentController.text;
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('프로필이 영구적으로 저장되었습니다.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('프로필 업데이트 중 오류가 발생했습니다: $e')),
                  );
                }
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              userInfo?['first_name'] != null && userInfo?['last_name'] != null
                  ? '${userInfo!['first_name']} ${userInfo!['last_name']}'
                  : widget.currentUser ?? '사용자',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(userInfo?['email'] ?? widget.currentUser ?? 'user@example.com'),
            if (userInfo?['department'] != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(userInfo!['department']),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ],
            if (userInfo?['is_staff'] == true) ...[
              const SizedBox(height: 8),
              Chip(
                label: const Text('관리자'),
                backgroundColor: Colors.red.shade100,
                labelStyle: TextStyle(color: Colors.red.shade800),
              ),
            ],
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('사용자명'),
                    subtitle: Text(userInfo?['username'] ?? widget.currentUser ?? ''),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('이메일'),
                    subtitle: Text(userInfo?['email'] ?? ''),
                  ),
                  ListTile(
                    leading: const Icon(Icons.business),
                    title: const Text('부서'),
                    subtitle: Text(userInfo?['department'] ?? '미정'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('프로필 수정'),
              onTap: () {
                _showEditProfileDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('알림 설정'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('알림 설정 기능은 준비 중입니다.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('도움말'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('도움말 기능은 준비 중입니다.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // 이벤트 추가 메서드
  void _addEvent(Map<String, dynamic> newEvent) {
    setState(() {
      events.insert(0, newEvent); // 새 이벤트를 맨 앞에 추가
    });
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final eventList = await ApiService.getEvents();
      setState(() {
        events = eventList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이벤트 목록을 불러오는데 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageManager.getText('이벤트', 'Events')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : events.isEmpty
              ? const Center(
                  child: Text('이벤트가 없습니다.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.event, color: Colors.blue),
                        title: Text(event['title'] ?? '제목 없음'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event['description'] != null)
                              Text(event['description']),
                            const SizedBox(height: 4),
                            if (event['start_time'] != null)
                              Text(
                                '시작: ${event['start_time']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            if (event['location'] != null)
                              Text(
                                '장소: ${event['location']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // 이벤트 상세 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailPage(
                                event: event,
                                currentUser: null, // 이벤트 페이지에서는 currentUser가 필요하지 않음
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 이벤트 생성 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventPage(
                onEventCreated: _addEvent,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final userList = await ApiService.getUsers();
      setState(() {
        users = userList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('사용자 목록을 불러오는데 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팀원 관리'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              _showAddMemberDialog();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : users.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('팀원이 없습니다.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('새 팀원을 초대해보세요.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // 팀원 통계
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard('총 팀원', '${users.length}명', Icons.people, Colors.blue),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard('관리자', '${users.where((u) => u['is_staff'] == true).length}명', Icons.admin_panel_settings, Colors.red),
                          ),
                        ],
                      ),
                    ),
                    // 팀원 목록
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getUserColor(user['username'] ?? ''),
                                child: Text(
                                  (user['username'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                user['username'] ?? '사용자',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user['email'] ?? '이메일 없음'),
                                  const SizedBox(height: 4),
                                  Text(
                                    user['email'] ?? '',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user['department'] ?? '부서 미정',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  _handleUserAction(value, user);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'profile',
                                    child: Row(
                                      children: [
                                        Icon(Icons.person),
                                        SizedBox(width: 8),
                                        Text('프로필 보기'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('권한 수정'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(Icons.remove_circle, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('팀에서 제거', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                child: const Icon(Icons.more_vert),
                              ),
                              onTap: () {
                                _showUserProfile(user);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Color _getUserColor(String username) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[username.hashCode % colors.length];
  }


  void _showAddMemberDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final departmentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: '사용자 ID',
                  hintText: 'user123',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  hintText: 'password123',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '이메일 주소',
                  hintText: 'user@company.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: '이름',
                        hintText: '홍길',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: '성',
                        hintText: '동',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(
                  labelText: '부서',
                  hintText: '개발팀, 디자인팀, 기획팀 등',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (usernameController.text.isNotEmpty && 
                  passwordController.text.isNotEmpty && 
                  emailController.text.isNotEmpty && 
                  firstNameController.text.isNotEmpty) {
                
                try {
                  // API를 통해 사용자 추가
                  final result = await ApiService.addUser(
                    username: usernameController.text,
                    password: passwordController.text,
                    email: emailController.text,
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    department: departmentController.text.isNotEmpty 
                        ? departmentController.text 
                        : '미정',
                  );
                  
                  if (result['success']) {
                    // 로컬 사용자 목록에 추가
                    setState(() {
                      users.add(result['user']);
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('사용자가 추가되었습니다.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('사용자 추가 중 오류가 발생했습니다: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('필수 정보를 모두 입력해주세요.')),
                );
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showUserProfile(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user['username']} 프로필'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow('사용자명', user['username'] ?? ''),
            _buildProfileRow('이메일', user['email'] ?? ''),
            _buildProfileRow('이름', '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'),
            _buildProfileRow('부서', user['department'] ?? '미정'),
            _buildProfileRow('관리자', user['is_staff'] == true ? '예' : '아니오'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('메시지 전송 기능은 준비 중입니다.')),
              );
            },
            child: const Text('메시지 보내기'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'profile':
        _showUserProfile(user);
        break;
      case 'edit':
        _showEditRoleDialog(user);
        break;
      case 'remove':
        _showRemoveUserDialog(user);
        break;
    }
  }

  void _showEditRoleDialog(Map<String, dynamic> user) {
    String selectedRole = user['is_staff'] == true ? 'admin' : 'member';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user['username']} 권한 수정'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: '역할 선택',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('관리자')),
                    DropdownMenuItem(value: 'member', child: Text('팀원')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 권한 수정
              setState(() {
                final userIndex = users.indexWhere((u) => u['id'] == user['id']);
                if (userIndex != -1) {
                  users[userIndex]['is_staff'] = selectedRole == 'admin';
                }
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('권한이 수정되었습니다.')),
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showRemoveUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팀원 제거'),
        content: Text('${user['username']}을(를) 팀에서 제거하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 팀원 제거
              setState(() {
                users.removeWhere((u) => u['id'] == user['id']);
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user['username']}이(가) 팀에서 제거되었습니다.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('제거', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// 이벤트 생성 페이지
class CreateEventPage extends StatefulWidget {
  final Function(Map<String, dynamic>)? onEventCreated;
  
  const CreateEventPage({
    super.key,
    this.onEventCreated,
  });

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedStatus = 'scheduled';
  DateTime? _startDate;
  DateTime? _endDate;
  final _locationController = TextEditingController();
  Color _selectedColor = Colors.blue;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 이벤트'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEvent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이벤트 제목
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이벤트 제목 *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '이벤트 제목을 입력하세요',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이벤트 제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 이벤트 설명
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이벤트 설명',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '이벤트 설명을 입력하세요',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 이벤트 상태
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이벤트 상태',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'scheduled',
                            child: Text('예정'),
                          ),
                          DropdownMenuItem(
                            value: 'in_progress',
                            child: Text('진행 중'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('완료'),
                          ),
                          DropdownMenuItem(
                            value: 'cancelled',
                            child: Text('취소'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 이벤트 색상
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이벤트 색상',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _getColorName(_selectedColor),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showColorPicker,
                            icon: const Icon(Icons.palette),
                            label: const Text('색상 선택'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 미리보기 색상 옵션들
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _getColorOptions().map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedColor == color 
                                    ? Colors.black 
                                    : Colors.grey.shade300,
                                  width: _selectedColor == color ? 3 : 1,
                                ),
                              ),
                              child: _selectedColor == color
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 시작일
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '시작일',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: Text(
                          _startDate == null 
                            ? '시작일을 선택하세요' 
                            : '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 종료일
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '종료일',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: Text(
                          _endDate == null 
                            ? '종료일을 선택하세요' 
                            : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 장소
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '장소',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '이벤트 장소를 입력하세요',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveEvent,
                  icon: const Icon(Icons.save),
                  label: const Text('이벤트 생성'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      // 이벤트 생성 로직
      final newEvent = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'description': _descriptionController.text,
        'status': _selectedStatus,
        'start_date': _startDate?.toIso8601String().split('T')[0],
        'end_date': _endDate?.toIso8601String().split('T')[0],
        'location': _locationController.text.isNotEmpty ? _locationController.text : '미정',
        'color': _selectedColor.value.toRadixString(16),
        'created_at': DateTime.now().toIso8601String().split('T')[0],
      };
      
      // 콜백 호출하여 이벤트 목록에 추가
      if (widget.onEventCreated != null) {
        widget.onEventCreated!(newEvent);
      }
      
      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이벤트가 생성되었습니다.')),
      );
      
      // 이전 페이지로 돌아가기
      Navigator.pop(context, newEvent);
    }
  }

  // 색상 옵션 목록
  List<Color> _getColorOptions() {
    return [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.brown,
    ];
  }

  // 색상 이름 반환
  String _getColorName(Color color) {
    if (color == Colors.blue) return '파란색';
    if (color == Colors.red) return '빨간색';
    if (color == Colors.green) return '초록색';
    if (color == Colors.orange) return '주황색';
    if (color == Colors.purple) return '보라색';
    if (color == Colors.teal) return '청록색';
    if (color == Colors.pink) return '분홍색';
    if (color == Colors.indigo) return '남색';
    if (color == Colors.amber) return '호박색';
    if (color == Colors.cyan) return '하늘색';
    if (color == Colors.lime) return '라임색';
    if (color == Colors.brown) return '갈색';
    return '기본색';
  }

  // 색상 선택 다이얼로그
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('색상 선택'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _getColorOptions().length,
            itemBuilder: (context, index) {
              final color = _getColorOptions()[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.black : Colors.grey,
                      width: _selectedColor == color ? 3 : 1,
                    ),
                  ),
                  child: _selectedColor == color
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}

// WBS 페이지
class WBSPage extends StatefulWidget {
  const WBSPage({super.key});

  @override
  State<WBSPage> createState() => _WBSPageState();
}

class _WBSPageState extends State<WBSPage> {
  List<Map<String, dynamic>> wbsItems = [];
  List<Map<String, dynamic>> teamMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 팀원 데이터 로드
      final users = await ApiService.getUsers();
      setState(() {
        teamMembers = users;
        wbsItems = _generateWBSData(users);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('데이터 로드 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _generateWBSData(List<Map<String, dynamic>> users) {
    return [
      {
        'id': '1',
        'title': 'WBS 프로젝트 관리 시스템',
        'description': '전체 프로젝트 관리 및 업무 분해 구조',
        'level': 0,
        'parentId': null,
        'assignee': users.isNotEmpty ? users[0]['username'] : '프로젝트 매니저',
        'status': 'in_progress',
        'progress': 65,
        'startDate': '2024-01-01',
        'endDate': '2024-12-31',
        'children': [
          {
            'id': '1.1',
            'title': '📋 기획 및 설계',
            'description': '요구사항 분석 및 시스템 설계',
            'level': 1,
            'parentId': '1',
            'assignee': users.length > 1 ? users[1]['username'] : '기획자',
            'status': 'completed',
            'progress': 100,
            'startDate': '2024-01-01',
            'endDate': '2024-02-28',
            'children': [
              {
                'id': '1.1.1',
                'title': '📊 요구사항 분석',
                'description': '사용자 요구사항 수집 및 분석',
                'level': 2,
                'parentId': '1.1',
                'assignee': users.length > 2 ? users[2]['username'] : '분석가',
                'status': 'completed',
                'progress': 100,
                'startDate': '2024-01-01',
                'endDate': '2024-01-31',
                'children': [],
              },
              {
                'id': '1.1.2',
                'title': '🏗️ 시스템 설계',
                'description': '아키텍처 및 데이터베이스 설계',
                'level': 2,
                'parentId': '1.1',
                'assignee': users.length > 3 ? users[3]['username'] : '설계자',
                'status': 'completed',
                'progress': 100,
                'startDate': '2024-02-01',
                'endDate': '2024-02-28',
                'children': [],
              },
            ],
          },
          {
            'id': '1.2',
            'title': '💻 개발',
            'description': '프론트엔드 및 백엔드 개발',
            'level': 1,
            'parentId': '1',
            'assignee': users.length > 4 ? users[4]['username'] : '개발자',
            'status': 'in_progress',
            'progress': 70,
            'startDate': '2024-03-01',
            'endDate': '2024-08-31',
            'children': [
              {
                'id': '1.2.1',
                'title': '🎨 프론트엔드 개발',
                'description': 'Flutter 모바일 앱 개발',
                'level': 2,
                'parentId': '1.2',
                'assignee': users.length > 5 ? users[5]['username'] : '프론트엔드 개발자',
                'status': 'in_progress',
                'progress': 80,
                'startDate': '2024-03-01',
                'endDate': '2024-07-31',
                'children': [
                  {
                    'id': '1.2.1.1',
                    'title': '📱 UI/UX 디자인',
                    'description': '사용자 인터페이스 설계 및 구현',
                    'level': 3,
                    'parentId': '1.2.1',
                    'assignee': users.length > 6 ? users[6]['username'] : 'UI/UX 디자이너',
                    'status': 'completed',
                    'progress': 100,
                    'startDate': '2024-03-01',
                    'endDate': '2024-04-15',
                    'children': [],
                  },
                  {
                    'id': '1.2.1.2',
                    'title': '⚡ 상태 관리',
                    'description': 'Flutter 상태 관리 구현',
                    'level': 3,
                    'parentId': '1.2.1',
                    'assignee': users.length > 7 ? users[7]['username'] : 'Flutter 개발자',
                    'status': 'in_progress',
                    'progress': 60,
                    'startDate': '2024-04-16',
                    'endDate': '2024-06-30',
                    'children': [],
                  },
                ],
              },
              {
                'id': '1.2.2',
                'title': '🔧 백엔드 개발',
                'description': 'Django API 서버 개발',
                'level': 2,
                'parentId': '1.2',
                'assignee': users.length > 8 ? users[8]['username'] : '백엔드 개발자',
                'status': 'in_progress',
                'progress': 60,
                'startDate': '2024-03-01',
                'endDate': '2024-08-31',
                'children': [
                  {
                    'id': '1.2.2.1',
                    'title': '🗄️ 데이터베이스 설계',
                    'description': 'PostgreSQL 데이터베이스 설계',
                    'level': 3,
                    'parentId': '1.2.2',
                    'assignee': users.length > 9 ? users[9]['username'] : 'DB 설계자',
                    'status': 'completed',
                    'progress': 100,
                    'startDate': '2024-03-01',
                    'endDate': '2024-03-31',
                    'children': [],
                  },
                  {
                    'id': '1.2.2.2',
                    'title': '🔌 API 개발',
                    'description': 'RESTful API 엔드포인트 개발',
                    'level': 3,
                    'parentId': '1.2.2',
                    'assignee': users.length > 10 ? users[10]['username'] : 'API 개발자',
                    'status': 'in_progress',
                    'progress': 40,
                    'startDate': '2024-04-01',
                    'endDate': '2024-07-31',
                    'children': [],
                  },
                ],
              },
            ],
          },
          {
            'id': '1.3',
            'title': '🧪 테스트',
            'description': '단위 테스트 및 통합 테스트',
            'level': 1,
            'parentId': '1',
            'assignee': users.length > 11 ? users[11]['username'] : '테스터',
            'status': 'scheduled',
            'progress': 0,
            'startDate': '2024-09-01',
            'endDate': '2024-10-31',
            'children': [
              {
                'id': '1.3.1',
                'title': '🔍 단위 테스트',
                'description': '개별 모듈 테스트',
                'level': 2,
                'parentId': '1.3',
                'assignee': users.length > 12 ? users[12]['username'] : 'QA 엔지니어',
                'status': 'scheduled',
                'progress': 0,
                'startDate': '2024-09-01',
                'endDate': '2024-09-30',
                'children': [],
              },
              {
                'id': '1.3.2',
                'title': '통합 테스트',
                'description': '전체 시스템 통합 테스트',
                'level': 2,
                'parentId': '1.3',
                'assignee': users.length > 9 ? users[9]['username'] : '테스트 매니저',
                'status': 'scheduled',
                'progress': 0,
                'children': [],
              },
            ],
          },
          {
            'id': '1.4',
            'title': '배포',
            'description': '프로덕션 환경 배포',
            'level': 1,
            'parentId': '1',
            'assignee': users.length > 10 ? users[10]['username'] : 'DevOps 엔지니어',
            'status': 'scheduled',
            'progress': 0,
            'children': [
              {
                'id': '1.4.1',
                'title': '스테이징 배포',
                'description': '테스트 환경 배포',
                'level': 2,
                'parentId': '1.4',
                'assignee': users.length > 11 ? users[11]['username'] : '배포 담당자',
                'status': 'scheduled',
                'progress': 0,
                'children': [],
              },
              {
                'id': '1.4.2',
                'title': '프로덕션 배포',
                'description': '실제 서비스 배포',
                'level': 2,
                'parentId': '1.4',
                'assignee': users.length > 12 ? users[12]['username'] : '운영 담당자',
                'status': 'scheduled',
                'progress': 0,
                'children': [],
              },
            ],
          },
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WBS (Work Breakdown Structure)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddWBSDialog();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // WBS 통계
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('총 작업', '${_countAllTasks(wbsItems)}개', Icons.work, Colors.blue),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard('완료', '${_countCompletedTasks(wbsItems)}개', Icons.check_circle, Colors.green),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard('진행중', '${_countInProgressTasks(wbsItems)}개', Icons.play_circle, Colors.orange),
                      ),
                    ],
                  ),
                ),
                // WBS 트리
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: wbsItems.length,
                    itemBuilder: (context, index) {
                      return _buildWBSItem(wbsItems[index], 0);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildWBSItem(Map<String, dynamic> item, int depth) {
    final children = (item['children'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: depth * 24.0),
          child: Card(
            elevation: depth == 0 ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _getStatusColor(item['status']).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    children: [
                      // 레벨 배지
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getLevelColor(item['level']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'L${item['level']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 제목
                      Expanded(
                        child: Text(
                          item['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: depth == 0 ? 18 : 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      // 상태 칩
                      _buildStatusChip(item['status']),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 설명
                  Text(
                    item['description'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 진행률 바
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '진행률',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${item['progress']}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(item['status']),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: item['progress'] / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(item['status']),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 하단 정보
                  Row(
                    children: [
                      // 담당자
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['assignee'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // 날짜
                      if (item['startDate'] != null)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['startDate'],
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(width: 8),
                      
                      // 액션 메뉴
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          _handleWBSAction(value, item);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('편집'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'add',
                            child: Row(
                              children: [
                                Icon(Icons.add),
                                SizedBox(width: 8),
                                Text('하위 작업 추가'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('삭제', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // 하위 작업들
        ...children.map((child) => _buildWBSItem(child, depth + 1)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'completed':
        color = Colors.green;
        text = '완료';
        break;
      case 'in_progress':
        color = Colors.blue;
        text = '진행중';
        break;
      case 'scheduled':
        color = Colors.orange;
        text = '예정';
        break;
      default:
        color = Colors.grey;
        text = '알 수 없음';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'scheduled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 0:
        return Colors.purple;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      case 'scheduled':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  int _countAllTasks(List<Map<String, dynamic>> items) {
    int count = items.length;
    for (var item in items) {
      final children = (item['children'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      count += _countAllTasks(children);
    }
    return count;
  }

  int _countCompletedTasks(List<Map<String, dynamic>> items) {
    int count = 0;
    for (var item in items) {
      if (item['status'] == 'completed') count++;
      final children = (item['children'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      count += _countCompletedTasks(children);
    }
    return count;
  }

  int _countInProgressTasks(List<Map<String, dynamic>> items) {
    int count = 0;
    for (var item in items) {
      if (item['status'] == 'in_progress') count++;
      final children = (item['children'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      count += _countInProgressTasks(children);
    }
    return count;
  }

  void _handleWBSAction(String action, Map<String, dynamic> item) {
    switch (action) {
      case 'edit':
        _showEditWBSDialog(item);
        break;
      case 'add':
        _showAddSubTaskDialog(item);
        break;
      case 'delete':
        _showDeleteWBSDialog(item);
        break;
    }
  }

  void _showAddWBSDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 WBS 항목 추가'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '설명',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('WBS 항목이 추가되었습니다.')),
              );
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showEditWBSDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item['title']} 편집'),
        content: const Text('WBS 항목 편집 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAddSubTaskDialog(Map<String, dynamic> parentItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${parentItem['title']} 하위 작업 추가'),
        content: const Text('하위 작업 추가 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showDeleteWBSDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WBS 항목 삭제'),
        content: Text('${item['title']}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item['title']}이(가) 삭제되었습니다.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// 캘린더 페이지
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final eventList = await ApiService.getEvents();
      setState(() {
        events = eventList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이벤트 목록을 불러오는데 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // 단일 날짜 이벤트와 기간별 이벤트를 모두 포함
    final singleDayEvents = events.where((event) {
      final eventDate = event['start_date'] != null 
          ? DateTime.parse(event['start_date']) 
          : null;
      if (eventDate == null) return false;
      
      return eventDate.year == day.year &&
             eventDate.month == day.month &&
             eventDate.day == day.day;
    }).toList();
    
    final rangeEvents = _getRangeEventsForDay(day);
    
    // 중복 제거 (같은 이벤트가 단일 날짜와 기간별로 중복될 수 있음)
    final allEvents = <Map<String, dynamic>>[];
    final eventIds = <String>{};
    
    for (final event in [...singleDayEvents, ...rangeEvents]) {
      final eventId = event['id']?.toString() ?? '';
      if (!eventIds.contains(eventId)) {
        eventIds.add(eventId);
        allEvents.add(event);
      }
    }
    
    return allEvents;
  }


  // 기간별 이벤트를 찾는 메서드 (시작일과 종료일이 있는 이벤트)
  List<Map<String, dynamic>> _getRangeEventsForDay(DateTime day) {
    return events.where((event) {
      final startDate = event['start_date'] != null 
          ? DateTime.parse(event['start_date']) 
          : null;
      final endDate = event['end_date'] != null 
          ? DateTime.parse(event['end_date']) 
          : null;
      
      if (startDate == null || endDate == null) return false;
      
      // 해당 날짜가 이벤트 기간 내에 있는지 확인 (시작일과 종료일 포함)
      // 날짜만 비교 (시간 제외)
      final dayOnly = DateTime(day.year, day.month, day.day);
      final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
      final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
      
      return (dayOnly.isAtSameMomentAs(startOnly)) ||
             (dayOnly.isAtSameMomentAs(endOnly)) ||
             (dayOnly.isAfter(startOnly) && dayOnly.isBefore(endOnly));
    }).toList();
  }

  // 이벤트의 색상을 반환하는 메서드
  Color _getEventRangeColor(Map<String, dynamic> event) {
    // 프로젝트 색상이 저장되어 있으면 해당 색상 사용
    if (event['color'] != null) {
      try {
        // color가 문자열인 경우 int로 변환
        if (event['color'] is String) {
          String colorStr = event['color'].toString();
          // 16진수 문자열을 int로 변환
          if (colorStr.length == 8) {
            // "fff44336" -> 0xfff44336
            return Color(int.parse('0x$colorStr'));
          } else if (colorStr.length == 6) {
            // "f44336" -> 0xfff44336
            return Color(int.parse('0xff$colorStr'));
          }
        } else if (event['color'] is int) {
          return Color(event['color']);
        }
      } catch (e) {
        // 색상 변환 실패 시 기본 색상 사용
        print('색상 변환 실패: ${event['color']}, 에러: $e');
      }
    }
    
    // 이벤트 ID나 제목을 기반으로 색상 결정
    final eventId = event['id'] ?? '';
    final title = event['title'] ?? '';
    
    // 첫 번째 프로젝트는 파란색, 두 번째는 빨간색
    if (eventId.contains('1') || title.contains('프로젝트 A') || title.contains('Project A')) {
      return Colors.blue;
    } else if (eventId.contains('2') || title.contains('프로젝트 B') || title.contains('Project B')) {
      return Colors.red;
    } else {
      // 기본 색상들
      final colors = [Colors.green, Colors.orange, Colors.purple, Colors.teal];
      return colors[eventId.hashCode % colors.length];
    }
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return days[date.weekday - 1];
  }

  // 커스텀 날짜 셀 빌더
  Widget _buildCustomDayCell(BuildContext context, DateTime day, DateTime focusedDay, {bool isToday = false, bool isSelected = false}) {
    final rangeEvents = _getRangeEventsForDay(day);
    final singleEvents = _getEventsForDay(day);
    
    return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _getDayBackgroundColor(day, rangeEvents, isToday, isSelected),
            borderRadius: BorderRadius.circular(8),
            border: _getDayBorder(day, rangeEvents, isToday, isSelected),
          ),
          child: Stack(
            children: [
          // 날짜 텍스트
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: _getDayTextColor(day, rangeEvents, isToday, isSelected),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
          // 기간별 이벤트 표시 (연결된 바)
          if (rangeEvents.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildConnectedRangeBars(day, rangeEvents),
            ),
          // 단일 이벤트 마커
          if (singleEvents.isNotEmpty)
            Positioned(
              top: 2,
              right: 2,
              child: _buildSingleEventMarkers(singleEvents),
            ),
        ],
      ),
    );
  }

  // 날짜 배경색 결정
  Color _getDayBackgroundColor(DateTime day, List<Map<String, dynamic>> rangeEvents, bool isToday, bool isSelected) {
    if (isSelected) {
      return Colors.blue.shade600;
    } else if (isToday) {
      return Colors.blue.shade100;
    } else if (rangeEvents.isNotEmpty) {
      // 기간별 이벤트가 있는 날짜는 연한 색상으로 표시
      final eventColor = _getEventRangeColor(rangeEvents.first);
      return eventColor.withOpacity(0.1);
    } else {
      return Colors.transparent;
    }
  }

  // 날짜 테두리 결정
  Border? _getDayBorder(DateTime day, List<Map<String, dynamic>> rangeEvents, bool isToday, bool isSelected) {
    if (isSelected) {
      return Border.all(color: Colors.blue.shade600, width: 2);
    } else if (isToday) {
      return Border.all(color: Colors.blue.shade400, width: 2);
    } else if (rangeEvents.isNotEmpty) {
      final eventColor = _getEventRangeColor(rangeEvents.first);
      return Border.all(color: eventColor.withOpacity(0.3), width: 1);
    }
    return null;
  }

  // 날짜 텍스트 색상 결정
  Color _getDayTextColor(DateTime day, List<Map<String, dynamic>> rangeEvents, bool isToday, bool isSelected) {
    if (isSelected) {
      return Colors.white;
    } else if (isToday) {
      return Colors.blue[800]!;
    } else if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return Colors.red.shade600;
    } else if (rangeEvents.isNotEmpty) {
      final eventColor = _getEventRangeColor(rangeEvents.first);
      return eventColor;
    } else {
      return Colors.black87;
    }
  }

  // 연결된 기간별 이벤트 바 빌드
  Widget _buildConnectedRangeBars(DateTime day, List<Map<String, dynamic>> events) {
    return Row(
      children: events.map((event) {
        final color = _getEventRangeColor(event);
        final startDate = DateTime.tryParse(event['start_date'] ?? '');
        final endDate = DateTime.tryParse(event['end_date'] ?? '');
        
        if (startDate == null || endDate == null) return const SizedBox.shrink();
        
        // 날짜만 비교 (시간 제외)
        final dayOnly = DateTime(day.year, day.month, day.day);
        final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
        final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
        
        // 시작일, 중간일, 종료일 구분
        bool isStart = dayOnly.isAtSameMomentAs(startOnly);
        bool isEnd = dayOnly.isAtSameMomentAs(endOnly);
        bool isMiddle = dayOnly.isAfter(startOnly) && dayOnly.isBefore(endOnly);
        
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 0.5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: isStart ? const Radius.circular(3) : Radius.zero,
                topRight: isEnd ? const Radius.circular(3) : Radius.zero,
                bottomLeft: isStart ? const Radius.circular(3) : Radius.zero,
                bottomRight: isEnd ? const Radius.circular(3) : Radius.zero,
              ),
            ),
            child: isStart || isEnd || isMiddle
                ? Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  // 기간별 이벤트 바 표시 (기존 메서드)
  Widget _buildRangeEventBars(List<Map<String, dynamic>> rangeEvents) {
    return Row(
      children: rangeEvents.take(3).map((event) {
        final color = _getEventRangeColor(event);
        return Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 단일 이벤트 마커 표시
  Widget _buildSingleEventMarkers(List<Map<String, dynamic>> singleEvents) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: singleEvents.take(2).map((event) {
        final color = _getEventColor(event['status']);
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(left: 1),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateEventPage(
                    onEventCreated: (newEvent) {
                      setState(() {
                        events.insert(0, newEvent);
                      });
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 캘린더
                TableCalendar<Map<String, dynamic>>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildCustomDayCell(context, day, focusedDay);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildCustomDayCell(context, day, focusedDay, isToday: true);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildCustomDayCell(context, day, focusedDay, isSelected: true);
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    markersMaxCount: 3,
                    markerDecoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade300,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue.shade400,
                        width: 2,
                      ),
                    ),
                    weekendTextStyle: TextStyle(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    defaultTextStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    holidayTextStyle: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    cellPadding: const EdgeInsets.all(8),
                    cellMargin: const EdgeInsets.all(2),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    leftChevronIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                    ),
                    rightChevronIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                    ),
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800]!,
                    ),
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    headerPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  ),
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
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                ),
                
                // 선택된 날짜의 이벤트 목록
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800]!,
                                      ),
                                    ),
                                    Text(
                                      _getDayOfWeek(_selectedDay!),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildEventsList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEventsList() {
    final dayEvents = _getEventsForDay(_selectedDay!);
    
    if (dayEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.event_available,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '이 날짜에는 이벤트가 없습니다',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새 이벤트를 추가해보세요',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getEventColor(event['status']).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(
                      event: event,
                      currentUser: null,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getEventColor(event['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getEventColor(event['status']).withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        _getEventIcon(event['status']),
                        color: _getEventColor(event['status']),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title'] ?? '제목 없음',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey[800]!,
                            ),
                          ),
                          if (event['description'] != null && event['description'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                event['description'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (event['location'] != null && event['location'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event['location'],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildEventStatusChip(event['status']),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventStatusChip(String status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case 'completed':
        color = Colors.green;
        text = '완료';
        icon = Icons.check_circle;
        break;
      case 'in_progress':
        color = Colors.blue;
        text = '진행 중';
        icon = Icons.play_circle;
        break;
      case 'scheduled':
        color = Colors.orange;
        text = '예정';
        icon = Icons.schedule;
        break;
      case 'cancelled':
        color = Colors.red;
        text = '취소';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = '알 수 없음';
        icon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'scheduled':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      case 'scheduled':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = '한국어';
  String _selectedTheme = '시스템';
  Map<String, dynamic>? _userInfo;
  
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final users = await ApiService.getUsers();
      if (users.isNotEmpty) {
        setState(() {
          _userInfo = users.first; // 첫 번째 사용자 정보 사용
        });
      }
    } catch (e) {
      print('사용자 정보 로드 실패: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 프로필 섹션
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '프로필',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.person, size: 30, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userInfo != null 
                                  ? '${_userInfo!['first_name'] ?? ''} ${_userInfo!['last_name'] ?? ''}'.trim().isEmpty
                                      ? _userInfo!['username'] ?? '사용자'
                                      : '${_userInfo!['first_name'] ?? ''} ${_userInfo!['last_name'] ?? ''}'.trim()
                                  : '사용자',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _userInfo?['email'] ?? 'user@example.com',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            if (_userInfo?['department'] != null) ...[
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(_userInfo!['department']),
                                backgroundColor: Colors.blue.shade100,
                                labelStyle: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditProfileDialog();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 알림 설정
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '알림',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('푸시 알림'),
                    subtitle: const Text('새로운 메시지와 업데이트 알림'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 디스플레이 설정
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '디스플레이',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: ThemeManager.themeNotifier,
                    builder: (context, isDarkMode, child) {
                      return ListTile(
                        leading: const Icon(Icons.dark_mode),
                        title: const Text('다크 모드'),
                        subtitle: const Text('어두운 테마 사용'),
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (value) {
                            ThemeManager.setTheme(value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('다크 모드가 ${value ? '활성화' : '비활성화'}되었습니다.')),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('언어'),
                    subtitle: Text(_selectedLanguage),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showLanguageDialog();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('테마'),
                    subtitle: Text(_selectedTheme),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showThemeDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 계정 설정
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '계정',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('보안'),
                    subtitle: const Text('비밀번호 변경, 2단계 인증'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showAdminSecurityDialog();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('개인정보 보호'),
                    subtitle: const Text('데이터 사용 및 개인정보 설정'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showPrivacyDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 앱 정보
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '앱 정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('버전'),
                    subtitle: const Text('1.0.0'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showVersionDialog();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('도움말'),
                    subtitle: const Text('사용법 및 FAQ'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showHelpDialog();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('구독 관리'),
                    subtitle: const Text('구독 플랜 및 결제'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.ads_click),
                    title: const Text('광고 설정'),
                    subtitle: const Text('광고 표시 및 관리'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showAdSettingsDialog();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_applications),
                    title: const Text('소셜 로그인 설정'),
                    subtitle: const Text('Google, Naver, Kakao API 키 설정'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SocialLoginSettingsPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('로그아웃'),
                    subtitle: const Text('계정에서 로그아웃'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showLogoutDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageManager.getText('언어 선택', 'Language Selection')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(LanguageManager.getText('한국어', 'Korean')),
              value: 'ko',
              groupValue: LanguageManager.currentLanguage,
              onChanged: (value) {
                LanguageManager.setLanguage('ko');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(LanguageManager.getText('언어가 한국어로 변경되었습니다', 'Language changed to Korean'))),
                );
              },
            ),
            RadioListTile<String>(
              title: Text(LanguageManager.getText('English', 'English')),
              value: 'en',
              groupValue: LanguageManager.currentLanguage,
              onChanged: (value) {
                LanguageManager.setLanguage('en');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(LanguageManager.getText('Language changed to English', 'Language changed to English'))),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAdSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('광고 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('배너 광고'),
              subtitle: const Text('하단에 배너 광고 표시'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('배너 광고: ${value ? "활성화" : "비활성화"}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('전면 광고'),
              subtitle: const Text('페이지 전환 시 전면 광고 표시'),
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('전면 광고: ${value ? "활성화" : "비활성화"}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('보상 광고'),
              subtitle: const Text('보상형 광고 표시'),
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('보상 광고: ${value ? "활성화" : "비활성화"}')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showAdminSecurityDialog() {
    bool ipRestriction = false;
    bool timeRestriction = false;
    bool deviceRestriction = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('관리자 보안 설정'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('IP 제한'),
                  subtitle: const Text('특정 IP에서만 접근 허용'),
                  value: ipRestriction,
                  onChanged: (value) {
                    setState(() {
                      ipRestriction = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('IP 제한: ${value ? "활성화" : "비활성화"}')),
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('시간 제한'),
                  subtitle: const Text('특정 시간대에만 접근 허용'),
                  value: timeRestriction,
                  onChanged: (value) {
                    setState(() {
                      timeRestriction = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('시간 제한: ${value ? "활성화" : "비활성화"}')),
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('디바이스 제한'),
                  subtitle: const Text('특정 디바이스에서만 접근 허용'),
                  value: deviceRestriction,
                  onChanged: (value) {
                    setState(() {
                      deviceRestriction = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('디바이스 제한: ${value ? "활성화" : "비활성화"}')),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테마 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('시스템'),
              value: '시스템',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                // 시스템 테마로 변경 (라이트 모드)
                ThemeManager.setTheme(false);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('라이트'),
              value: '라이트',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                // 라이트 테마로 변경
                ThemeManager.setTheme(false);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('다크'),
              value: '다크',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                // 다크 테마로 변경
                ThemeManager.setTheme(true);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }


  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 보호'),
        content: const Text('개인정보 보호 설정 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WBS Project Management'),
            Text('버전: 1.0.0'),
            SizedBox(height: 8),
            Text('개발자: WBS Team'),
            Text('빌드: 2024.01.01'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('도움말'),
        content: const Text('도움말 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final firstNameController = TextEditingController(text: _userInfo?['first_name'] ?? '');
    final lastNameController = TextEditingController(text: _userInfo?['last_name'] ?? '');
    final emailController = TextEditingController(text: _userInfo?['email'] ?? '');
    final departmentController = TextEditingController(text: _userInfo?['department'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 편집'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  hintText: '홍길동',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: '성',
                  hintText: '김',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: 'user@example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(
                  labelText: '부서',
                  hintText: '개발팀',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 프로필 정보 업데이트
              if (_userInfo != null) {
                try {
                  // API를 통해 프로필 업데이트
                  final result = await ApiService.updateUserProfile(
                    username: _userInfo!['username'],
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    email: emailController.text,
                    department: departmentController.text,
                  );
                  
                  if (result['success']) {
                    // 로컬 상태 업데이트
                    setState(() {
                      _userInfo!['first_name'] = firstNameController.text;
                      _userInfo!['last_name'] = lastNameController.text;
                      _userInfo!['email'] = emailController.text;
                      _userInfo!['department'] = departmentController.text;
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('프로필이 영구적으로 저장되었습니다.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('프로필 업데이트 중 오류가 발생했습니다: $e')),
                  );
                }
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // SettingsPage 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그아웃되었습니다.')),
              );
              // 로그인 페이지로 이동 (루트 경로로)
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// 관리자 페이지
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final users = await ApiService.getUsers();
      final projects = await ApiService.getProjects();
      final events = await ApiService.getEvents();
      
      setState(() {
        _users = users;
        _projects = projects;
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터 로드 실패: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 패널'),
        backgroundColor: Colors.red.shade100,
        foregroundColor: Colors.red[800]!,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('데이터를 새로고침했습니다.')),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // 사이드바
          Container(
            width: 250,
            color: Colors.grey.shade100,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSidebarItem(0, Icons.dashboard, '대시보드'),
                _buildSidebarItem(1, Icons.people, '사용자 관리'),
                _buildSidebarItem(2, Icons.work, '프로젝트 관리'),
                _buildSidebarItem(3, Icons.event, '이벤트 관리'),
                _buildSidebarItem(4, Icons.settings, '시스템 설정'),
                _buildSidebarItem(5, Icons.analytics, '통계 및 분석'),
                _buildSidebarItem(6, Icons.security, '보안 설정'),
                _buildSidebarItem(7, Icons.backup, '데이터 관리'),
              ],
            ),
          ),
          // 메인 콘텐츠
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.red : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.red.shade50,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildUserManagement();
      case 2:
        return _buildProjectManagement();
      case 3:
        return _buildEventManagement();
      case 4:
        return _buildSystemSettings();
      case 5:
        return _buildAnalytics();
      case 6:
        return _buildSecuritySettings();
      case 7:
        return _buildDataManagement();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '관리자 대시보드',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // 통계 카드들
          Row(
            children: [
              Expanded(
                child: _buildStatCard('총 사용자', '${_users.length}', Icons.people, Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('활성 프로젝트', '${_projects.length}', Icons.work, Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('이벤트', '${_events.length}', Icons.event, Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('시스템 상태', '정상', Icons.check_circle, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // 최근 활동
          const Text(
            '최근 활동',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: ListView(
                children: [
                  _buildActivityItem('새 사용자가 가입했습니다', '2분 전', Icons.person_add),
                  _buildActivityItem('프로젝트가 완료되었습니다', '1시간 전', Icons.check_circle),
                  _buildActivityItem('새 이벤트가 생성되었습니다', '3시간 전', Icons.event),
                  _buildActivityItem('시스템 백업이 완료되었습니다', '1일 전', Icons.backup),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Icon(Icons.trending_up, color: Colors.green, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(time),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  Widget _buildUserManagement() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '사용자 관리',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(),
                icon: const Icon(Icons.add),
                label: const Text('새 사용자'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return _buildUserItem(
                    user['username'] ?? '',
                    user['email'] ?? '',
                    user['is_staff'] == true ? '관리자' : '사용자',
                    user['is_staff'] == true,
                    user,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(String username, String email, String role, bool isAdmin, Map<String, dynamic> user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isAdmin ? Colors.red : Colors.blue,
        child: Text(username.isNotEmpty ? username[0].toUpperCase() : 'U'),
      ),
      title: Text(username),
      subtitle: Text(email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(role),
            backgroundColor: isAdmin ? Colors.red.shade100 : Colors.blue.shade100,
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditUserDialog(user);
                  break;
                case 'delete':
                  _showDeleteUserDialog(user);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('편집')),
              const PopupMenuItem(value: 'delete', child: Text('삭제')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectManagement() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '프로젝트 관리',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddProjectDialog(),
                icon: const Icon(Icons.add),
                label: const Text('새 프로젝트'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: _projects.length,
                itemBuilder: (context, index) {
                  final project = _projects[index];
                  return _buildProjectItem(project);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(Map<String, dynamic> project) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getProjectStatusColor(project['status']),
        child: Icon(
          _getProjectStatusIcon(project['status']),
          color: Colors.white,
        ),
      ),
      title: Text(project['title'] ?? ''),
      subtitle: Text(project['description'] ?? ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(_getProjectStatusText(project['status'])),
            backgroundColor: _getProjectStatusColor(project['status']).withOpacity(0.2),
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditProjectDialog(project);
                  break;
                case 'delete':
                  _showDeleteProjectDialog(project);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('편집')),
              const PopupMenuItem(value: 'delete', child: Text('삭제')),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProjectStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'on_hold':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getProjectStatusIcon(String? status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      case 'on_hold':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  String _getProjectStatusText(String? status) {
    switch (status) {
      case 'completed':
        return '완료';
      case 'in_progress':
        return '진행 중';
      case 'on_hold':
        return '보류';
      default:
        return '알 수 없음';
    }
  }

  Widget _buildEventManagement() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '이벤트 관리',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddEventDialog(),
                icon: const Icon(Icons.add),
                label: const Text('새 이벤트'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return _buildEventItem(event);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getEventStatusColor(event['status']),
        child: Icon(
          _getEventStatusIcon(event['status']),
          color: Colors.white,
        ),
      ),
      title: Text(event['title'] ?? ''),
      subtitle: Text(event['description'] ?? ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(_getEventStatusText(event['status'])),
            backgroundColor: _getEventStatusColor(event['status']).withOpacity(0.2),
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditEventDialog(event);
                  break;
                case 'delete':
                  _showDeleteEventDialog(event);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('편집')),
              const PopupMenuItem(value: 'delete', child: Text('삭제')),
            ],
          ),
        ],
      ),
    );
  }

  Color _getEventStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'scheduled':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventStatusIcon(String? status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      case 'scheduled':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getEventStatusText(String? status) {
    switch (status) {
      case 'completed':
        return '완료';
      case 'in_progress':
        return '진행 중';
      case 'scheduled':
        return '예정';
      case 'cancelled':
        return '취소';
      default:
        return '알 수 없음';
    }
  }

  Widget _buildSystemSettings() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '시스템 설정',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                // 알림 설정
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '알림 설정',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('푸시 알림'),
                          subtitle: const Text('새로운 메시지와 업데이트 알림'),
                          value: true,
                          onChanged: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('푸시 알림 ${value ? '활성화' : '비활성화'}')),
                            );
                          },
                        ),
                        SwitchListTile(
                          title: const Text('이메일 알림'),
                          subtitle: const Text('중요한 업데이트 이메일 알림'),
                          value: true,
                          onChanged: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('이메일 알림 ${value ? '활성화' : '비활성화'}')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 테마 설정
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '테마 설정',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ValueListenableBuilder<bool>(
                          valueListenable: ThemeManager.themeNotifier,
                          builder: (context, isDarkMode, child) {
                            return Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.light_mode),
                                  title: const Text('라이트 모드'),
                                  trailing: Radio<String>(
                                    value: 'light',
                                    groupValue: isDarkMode ? 'dark' : 'light',
                                    onChanged: (value) {
                                      ThemeManager.setTheme(false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('라이트 모드로 변경되었습니다.')),
                                      );
                                    },
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.dark_mode),
                                  title: const Text('다크 모드'),
                                  trailing: Radio<String>(
                                    value: 'dark',
                                    groupValue: isDarkMode ? 'dark' : 'light',
                                    onChanged: (value) {
                                      ThemeManager.setTheme(value == 'dark');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('다크 모드가 ${value == 'dark' ? '활성화' : '비활성화'}되었습니다.')),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 데이터 관리
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '데이터 관리',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.cleaning_services),
                          title: const Text('캐시 정리'),
                          subtitle: const Text('앱 캐시를 정리합니다'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('캐시가 정리되었습니다')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.storage),
                          title: const Text('데이터베이스 최적화'),
                          subtitle: const Text('데이터베이스 성능을 최적화합니다'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('데이터베이스가 최적화되었습니다')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // 통계 계산
    final projectStats = _calculateProjectStats();
    final eventStats = _calculateEventStats();
    final userStats = _calculateUserStats();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '통계 및 분석',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                // 프로젝트 통계
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '프로젝트 통계',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '총 프로젝트',
                                '${projectStats['total']}',
                                Icons.work,
                                Colors.blue,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '완료된 프로젝트',
                                '${projectStats['completed']}',
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '진행 중',
                                '${projectStats['in_progress']}',
                                Icons.play_circle,
                                Colors.orange,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '보류',
                                '${projectStats['on_hold']}',
                                Icons.pause_circle,
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: projectStats['completion_rate'],
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '완료율: ${(projectStats['completion_rate'] * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 이벤트 통계
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '이벤트 통계',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '총 이벤트',
                                '${eventStats['total']}',
                                Icons.event,
                                Colors.purple,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '완료된 이벤트',
                                '${eventStats['completed']}',
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '예정',
                                '${eventStats['scheduled']}',
                                Icons.schedule,
                                Colors.blue,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '진행 중',
                                '${eventStats['in_progress']}',
                                Icons.play_circle,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 사용자 통계
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '사용자 통계',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '총 사용자',
                                '${userStats['total']}',
                                Icons.people,
                                Colors.blue,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '관리자',
                                '${userStats['admins']}',
                                Icons.admin_panel_settings,
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '일반 사용자',
                                '${userStats['users']}',
                                Icons.person,
                                Colors.green,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '활성 사용자',
                                '${userStats['active']}',
                                Icons.online_prediction,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 월별 생성 추이
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '월별 생성 추이',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildTrendChart(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            '최근 6개월 프로젝트 생성 추이',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBarChart('1월', 0.3, Colors.blue),
                _buildBarChart('2월', 0.5, Colors.blue),
                _buildBarChart('3월', 0.7, Colors.blue),
                _buildBarChart('4월', 0.4, Colors.blue),
                _buildBarChart('5월', 0.8, Colors.blue),
                _buildBarChart('6월', 0.6, Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(String month, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 100 * height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateProjectStats() {
    final total = _projects.length;
    final completed = _projects.where((p) => p['status'] == 'completed').length;
    final inProgress = _projects.where((p) => p['status'] == 'in_progress').length;
    final onHold = _projects.where((p) => p['status'] == 'on_hold').length;
    final completionRate = total > 0 ? completed / total : 0.0;
    
    return {
      'total': total,
      'completed': completed,
      'in_progress': inProgress,
      'on_hold': onHold,
      'completion_rate': completionRate,
    };
  }

  Map<String, dynamic> _calculateEventStats() {
    final total = _events.length;
    final completed = _events.where((e) => e['status'] == 'completed').length;
    final scheduled = _events.where((e) => e['status'] == 'scheduled').length;
    final inProgress = _events.where((e) => e['status'] == 'in_progress').length;
    
    return {
      'total': total,
      'completed': completed,
      'scheduled': scheduled,
      'in_progress': inProgress,
    };
  }

  Map<String, dynamic> _calculateUserStats() {
    final total = _users.length;
    final admins = _users.where((u) => u['is_staff'] == true).length;
    final users = total - admins;
    final active = total; // 모든 사용자를 활성으로 간주
    
    return {
      'total': total,
      'admins': admins,
      'users': users,
      'active': active,
    };
  }

  // 프로젝트 CRUD 메서드들
  void _showAddProjectDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedStatus = 'in_progress';
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('새 프로젝트 추가'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '프로젝트 제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '프로젝트 설명',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '상태',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'in_progress', child: Text('진행 중')),
                    DropdownMenuItem(value: 'completed', child: Text('완료')),
                    DropdownMenuItem(value: 'on_hold', child: Text('보류')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('프로젝트 색상'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildColorOption(Colors.blue, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.blue;
                      });
                    }),
                    _buildColorOption(Colors.green, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.green;
                      });
                    }),
                    _buildColorOption(Colors.orange, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.orange;
                      });
                    }),
                    _buildColorOption(Colors.red, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.red;
                      });
                    }),
                    _buildColorOption(Colors.purple, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.purple;
                      });
                    }),
                    _buildColorOption(Colors.teal, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.teal;
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await ApiService.addProject(
                    title: titleController.text,
                    description: descriptionController.text,
                    status: selectedStatus,
                    color: selectedColor.value.toRadixString(16),
                  );
                  
                  if (result['success']) {
                    Navigator.pop(context);
                    _loadData(); // 데이터 새로고침
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('프로젝트가 추가되었습니다.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('프로젝트 추가 실패: $e')),
                  );
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, Color selectedColor, VoidCallback onTap) {
    final isSelected = color == selectedColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  void _showEditProjectDialog(Map<String, dynamic> project) {
    final titleController = TextEditingController(text: project['title'] ?? '');
    final descriptionController = TextEditingController(text: project['description'] ?? '');
    String selectedStatus = project['status'] ?? 'in_progress';
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('프로젝트 편집'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '프로젝트 제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '프로젝트 설명',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '상태',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'in_progress', child: Text('진행 중')),
                    DropdownMenuItem(value: 'completed', child: Text('완료')),
                    DropdownMenuItem(value: 'on_hold', child: Text('보류')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('프로젝트 색상'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildColorOption(Colors.blue, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.blue;
                      });
                    }),
                    _buildColorOption(Colors.green, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.green;
                      });
                    }),
                    _buildColorOption(Colors.orange, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.orange;
                      });
                    }),
                    _buildColorOption(Colors.red, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.red;
                      });
                    }),
                    _buildColorOption(Colors.purple, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.purple;
                      });
                    }),
                    _buildColorOption(Colors.teal, selectedColor, () {
                      setDialogState(() {
                        selectedColor = Colors.teal;
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('프로젝트 편집 기능은 준비 중입니다.')),
                );
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteProjectDialog(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로젝트 삭제'),
        content: Text('${project['title']} 프로젝트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프로젝트 삭제 기능은 준비 중입니다.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  // 이벤트 CRUD 메서드들
  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    String selectedStatus = 'scheduled';
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('새 이벤트 추가'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '이벤트 제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '이벤트 설명',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: '장소',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '상태',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'scheduled', child: Text('예정')),
                    DropdownMenuItem(value: 'in_progress', child: Text('진행 중')),
                    DropdownMenuItem(value: 'completed', child: Text('완료')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('시작일'),
                        subtitle: Text(startDate != null 
                            ? '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}'
                            : '선택하세요'),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setDialogState(() {
                              startDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('종료일'),
                        subtitle: Text(endDate != null 
                            ? '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'
                            : '선택하세요'),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: startDate ?? DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setDialogState(() {
                              endDate = date;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (startDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('시작일을 선택해주세요.')),
                  );
                  return;
                }
                
                try {
                  final result = await ApiService.addEvent(
                    title: titleController.text,
                    description: descriptionController.text,
                    startDate: '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}',
                    endDate: endDate != null 
                        ? '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'
                        : null,
                    status: selectedStatus,
                    location: locationController.text,
                    attendees: [],
                    hasAlarm: false,
                    alarmMinutes: 15,
                  );
                  
                  if (result['success']) {
                    Navigator.pop(context);
                    _loadData(); // 데이터 새로고침
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이벤트가 추가되었습니다.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('이벤트 추가 실패: $e')),
                  );
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEventDialog(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이벤트 편집'),
        content: const Text('이벤트 편집 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showDeleteEventDialog(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이벤트 삭제'),
        content: Text('${event['title']} 이벤트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이벤트 삭제 기능은 준비 중입니다.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '보안 설정',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                // 사용자 권한 관리
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '사용자 권한 관리',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.admin_panel_settings),
                          title: const Text('관리자 권한'),
                          subtitle: const Text('시스템 전체 관리 권한'),
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('관리자 권한 ${value ? '활성화' : '비활성화'}')),
                              );
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('편집 권한'),
                          subtitle: const Text('프로젝트 및 이벤트 편집 권한'),
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('편집 권한 ${value ? '활성화' : '비활성화'}')),
                              );
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.visibility),
                          title: const Text('조회 권한'),
                          subtitle: const Text('데이터 조회 권한'),
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('조회 권한 ${value ? '활성화' : '비활성화'}')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 접근 제어
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '접근 제어',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('IP 제한'),
                          subtitle: const Text('특정 IP에서만 접근 허용'),
                          trailing: Switch(
                            value: false,
                            onChanged: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('IP 제한 ${value ? '활성화' : '비활성화'}')),
                              );
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.schedule),
                          title: const Text('시간 제한'),
                          subtitle: const Text('특정 시간대에만 접근 허용'),
                          trailing: Switch(
                            value: false,
                            onChanged: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('시간 제한 ${value ? '활성화' : '비활성화'}')),
                              );
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.device_hub),
                          title: const Text('디바이스 제한'),
                          subtitle: const Text('등록된 디바이스에서만 접근'),
                          trailing: Switch(
                            value: false,
                            onChanged: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('디바이스 제한 ${value ? '활성화' : '비활성화'}')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 보안 로그
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '보안 로그',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildSecurityLogItem('로그인 시도', 'admin', '2024-01-15 14:30:25', '성공'),
                        _buildSecurityLogItem('권한 변경', 'admin', '2024-01-15 14:25:10', '성공'),
                        _buildSecurityLogItem('데이터 접근', 'user1', '2024-01-15 14:20:05', '성공'),
                        _buildSecurityLogItem('로그인 시도', 'unknown', '2024-01-15 14:15:30', '실패'),
                        _buildSecurityLogItem('시스템 설정 변경', 'admin', '2024-01-15 14:10:15', '성공'),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('보안 로그를 내보냈습니다.')),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('로그 내보내기'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 보안 정책
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '보안 정책',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.password),
                          title: const Text('비밀번호 정책'),
                          subtitle: const Text('최소 8자, 특수문자 포함'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('비밀번호 정책 설정으로 이동')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.timer),
                          title: const Text('세션 타임아웃'),
                          subtitle: const Text('30분 후 자동 로그아웃'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('세션 설정으로 이동')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.security),
                          title: const Text('2단계 인증'),
                          subtitle: const Text('SMS 또는 이메일 인증'),
                          trailing: Switch(
                            value: false,
                            onChanged: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('2단계 인증 ${value ? '활성화' : '비활성화'}')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityLogItem(String action, String user, String time, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status == '성공' ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status == '성공' ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            status == '성공' ? Icons.check_circle : Icons.error,
            color: status == '성공' ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$user • $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(status),
            backgroundColor: status == '성공' ? Colors.green.shade100 : Colors.red.shade100,
            labelStyle: TextStyle(
              color: status == '성공' ? Colors.green.shade800 : Colors.red.shade800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagement() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '데이터 관리',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                // 백업 및 복원
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '백업 및 복원',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.backup),
                          title: const Text('자동 백업'),
                          subtitle: const Text('매일 자동으로 데이터 백업'),
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('자동 백업 ${value ? '활성화' : '비활성화'}')),
                              );
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.cloud_upload),
                          title: const Text('클라우드 백업'),
                          subtitle: const Text('Google Drive, Dropbox 연동'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('클라우드 백업 설정으로 이동')),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('백업이 시작되었습니다.')),
                                  );
                                },
                                icon: const Icon(Icons.backup),
                                label: const Text('지금 백업'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('복원이 시작되었습니다.')),
                                  );
                                },
                                icon: const Icon(Icons.restore),
                                label: const Text('복원'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 데이터 내보내기/가져오기
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '데이터 내보내기/가져오기',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.file_download),
                          title: const Text('CSV 내보내기'),
                          subtitle: const Text('프로젝트 및 이벤트 데이터를 CSV로 내보내기'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('CSV 파일이 다운로드되었습니다.')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.file_upload),
                          title: const Text('CSV 가져오기'),
                          subtitle: const Text('CSV 파일에서 데이터 가져오기'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('CSV 파일 선택 다이얼로그가 열렸습니다.')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: const Text('JSON 내보내기'),
                          subtitle: const Text('전체 데이터를 JSON 형식으로 내보내기'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('JSON 파일이 다운로드되었습니다.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 데이터 정리
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '데이터 정리',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.delete_sweep),
                          title: const Text('휴지통 비우기'),
                          subtitle: const Text('삭제된 항목들을 완전히 제거'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('휴지통 비우기'),
                                content: const Text('삭제된 모든 항목이 완전히 제거됩니다. 계속하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('취소'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('휴지통이 비워졌습니다.')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('비우기'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.cleaning_services),
                          title: const Text('중복 데이터 정리'),
                          subtitle: const Text('중복된 항목들을 자동으로 정리'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('중복 데이터 정리가 완료되었습니다.')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.storage),
                          title: const Text('캐시 정리'),
                          subtitle: const Text('임시 파일 및 캐시 데이터 정리'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('캐시가 정리되었습니다.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 저장소 정보
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '저장소 정보',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildStorageInfo('프로젝트 데이터', '2.3 MB', '15개 항목'),
                        _buildStorageInfo('이벤트 데이터', '1.8 MB', '42개 항목'),
                        _buildStorageInfo('사용자 데이터', '0.5 MB', '8개 항목'),
                        _buildStorageInfo('백업 파일', '12.4 MB', '5개 파일'),
                        _buildStorageInfo('캐시 데이터', '3.2 MB', '임시 파일'),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '총 사용량',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '20.2 MB',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '사용 가능: 479.8 MB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfo(String title, String size, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.folder, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            size,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }




  // 사용자 관리 다이얼로그들
  void _showAddUserDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final departmentController = TextEditingController();
    bool isAdmin = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('새 사용자 추가'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: '사용자명',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: '성',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    labelText: '부서',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('관리자 권한'),
                  value: isAdmin,
                  onChanged: (value) {
                    setDialogState(() {
                      isAdmin = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await ApiService.addUser(
                    username: usernameController.text,
                    password: passwordController.text,
                    email: emailController.text,
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    department: departmentController.text,
                  );
                  
                  if (result['success']) {
                    Navigator.pop(context);
                    _loadData(); // 데이터 새로고침
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('사용자가 추가되었습니다.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('사용자 추가 실패: $e')),
                  );
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final usernameController = TextEditingController(text: user['username'] ?? '');
    final emailController = TextEditingController(text: user['email'] ?? '');
    final firstNameController = TextEditingController(text: user['first_name'] ?? '');
    final lastNameController = TextEditingController(text: user['last_name'] ?? '');
    final departmentController = TextEditingController(text: user['department'] ?? '');
    bool isAdmin = user['is_staff'] == true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('사용자 편집'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: '사용자명',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: '성',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    labelText: '부서',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('관리자 권한'),
                  value: isAdmin,
                  onChanged: (value) {
                    setDialogState(() {
                      isAdmin = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await ApiService.updateUserProfile(
                    username: user['username'],
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    email: emailController.text,
                    department: departmentController.text,
                  );
                  
                  if (result['success']) {
                    Navigator.pop(context);
                    _loadData(); // 데이터 새로고침
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('사용자 정보가 업데이트되었습니다.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('사용자 업데이트 실패: $e')),
                  );
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 삭제'),
        content: Text('${user['username']} 사용자를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 실제 삭제 로직은 ApiService에 deleteUser 메서드가 필요
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('사용자 삭제 기능은 준비 중입니다.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class ProjectDetailPage extends StatefulWidget {
  final Map<String, dynamic> project;
  final String? currentUser;
  
  const ProjectDetailPage({
    super.key,
    required this.project,
    this.currentUser,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  bool isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project['title']);
    _descriptionController = TextEditingController(text: widget.project['description']);
    _selectedStatus = widget.project['status'] ?? 'in_progress';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '프로젝트 편집' : '프로젝트 상세'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                 actions: [
                   if (!isEditing)
                     IconButton(
                       icon: const Icon(Icons.edit),
                       onPressed: () {
                         setState(() {
                           isEditing = true;
                         });
                       },
                     ),
                   if (!isEditing)
                     IconButton(
                       icon: const Icon(Icons.delete),
                       onPressed: () {
                         _deleteProject();
                       },
                     ),
                   if (isEditing)
                     IconButton(
                       icon: const Icon(Icons.save),
                       onPressed: () {
                         _saveProject();
                       },
                     ),
                   if (isEditing)
                     IconButton(
                       icon: const Icon(Icons.close),
                       onPressed: () {
                         setState(() {
                           isEditing = false;
                         });
                       },
                     ),
                 ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로젝트 제목
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '프로젝트 제목',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isEditing
                        ? TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '프로젝트 제목을 입력하세요',
                            ),
                          )
                        : Text(
                            widget.project['title'],
                            style: const TextStyle(fontSize: 18),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 프로젝트 설명
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '프로젝트 설명',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isEditing
                        ? TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '프로젝트 설명을 입력하세요',
                            ),
                          )
                        : Text(
                            widget.project['description'],
                            style: const TextStyle(fontSize: 16),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 프로젝트 상태
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '프로젝트 상태',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isEditing
                        ? DropdownButton<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'in_progress',
                                child: Text('진행 중'),
                              ),
                              DropdownMenuItem(
                                value: 'completed',
                                child: Text('완료'),
                              ),
                              DropdownMenuItem(
                                value: 'on_hold',
                                child: Text('보류'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          )
                        : Row(
                            children: [
                              Icon(
                                _getStatusIcon(widget.project['status']),
                                color: _getStatusColor(widget.project['status']),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusText(widget.project['status']),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _getStatusColor(widget.project['status']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 프로젝트 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '프로젝트 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('시작일', widget.project['start_date'] ?? '미정'),
                    _buildInfoRow('종료일', widget.project['end_date'] ?? '미정'),
                    _buildInfoRow('관리자', widget.project['manager'] ?? '미정'),
                    _buildInfoRow('생성일', widget.project['created_at'] ?? '미정'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 액션 버튼들
            if (!isEditing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WBSPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.account_tree),
                      label: const Text('WBS 트리'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TeamPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.group),
                      label: const Text('팀원 관리'),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 20),
            
            // 댓글 섹션 (임시 주석 처리)
            // _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      case 'on_hold':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'on_hold':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return '완료';
      case 'in_progress':
        return '진행 중';
      case 'on_hold':
        return '보류';
      default:
        return '알 수 없음';
    }
  }

  void _saveProject() {
    // 프로젝트 저장 로직
    setState(() {
      isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프로젝트가 저장되었습니다.')),
    );
  }

  void _deleteProject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로젝트 삭제'),
        content: const Text('이 프로젝트를 삭제하시겠습니까?\n삭제된 프로젝트는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 프로젝트 상세 페이지 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프로젝트가 삭제되었습니다.')),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// 프로젝트 생성 페이지
class CreateProjectPage extends StatefulWidget {
  final String? currentUser;
  
  const CreateProjectPage({
    super.key,
    this.currentUser,
  });

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedStatus = 'in_progress';
  DateTime? _startDate;
  DateTime? _endDate;
  final _managerController = TextEditingController();
  Color _selectedColor = Colors.blue;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _managerController.dispose();
    super.dispose();
  }

  Widget _buildColorOption(Color color, String label) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Center(
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 24)
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 프로젝트'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProject,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로젝트 제목
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '프로젝트 제목 *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '프로젝트 제목을 입력하세요',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '프로젝트 제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 프로젝트 설명
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '프로젝트 설명',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '프로젝트 설명을 입력하세요',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 프로젝트 상태
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '프로젝트 상태',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'in_progress',
                            child: Text('진행 중'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('완료'),
                          ),
                          DropdownMenuItem(
                            value: 'on_hold',
                            child: Text('보류'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 시작일
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '시작일',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: Text(
                          _startDate == null 
                            ? '시작일을 선택하세요' 
                            : '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 종료일
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '종료일',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: Text(
                          _endDate == null 
                            ? '종료일을 선택하세요' 
                            : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 프로젝트 색상
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '프로젝트 색상',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildColorOption(Colors.blue, '파란색'),
                          _buildColorOption(Colors.red, '빨간색'),
                          _buildColorOption(Colors.green, '초록색'),
                          _buildColorOption(Colors.orange, '주황색'),
                          _buildColorOption(Colors.purple, '보라색'),
                          _buildColorOption(Colors.teal, '청록색'),
                          _buildColorOption(Colors.pink, '분홍색'),
                          _buildColorOption(Colors.indigo, '남색'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 관리자
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '관리자',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _managerController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '관리자 이름을 입력하세요',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProject,
                  icon: const Icon(Icons.save),
                  label: const Text('프로젝트 생성'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      // 프로젝트 생성 로직
      final newProject = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'description': _descriptionController.text,
        'status': _selectedStatus,
        'start_date': _startDate?.toIso8601String().split('T')[0],
        'end_date': _endDate?.toIso8601String().split('T')[0],
        'manager': _managerController.text.isNotEmpty ? _managerController.text : '미정',
        'created_at': DateTime.now().toIso8601String().split('T')[0],
        'color': _selectedColor.value.toRadixString(16), // 색상 정보를 16진수 문자열로 저장
      };
      
      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로젝트가 생성되었습니다.')),
      );
      
      // 알림 추가
      NotificationManager.addNotification(
        title: '새 프로젝트 생성',
        message: '${_titleController.text} 프로젝트가 생성되었습니다.',
        type: 'success',
      );
      
      // 이전 페이지로 돌아가기
      Navigator.pop(context, newProject);
    }
  }
}

// 이벤트 상세 페이지
class EventDetailPage extends StatefulWidget {
  final Map<String, dynamic> event;
  final String? currentUser;
  
  const EventDetailPage({
    super.key,
    required this.event,
    this.currentUser,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // 알람 관련 변수
  bool _hasAlarm = false;
  int _alarmMinutes = 15; // 기본 15분 전 알람
  List<String> _attendees = []; // 참석자 목록
  final TextEditingController _attendeeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event['title']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.event['description']?.toString() ?? '');
    _selectedStatus = widget.event['status']?.toString() ?? 'scheduled';
    _startDate = widget.event['start_date'] != null 
        ? DateTime.tryParse(widget.event['start_date'].toString()) 
        : null;
    _endDate = widget.event['end_date'] != null 
        ? DateTime.tryParse(widget.event['end_date'].toString()) 
        : null;
    
    // 알람 및 참석자 정보 로드
    _hasAlarm = widget.event['has_alarm'] ?? false;
    _alarmMinutes = widget.event['alarm_minutes'] ?? 15;
    _attendees = List<String>.from(widget.event['attendees'] ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _attendeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '이벤트 편집' : '이벤트 상세'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteEvent();
              },
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                _saveEvent();
              },
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isEditing = false;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이벤트 제목
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '이벤트 제목',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isEditing
                        ? TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '이벤트 제목을 입력하세요',
                            ),
                          )
                        : Text(
                            widget.event['title']?.toString() ?? '제목 없음',
                            style: const TextStyle(fontSize: 18),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 이벤트 설명
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '이벤트 설명',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isEditing
                        ? TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '이벤트 설명을 입력하세요',
                            ),
                          )
                        : Text(
                            widget.event['description']?.toString() ?? '설명 없음',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 이벤트 상태
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '이벤트 상태',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isEditing
                        ? DropdownButton<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'scheduled',
                                child: Text('예정'),
                              ),
                              DropdownMenuItem(
                                value: 'in_progress',
                                child: Text('진행 중'),
                              ),
                              DropdownMenuItem(
                                value: 'completed',
                                child: Text('완료'),
                              ),
                              DropdownMenuItem(
                                value: 'cancelled',
                                child: Text('취소'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          )
                        : Row(
                            children: [
                              Icon(
                                _getStatusIcon(widget.event['status']?.toString() ?? 'scheduled'),
                                color: _getStatusColor(widget.event['status']?.toString() ?? 'scheduled'),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusText(widget.event['status']?.toString() ?? 'scheduled'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _getStatusColor(widget.event['status']?.toString() ?? 'scheduled'),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 이벤트 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '이벤트 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('시작일', _startDate != null 
                        ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
                        : '미정'),
                    _buildInfoRow('종료일', _endDate != null 
                        ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
                        : '미정'),
                    _buildInfoRow('생성일', widget.event['created_at']?.toString() ?? '미정'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 알람 설정
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '알람 설정',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Switch(
                          value: _hasAlarm,
                          onChanged: (value) {
                            setState(() {
                              _hasAlarm = value;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(_hasAlarm ? '알람 활성화' : '알람 비활성화'),
                      ],
                    ),
                    if (_hasAlarm) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('알람 시간: '),
                          DropdownButton<int>(
                            value: _alarmMinutes,
                            items: const [
                              DropdownMenuItem(value: 5, child: Text('5분 전')),
                              DropdownMenuItem(value: 15, child: Text('15분 전')),
                              DropdownMenuItem(value: 30, child: Text('30분 전')),
                              DropdownMenuItem(value: 60, child: Text('1시간 전')),
                              DropdownMenuItem(value: 1440, child: Text('1일 전')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _alarmMinutes = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 참석자 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '참석자',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addAttendee,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_attendees.isEmpty)
                      const Text(
                        '참석자가 없습니다.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ..._attendees.map((attendee) => ListTile(
                        leading: const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 16),
                        ),
                        title: Text(attendee),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => _removeAttendee(attendee),
                        ),
                      )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 액션 버튼들
            if (!isEditing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAlarmSettings();
                      },
                      icon: const Icon(Icons.notifications),
                      label: const Text('알림 설정'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAttendeeManagement();
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('참석자 관리'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      case 'scheduled':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'scheduled':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return '완료';
      case 'in_progress':
        return '진행 중';
      case 'scheduled':
        return '예정';
      case 'cancelled':
        return '취소';
      default:
        return '알 수 없음';
    }
  }

  void _saveEvent() {
    // 이벤트 저장 로직
    setState(() {
      isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이벤트가 저장되었습니다.')),
    );
  }

  void _addAttendee() async {
    // 등록된 팀원 목록 가져오기
    final teamMembers = await ApiService.getUsers();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedMembers = <String>{};
          
          return AlertDialog(
            title: const Text('참석자 추가'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // 수동 입력 옵션
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '수동 입력',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _attendeeController,
                            decoration: const InputDecoration(
                              labelText: '참석자 이름',
                              hintText: '홍길동',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_attendeeController.text.isNotEmpty) {
                                setState(() {
                                  _attendees.add(_attendeeController.text);
                                });
                                _attendeeController.clear();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('참석자가 추가되었습니다.')),
                                );
                              }
                            },
                            child: const Text('수동 추가'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 팀원 목록에서 선택
                  const Text(
                    '등록된 팀원에서 선택',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: teamMembers.length,
                      itemBuilder: (context, index) {
                        final member = teamMembers[index];
                        final memberName = '${member['first_name']} ${member['last_name']}';
                        final isSelected = selectedMembers.contains(memberName);
                        
                        return CheckboxListTile(
                          title: Text(memberName),
                          subtitle: Text('${member['username']} (${member['department']})'),
                          value: isSelected,
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedMembers.add(memberName);
                              } else {
                                selectedMembers.remove(memberName);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _attendeeController.clear();
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedMembers.isNotEmpty) {
                    setState(() {
                      _attendees.addAll(selectedMembers);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${selectedMembers.length}명의 참석자가 추가되었습니다.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('참석자를 선택해주세요.')),
                    );
                  }
                },
                child: const Text('선택 추가'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _removeAttendee(String attendee) {
    setState(() {
      _attendees.remove(attendee);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$attendee 참석자가 제거되었습니다.')),
    );
  }

  void _showAlarmSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('알림 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('알림 활성화'),
                  Switch(
                    value: _hasAlarm,
                    onChanged: (value) {
                      setDialogState(() {
                        _hasAlarm = value;
                      });
                    },
                  ),
                ],
              ),
              if (_hasAlarm) ...[
                const SizedBox(height: 16),
                const Text('알림 시간'),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  value: _alarmMinutes,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5분 전')),
                    DropdownMenuItem(value: 15, child: Text('15분 전')),
                    DropdownMenuItem(value: 30, child: Text('30분 전')),
                    DropdownMenuItem(value: 60, child: Text('1시간 전')),
                    DropdownMenuItem(value: 1440, child: Text('1일 전')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _alarmMinutes = value!;
                    });
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // 알람 설정 저장
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('알림 설정이 저장되었습니다.')),
                );
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttendeeManagement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('참석자 관리'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('참석자 목록'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.pop(context);
                      _addAttendee();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_attendees.isEmpty)
                const Text(
                  '참석자가 없습니다.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ..._attendees.map((attendee) => ListTile(
                  leading: const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 16),
                  ),
                  title: Text(attendee),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _attendees.remove(attendee);
                      });
                    },
                  ),
                )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이벤트 삭제'),
        content: const Text('이 이벤트를 삭제하시겠습니까?\n삭제된 이벤트는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 이벤트 상세 페이지 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이벤트가 삭제되었습니다.')),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// 메시지 페이지
class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  void initState() {
    super.initState();
    MessageManager.initializeDefaultChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메시지'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateChatRoomDialog();
        },
        child: const Icon(Icons.add),
        tooltip: '새 채팅방 만들기',
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: MessageManager.chatRoomStream,
        initialData: MessageManager.chatRooms,
        builder: (context, snapshot) {
          final chatRooms = snapshot.data ?? MessageManager.chatRooms;
          
          if (chatRooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '채팅방이 없습니다',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '+ 버튼을 눌러 새 채팅방을 만들어보세요',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              return _buildChatRoomItem(chatRoom);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatRoomItem(Map<String, dynamic> chatRoom) {
    final unreadCount = chatRoom['unreadCount'] as int;
    final lastMessageTime = chatRoom['lastMessageTime'] as DateTime;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: chatRoom['type'] == 'private' 
              ? Colors.blue.shade100 
              : Colors.green.shade100,
          child: Icon(
            chatRoom['type'] == 'private' ? Icons.person : Icons.group,
            color: chatRoom['type'] == 'private' 
                ? Colors.blue.shade800 
                : Colors.green.shade800,
          ),
        ),
        title: Text(
          chatRoom['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatRoom['lastMessage'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: unreadCount > 0
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomPage(
                chatRoom: chatRoom,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  void _showCreateChatRoomDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 채팅방 만들기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '채팅방 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '설명',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                MessageManager.createChatRoom(
                  nameController.text,
                  descriptionController.text,
                  ['admin', 'devops'], // 기본 참가자
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('채팅방이 생성되었습니다.')),
                );
              }
            },
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }
}

// 간트 차트 페이지
class GanttChartPage extends StatefulWidget {
  const GanttChartPage({super.key});

  @override
  State<GanttChartPage> createState() => _GanttChartPageState();
}

class _GanttChartPageState extends State<GanttChartPage> {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await ApiService.getProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('간트 차트'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadProjects();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timeline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '프로젝트가 없습니다',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '새 프로젝트를 생성해보세요',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : _buildGanttChart(),
    );
  }

  Widget _buildGanttChart() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // 프로젝트 이름 컬럼
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    '프로젝트',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // 날짜 헤더 (Expanded 제거)
                _buildDateHeader(),
              ],
            ),
          ),
          // 프로젝트 행들
          ..._projects.map((project) => _buildProjectRow(project)),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 1, 1);
    final endDate = DateTime(now.year, now.month + 2, 0);
    final days = endDate.difference(startDate).inDays + 1;

    return Container(
      height: 60,
      width: days * 30.0, // 고정 너비 설정
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isToday = date.year == now.year && 
                       date.month == now.month && 
                       date.day == now.day;
          
          return Container(
            width: 30,
            decoration: BoxDecoration(
              color: isToday 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  _getMonthName(date.month),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectRow(Map<String, dynamic> project) {
    final projectColor = _getProjectColor(project['color'] ?? 'blue');
    final progress = _getProjectProgress(project);
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 프로젝트 이름
          Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: projectColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project['title'] ?? '제목 없음',
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // 진행률 바 (Expanded 제거하고 고정 너비)
          _buildProgressBar(project, projectColor, progress),
        ],
      ),
    );
  }

  // 마일스톤 관리 기능 추가
  Widget _buildMilestoneSection(Map<String, dynamic> project) {
    final milestones = project['milestones'] as List<Map<String, dynamic>>? ?? [];
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '마일스톤',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => _showAddMilestoneDialog(project),
                  icon: const Icon(Icons.add),
                  tooltip: '마일스톤 추가',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (milestones.isEmpty)
              const Center(
                child: Text(
                  '마일스톤이 없습니다',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...milestones.map((milestone) => _buildMilestoneItem(milestone, project)),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneItem(Map<String, dynamic> milestone, Map<String, dynamic> project) {
    final isCompleted = milestone['isCompleted'] ?? false;
    final dueDate = DateTime.tryParse(milestone['dueDate'] ?? '');
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now()) && !isCompleted;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? Colors.green : (isOverdue ? Colors.red : Colors.grey),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (value) => _toggleMilestone(project, milestone, value ?? false),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone['title'] ?? '제목 없음',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (milestone['description'] != null)
                  Text(
                    milestone['description'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                if (dueDate != null)
                  Text(
                    '마감일: ${dueDate.year}-${dueDate.month}-${dueDate.day}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditMilestoneDialog(project, milestone);
              } else if (value == 'delete') {
                _deleteMilestone(project, milestone);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('편집')),
              const PopupMenuItem(value: 'delete', child: Text('삭제')),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneDialog(Map<String, dynamic> project) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('마일스톤 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '마일스톤 제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '설명 (선택사항)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(selectedDate == null 
                  ? '마감일 선택' 
                  : '마감일: ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  selectedDate = date;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addMilestone(project, {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'dueDate': selectedDate?.toIso8601String(),
                  'isCompleted': false,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _addMilestone(Map<String, dynamic> project, Map<String, dynamic> milestone) {
    setState(() {
      if (project['milestones'] == null) {
        project['milestones'] = <Map<String, dynamic>>[];
      }
      (project['milestones'] as List<Map<String, dynamic>>).add(milestone);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('마일스톤이 추가되었습니다')),
    );
  }

  void _toggleMilestone(Map<String, dynamic> project, Map<String, dynamic> milestone, bool isCompleted) {
    setState(() {
      milestone['isCompleted'] = isCompleted;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isCompleted ? '마일스톤이 완료되었습니다' : '마일스톤이 미완료로 변경되었습니다')),
    );
  }

  void _showEditMilestoneDialog(Map<String, dynamic> project, Map<String, dynamic> milestone) {
    final titleController = TextEditingController(text: milestone['title']);
    final descriptionController = TextEditingController(text: milestone['description'] ?? '');
    DateTime? selectedDate = milestone['dueDate'] != null 
        ? DateTime.tryParse(milestone['dueDate']) 
        : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('마일스톤 편집'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '마일스톤 제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '설명 (선택사항)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(selectedDate == null 
                  ? '마감일 선택' 
                  : '마감일: ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  selectedDate = date;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  milestone['title'] = titleController.text;
                  milestone['description'] = descriptionController.text;
                  milestone['dueDate'] = selectedDate?.toIso8601String();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _deleteMilestone(Map<String, dynamic> project, Map<String, dynamic> milestone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('마일스톤 삭제'),
        content: const Text('이 마일스톤을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                (project['milestones'] as List<Map<String, dynamic>>).remove(milestone);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('마일스톤이 삭제되었습니다')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Map<String, dynamic> project, Color projectColor, double progress) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 1, 1);
    final endDate = DateTime(now.year, now.month + 2, 0);
    final totalDays = endDate.difference(startDate).inDays + 1;
    
    // 프로젝트 시작일과 종료일 계산 (임시 데이터)
    final projectStart = DateTime.now().subtract(const Duration(days: 15));
    final projectEnd = DateTime.now().add(const Duration(days: 30));
    
    final startOffset = projectStart.difference(startDate).inDays;
    final duration = projectEnd.difference(projectStart).inDays;
    
    return Container(
      height: 50,
      width: totalDays * 30.0, // 고정 너비 설정
      child: Stack(
        children: [
          // 배경 그리드
          _buildGridLines(totalDays),
          // 진행률 바
          Positioned(
            left: startOffset * 30.0,
            top: 15,
            child: Container(
              width: duration * 30.0,
              height: 20,
              decoration: BoxDecoration(
                color: projectColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: projectColor, width: 2),
              ),
              child: Stack(
                children: [
                  // 진행률 표시
                  Container(
                    width: (duration * 30.0) * progress,
                    decoration: BoxDecoration(
                      color: projectColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // 진행률 텍스트
                  Center(
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: progress > 0.5 
                            ? Colors.white 
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLines(int totalDays) {
    return Row(
      children: List.generate(totalDays, (index) {
        return Container(
          width: 30,
          height: 50,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                width: 0.5,
              ),
            ),
          ),
        );
      }),
    );
  }

  Color _getProjectColor(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  double _getProjectProgress(Map<String, dynamic> project) {
    // 임시 진행률 계산 (실제로는 프로젝트 데이터에서 가져와야 함)
    final status = project['status'] ?? 'planning';
    switch (status) {
      case 'completed':
        return 1.0;
      case 'in_progress':
        return 0.6;
      case 'planning':
        return 0.2;
      default:
        return 0.0;
    }
  }

  String _getMonthName(int month) {
    const months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    return months[month - 1];
  }
}

// 채팅방 페이지
class ChatRoomPage extends StatefulWidget {
  final Map<String, dynamic> chatRoom;
  
  const ChatRoomPage({super.key, required this.chatRoom});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final String _currentUser = 'admin'; // 현재 사용자

  @override
  void initState() {
    super.initState();
    // 메시지를 읽음으로 표시
    MessageManager.markMessagesAsRead(widget.chatRoom['id'], _currentUser);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoom['name']),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: MessageManager.messageStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final allMessages = snapshot.data!;
                  final chatMessages = allMessages
                      .where((message) => message['chatRoomId'] == widget.chatRoom['id'])
                      .toList();
                  
                  // 시간순으로 정렬 (오래된 것부터)
                  chatMessages.sort((a, b) => 
                      (a['timestamp'] as DateTime).compareTo(b['timestamp'] as DateTime));
                  
                  return ListView.builder(
                    itemCount: chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = chatMessages[index];
                      return _buildMessageItem(message);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final isMe = message['sender'] == _currentUser;
    final timestamp = message['timestamp'] as DateTime;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                message['sender'][0].toUpperCase(),
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message['sender'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  Text(message['content']),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade100,
              child: Text(
                _currentUser[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _sendMessage();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      MessageManager.sendMessage(
        widget.chatRoom['id'],
        _currentUser,
        content,
      );
      _messageController.clear();
    }
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${time.month}/${time.day}';
    } else if (difference.inHours > 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

// 댓글 관리자
class CommentManager {
  static final List<Map<String, dynamic>> _comments = [];
  static final StreamController<List<Map<String, dynamic>>> _commentController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();

  static Stream<List<Map<String, dynamic>>> get commentStream => _commentController.stream;
  static List<Map<String, dynamic>> get comments => List.unmodifiable(_comments);

  static void addComment(String targetType, String targetId, String author, String content) {
    final comment = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'targetType': targetType, // 'project' or 'event'
      'targetId': targetId,
      'author': author,
      'content': content,
      'timestamp': DateTime.now(),
      'isEdited': false,
    };
    
    _comments.insert(0, comment);
    _commentController.add(List.unmodifiable(_comments));
  }

  static void editComment(String commentId, String newContent) {
    final commentIndex = _comments.indexWhere((comment) => comment['id'] == commentId);
    if (commentIndex != -1) {
      _comments[commentIndex]['content'] = newContent;
      _comments[commentIndex]['isEdited'] = true;
      _commentController.add(List.unmodifiable(_comments));
    }
  }

  static void deleteComment(String commentId) {
    _comments.removeWhere((comment) => comment['id'] == commentId);
    _commentController.add(List.unmodifiable(_comments));
  }

  static List<Map<String, dynamic>> getCommentsForTarget(String targetType, String targetId) {
    return _comments.where((comment) => 
        comment['targetType'] == targetType && comment['targetId'] == targetId).toList();
  }
}
