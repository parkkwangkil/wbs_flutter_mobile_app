import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class TeamPage extends StatefulWidget {
  final String projectId;
  const TeamPage({super.key, required this.projectId});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  // 가짜 팀 멤버 데이터
  List<Map<String, dynamic>> teamMembers = [
    {'id': '1', 'name': 'Admin', 'role': 'Project Manager', 'status': 'online', 'email': 'admin@company.com'},
    {'id': '2', 'name': 'DevOps', 'role': 'Lead Developer', 'status': 'online', 'email': 'devops@company.com'},
    {'id': '3', 'name': 'Designer', 'role': 'UI/UX Designer', 'status': 'away', 'email': 'designer@company.com'},
    {'id': '4', 'name': 'User1', 'role': 'Frontend Developer', 'status': 'offline', 'email': 'user1@company.com'},
    {'id': '5', 'name': 'User2', 'role': 'Backend Developer', 'status': 'offline', 'email': 'user2@company.com'},
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('팀 멤버', 'Team Members')),
      ),
      body: ListView.builder(
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          return ListTile(
            leading: CircleAvatar(
              child: Stack(
                children: [
                  Center(child: Text(member['name'].substring(0, 1))),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(member['status']),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: Text(member['name']),
            subtitle: Text(member['role']),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'generate_password') {
                  _generatePasswordForMember(context, lang, member);
                } else if (value == 'edit') {
                  _editMember(context, lang, member);
                } else if (value == 'remove') {
                  _removeMember(context, lang, member);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'generate_password',
                  child: Text(lang.getText('비밀번호 생성', 'Generate Password')),
                ),
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text(lang.getText('편집', 'Edit')),
                ),
                PopupMenuItem<String>(
                  value: 'remove',
                  child: Text(lang.getText('제거', 'Remove')),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "team_create_fab",
            onPressed: () {
              _showCreateMemberDialog(context, lang);
            },
            child: const Icon(Icons.person_add),
            tooltip: lang.getText('멤버 생성', 'Create Member'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "team_invite_fab",
            onPressed: () {
              _showInviteDialog(context, lang);
            },
            child: const Icon(Icons.person_add_alt_1),
            tooltip: lang.getText('멤버 초대', 'Invite Member'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'offline':
      default:
        return Colors.grey;
    }
  }

  void _showInviteDialog(BuildContext context, LanguageProvider lang) {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('멤버 초대', 'Invite Member')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: lang.getText('이메일 주소', 'Email Address'),
                  hintText: lang.getText('example@company.com', 'example@company.com'),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(lang.getText('취소', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  // 새 멤버 추가
                  setState(() {
                    teamMembers.add({
                      'name': emailController.text.split('@')[0],
                      'role': 'New Member',
                      'status': 'offline',
                    });
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lang.getText('초대가 전송되었습니다.', 'Invitation sent.')),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text(lang.getText('초대', 'Invite')),
            ),
          ],
        );
      },
    );
  }

  void _showCreateMemberDialog(BuildContext context, LanguageProvider lang) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('새 멤버 생성', 'Create New Member')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: lang.getText('이름', 'Name'),
                  ),
                ),
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(
                    labelText: lang.getText('역할', 'Role'),
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: lang.getText('이메일', 'Email'),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: lang.getText('비밀번호', 'Password'),
                    helperText: lang.getText('사용자가 로그인할 비밀번호를 입력하세요', 'Enter password for user login'),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(lang.getText('취소', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && 
                    roleController.text.isNotEmpty && 
                    emailController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  // 새 멤버 추가
                  setState(() {
                    teamMembers.add({
                      'name': nameController.text,
                      'role': roleController.text,
                      'email': emailController.text,
                      'password': passwordController.text,
                      'status': 'offline',
                    });
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lang.getText('멤버가 생성되었습니다.', 'Member created.')),
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lang.getText('모든 필드를 입력해주세요.', 'Please fill in all fields.')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(lang.getText('생성', 'Create')),
            ),
          ],
        );
      },
    );
  }

  void _generatePasswordForMember(BuildContext context, LanguageProvider lang, Map<String, dynamic> member) {
    // 랜덤 비밀번호 생성
    final password = _generateRandomPassword();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('비밀번호 생성', 'Generate Password')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${member['name']}님의 새 비밀번호:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  password,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lang.getText('이 비밀번호를 안전한 곳에 저장하세요.', 'Please save this password securely.'),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(lang.getText('닫기', 'Close')),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: 실제 비밀번호 업데이트 로직
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lang.getText('비밀번호가 생성되었습니다.', 'Password generated.')),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Text(lang.getText('생성', 'Generate')),
            ),
          ],
        );
      },
    );
  }

  void _editMember(BuildContext context, LanguageProvider lang, Map<String, dynamic> member) {
    // TODO: 멤버 편집 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang.getText('멤버 편집 기능은 준비 중입니다.', 'Member edit feature is coming soon.')),
      ),
    );
  }

  void _removeMember(BuildContext context, LanguageProvider lang, Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('멤버 제거', 'Remove Member')),
          content: Text('${member['name']}님을 팀에서 제거하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(lang.getText('취소', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  teamMembers.remove(member);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lang.getText('멤버가 제거되었습니다.', 'Member removed.')),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(lang.getText('제거', 'Remove')),
            ),
          ],
        );
      },
    );
  }

  String _generateRandomPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    final password = StringBuffer();
    
    for (int i = 0; i < 12; i++) {
      password.write(chars[random % chars.length]);
    }
    
    return password.toString();
  }
}
