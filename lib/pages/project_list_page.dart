import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_provider.dart';
import '../services/api_service.dart';
import '../services/local_database.dart';
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
  Future<List<Map<String, dynamic>>>? _projectsFuture;
  List<Map<String, dynamic>> _projects = [];
  String _selectedFilter = 'all'; // all, personal, team

  @override
  void initState() {
    super.initState();
    _initializeAndLoadProjects();
    
    // 페이지에 들어올 때 가짜 알림을 생성합니다. (테스트용)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .sendProjectNotification(
        projectName: 'WBS 모바일 앱 개발',
        message: '로그인 UI 관련 버그가 보고되었습니다.',
      );
    });
  }
  
  Future<void> _initializeAndLoadProjects() async {
    // 샘플 프로젝트 생성 (데이터가 없을 경우)
    await LocalDatabase.createSampleProjects();
    _loadProjects();
  }

  void _loadProjects() {
    setState(() {
      _projectsFuture = LocalDatabase.getProjects().then((projects) {
        setState(() {
          _projects = projects;
        });
        return projects;
      }).catchError((error) {
        print('프로젝트 로드 오류: $error');
        setState(() {
          _projects = [];
        });
        return <Map<String, dynamic>>[];
      });
    });
  }

  List<Map<String, dynamic>> _getFilteredProjects() {
    switch (_selectedFilter) {
      case 'personal':
        return _projects.where((project) => project['type'] == 'personal').toList();
      case 'team':
        return _projects.where((project) => project['type'] == 'team').toList();
      default:
        return _projects;
    }
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

  // 프로젝트 타입에 따라 아이콘과 색상을 반환하는 함수
  Widget _buildTypeChip(String type, LanguageProvider lang) {
    IconData icon;
    Color color;
    String text;

    switch (type) {
      case 'personal':
        icon = Icons.person;
        color = Colors.blue;
        text = lang.getText('개인', 'Personal');
        break;
      case 'team':
        icon = Icons.group;
        color = Colors.green;
        text = lang.getText('팀', 'Team');
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Icons.all_inclusive,
                      color: _selectedFilter == 'all' ? Theme.of(context).primaryColor : null,
                    ),
                    const SizedBox(width: 8),
                    Text(lang.getText('전체', 'All')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'personal',
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: _selectedFilter == 'personal' ? Theme.of(context).primaryColor : null,
                    ),
                    const SizedBox(width: 8),
                    Text(lang.getText('개인', 'Personal')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'team',
                child: Row(
                  children: [
                    Icon(
                      Icons.group,
                      color: _selectedFilter == 'team' ? Theme.of(context).primaryColor : null,
                    ),
                    const SizedBox(width: 8),
                    Text(lang.getText('팀', 'Team')),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
            tooltip: lang.getText('새로고침', 'Refresh'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _projectsFuture == null 
        ? const Center(child: CircularProgressIndicator())
        : FutureBuilder<List<Map<String, dynamic>>>(
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
            final allProjects = snapshot.data!;
            final filteredProjects = _getFilteredProjects();
            return ListView.builder(
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                final project = filteredProjects[index];
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
                            _buildTypeChip(project['type'] ?? 'team', lang),
                          ],
                        ),
                        const SizedBox(height: 4),
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
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'view') {
                          // 프로젝트 상세 보기
                          Navigator.pushNamed(context, '/project_detail', arguments: project);
                        } else if (value == 'edit') {
                          // 프로젝트 편집
                          Navigator.pushNamed(context, '/edit_project', arguments: project).then((result) {
                            if (result != null && result is Map<String, dynamic>) {
                              // 편집된 프로젝트로 업데이트
                              setState(() {
                                final index = _projects.indexWhere((p) => p['id'] == project['id']);
                                if (index != -1) {
                                  _projects[index] = result;
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(lang.getText('프로젝트가 수정되었습니다.', 'Project updated successfully.')),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          });
                        } else if (value == 'delete') {
                          // 프로젝트 삭제
                          _showDeleteDialog(context, project, lang);
                        } else if (value == 'status') {
                          // 상태 변경
                          _showStatusChangeDialog(context, project, lang);
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
                          value: 'status',
                          child: Text(lang.getText('상태 변경', 'Change Status')),
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
          if (result != null && result is Map<String, dynamic>) {
            // 프로젝트 목록 새로고침
            _loadProjects();
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
              onPressed: () async {
                try {
                  await LocalDatabase.deleteProject(project['id']);
                  Navigator.of(context).pop();
                  _loadProjects(); // 프로젝트 목록 새로고침
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lang.getText('프로젝트가 삭제되었습니다.', 'Project deleted.')),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lang.getText('삭제 중 오류가 발생했습니다.', 'Error occurred while deleting.')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(lang.getText('삭제', 'Delete')),
            ),
          ],
        );
      },
    );
  }

  // 프로젝트 상태 변경 다이얼로그
  void _showStatusChangeDialog(BuildContext context, Map<String, dynamic> project, LanguageProvider lang) {
    String currentStatus = project['status'] ?? 'in_progress';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(lang.getText('상태 변경', 'Change Status')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${lang.getText('프로젝트', 'Project')}: ${project['name']}'),
                  const SizedBox(height: 16),
                  Text(lang.getText('새로운 상태를 선택하세요', 'Select new status:')),
                  const SizedBox(height: 16),
                  ...['in_progress', 'completed', 'on_hold'].map((status) {
                    String statusText = '';
                    switch (status) {
                      case 'in_progress':
                        statusText = lang.getText('진행중', 'In Progress');
                        break;
                      case 'completed':
                        statusText = lang.getText('완료', 'Completed');
                        break;
                      case 'on_hold':
                        statusText = lang.getText('보류', 'On Hold');
                        break;
                    }
                    
                    return RadioListTile<String>(
                      title: Text(statusText),
                      value: status,
                      groupValue: currentStatus,
                      onChanged: (String? value) {
                        setState(() {
                          currentStatus = value!;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(lang.getText('취소', 'Cancel')),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 프로젝트 상태 업데이트
                    setState(() {
                      final index = _projects.indexWhere((p) => p['id'] == project['id']);
                      if (index != -1) {
                        _projects[index]['status'] = currentStatus;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(lang.getText('상태가 변경되었습니다.', 'Status changed successfully.')),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Text(lang.getText('변경', 'Change')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
