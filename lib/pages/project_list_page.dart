import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_provider.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'calendar_page.dart';
import 'admin_page.dart';
import 'create_project_page.dart';

class ProjectListPage extends StatefulWidget {
  final String? currentUser;
  const ProjectListPage({super.key, this.currentUser});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  // 프로젝트 목록을 저장할 Future 객체
  late Future<List<Map<String, dynamic>>> _projectsFuture;
  List<Map<String, dynamic>> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
    
    // 페이지에 들어올 때 가짜 알림을 생성합니다. (테스트용)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .sendProjectNotification(
        projectName: 'WBS 모바일 앱 개발',
        message: '로그인 UI 관련 버그가 보고되었습니다.',
      );
    });
  }

  void _loadProjects() {
    setState(() {
      _projectsFuture = ApiService.getProjects().then((projects) {
        _projects = projects;
        return projects;
      });
    });
  }

  // 프로젝트 상태에 따라 아이콘과 색상을 반환하는 함수
  Widget _buildStatusChip(String status, LanguageProvider lang) {
    IconData icon;
    Color color;
    String text;

    switch (status) {
      case 'in_progress':
        icon = Icons.play_circle;
        color = Colors.blue;
        text = lang.getText('진행중', 'In Progress');
        break;
      case 'completed':
        icon = Icons.check_circle;
        color = Colors.green;
        text = lang.getText('완료', 'Completed');
        break;
      case 'on_hold':
        icon = Icons.pause_circle;
        color = Colors.orange;
        text = lang.getText('보류', 'On Hold');
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
        text = lang.getText('알 수 없음', 'Unknown');
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(text),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('프로젝트 목록', 'Project List')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
            tooltip: lang.getText('새로고침', 'Refresh'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    lang.getText('오류가 발생했습니다.', 'An error occurred.'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    lang.getText('프로젝트가 없습니다.', 'No projects found.'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.getText('새 프로젝트를 생성해보세요.', 'Create a new project.'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          } else {
            final projects = snapshot.data!;
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        project['name']?.substring(0, 1).toUpperCase() ?? 'P',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      project['name'] ?? lang.getText('제목 없음', 'No Title'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project['description'] ?? ''),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusChip(project['status'] ?? 'unknown', lang),
                            const SizedBox(width: 8),
                            if (project['start_date'] != null)
                              Text(
                                '${project['start_date']} ~ ${project['end_date'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'view') {
                          // 프로젝트 상세 보기
                          Navigator.pushNamed(context, '/project_detail', arguments: project);
                        } else if (value == 'edit') {
                          // 프로젝트 편집
                          Navigator.pushNamed(context, '/edit_project', arguments: project);
                        } else if (value == 'delete') {
                          // 프로젝트 삭제
                          _showDeleteDialog(context, project, lang);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'view',
                          child: Text(lang.getText('상세 보기', 'View Details')),
                        ),
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(lang.getText('편집', 'Edit')),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(lang.getText('삭제', 'Delete')),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/project_detail', arguments: project);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "project_fab",
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateProjectPage()),
          );
          if (result != null) {
            // 새 프로젝트를 목록에 즉시 추가
            setState(() {
              _projects.add({
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'name': '새 프로젝트',
                'description': '새로 생성된 프로젝트입니다.',
                'status': 'active',
                'start_date': DateTime.now().toIso8601String().split('T')[0],
                'end_date': DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
                'created_at': DateTime.now().toIso8601String().split('T')[0],
              });
            });
            // 성공 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(lang.getText('프로젝트가 생성되었습니다.', 'Project created successfully.')),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: const Icon(Icons.add),
        tooltip: lang.getText('새 프로젝트', 'New Project'),
      ),
    );
  }

  // 왼쪽 메뉴 드로어를 구성하는 위젯
  Drawer _buildDrawer(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            accountName: Text(widget.currentUser ?? '사용자'),
            accountEmail: Text(widget.currentUser != null ? '${widget.currentUser}@example.com' : ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.currentUser?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text(lang.getText('대시보드', 'Dashboard')),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(lang.getText('캘린더', 'Calendar')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(lang.getText('팀 관리', 'Team Management')),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(lang.getText('설정', 'Settings')),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          if (widget.currentUser == 'admin') ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: Text(lang.getText('관리자', 'Admin')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPage()),
                );
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(lang.getText('로그아웃', 'Logout')),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // 프로젝트 삭제 확인 다이얼로그
  void _showDeleteDialog(BuildContext context, Map<String, dynamic> project, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('프로젝트 삭제', 'Delete Project')),
          content: Text(lang.getText('정말로 이 프로젝트를 삭제하시겠습니까?', 'Are you sure you want to delete this project?')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(lang.getText('취소', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: 실제 삭제 로직 구현
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lang.getText('프로젝트가 삭제되었습니다.', 'Project deleted.')),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(lang.getText('삭제', 'Delete')),
            ),
          ],
        );
      },
    );
  }
}