import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'project_list_page.dart';
import 'calendar_page.dart';
import 'event_list_page.dart';
import 'team_page.dart';
import 'profile_page.dart';
import 'data_analysis_page.dart';
import 'gantt_chart_page.dart';
import 'todo_page.dart';
import 'chat_list_page.dart';
import 'user_settings_page.dart';
import 'ai_assistant_page.dart';

class MainNavigationPage extends StatefulWidget {
  final String? currentUser;
  const MainNavigationPage({super.key, this.currentUser});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
            _pages.addAll([
              ProjectListPage(currentUser: widget.currentUser),
              const CalendarPage(),
              const EventListPage(),
              const TeamPage(projectId: 'default'),
              const DataAnalysisPage(),
              const GanttChartPage(),
              const TodoPage(),
              const ChatListPage(),
              const AiAssistantPage(),
              ProfilePage(username: widget.currentUser ?? 'User'),
            ]);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline),
            activeIcon: const Icon(Icons.work),
            label: lang.getText('프로젝트', 'Projects'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: lang.getText('캘린더', 'Calendar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.event_outlined),
            activeIcon: const Icon(Icons.event),
            label: lang.getText('이벤트', 'Events'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group_outlined),
            activeIcon: const Icon(Icons.group),
            label: lang.getText('팀', 'Team'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics_outlined),
            activeIcon: const Icon(Icons.analytics),
            label: lang.getText('분석', 'Analysis'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.timeline_outlined),
            activeIcon: const Icon(Icons.timeline),
            label: lang.getText('차트', 'Chart'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.checklist_outlined),
            activeIcon: const Icon(Icons.checklist),
            label: lang.getText('할 일', 'Todo'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.note_outlined),
            activeIcon: const Icon(Icons.note),
            label: lang.getText('메모', 'Memo'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.smart_toy_outlined),
            activeIcon: const Icon(Icons.smart_toy),
            label: lang.getText('AI', 'AI'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: lang.getText('프로필', 'Profile'),
          ),
        ],
      ),
    );
  }
}
