import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Map<String, dynamic>> _todos = [];
  final _todoController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadInitialTodos();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  // 초기 To-do 데이터 로드
  void _loadInitialTodos() {
    setState(() {
      _todos = [
        {
          'id': '1',
          'title': '프로젝트 기획서 작성',
          'completed': false,
          'priority': 'high',
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'id': '2',
          'title': 'UI/UX 디자인 검토',
          'completed': true,
          'priority': 'medium',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': '3',
          'title': '개발 환경 설정',
          'completed': false,
          'priority': 'high',
          'createdAt': DateTime.now(),
        },
        {
          'id': '4',
          'title': '팀 미팅 준비',
          'completed': false,
          'priority': 'low',
          'createdAt': DateTime.now(),
        },
      ];
    });
  }

  // To-do 추가
  void _addTodo() {
    if (_todoController.text.isNotEmpty) {
      setState(() {
        _todos.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': _todoController.text,
          'completed': false,
          'priority': 'medium',
          'createdAt': DateTime.now(),
        });
      });
      _todoController.clear();
    }
  }

  // To-do 완료 상태 토글
  void _toggleTodo(String id) {
    setState(() {
      final todo = _todos.firstWhere((todo) => todo['id'] == id);
      todo['completed'] = !todo['completed'];
    });
  }

  // To-do 삭제
  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo['id'] == id);
    });
  }

  // 모든 To-do 초기화
  void _clearAllTodos() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.getText('모든 할 일 삭제', 'Clear All Todos')),
          content: Text(lang.getText('모든 할 일을 삭제하시겠습니까?', 'Are you sure you want to delete all todos?')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(lang.getText('취소', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _todos.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lang.getText('모든 할 일이 삭제되었습니다.', 'All todos have been cleared.')),
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

  // 완료된 To-do만 삭제
  void _clearCompletedTodos() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    setState(() {
      _todos.removeWhere((todo) => todo['completed'] == true);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang.getText('완료된 할 일이 삭제되었습니다.', 'Completed todos have been cleared.')),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // 필터링된 To-do 목록
  List<Map<String, dynamic>> get _filteredTodos {
    switch (_selectedFilter) {
      case 'completed':
        return _todos.where((todo) => todo['completed'] == true).toList();
      case 'pending':
        return _todos.where((todo) => todo['completed'] == false).toList();
      default:
        return _todos;
    }
  }

  // 우선순위 색상
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('할 일 관리', 'Todo Management')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                _clearAllTodos();
              } else if (value == 'clear_completed') {
                _clearCompletedTodos();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'clear_completed',
                child: Text(lang.getText('완료된 할 일 삭제', 'Clear Completed')),
              ),
              PopupMenuItem<String>(
                value: 'clear_all',
                child: Text(lang.getText('모든 할 일 삭제', 'Clear All')),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 버튼
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildFilterButton('all', lang.getText('전체', 'All')),
                const SizedBox(width: 8),
                _buildFilterButton('pending', lang.getText('진행중', 'Pending')),
                const SizedBox(width: 8),
                _buildFilterButton('completed', lang.getText('완료', 'Completed')),
              ],
            ),
          ),
          
          // To-do 입력
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      hintText: lang.getText('새 할 일 추가...', 'Add new todo...'),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
          
          // To-do 목록
          Expanded(
            child: _filteredTodos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'completed'
                              ? lang.getText('완료된 할 일이 없습니다.', 'No completed todos.')
                              : _selectedFilter == 'pending'
                                  ? lang.getText('진행중인 할 일이 없습니다.', 'No pending todos.')
                                  : lang.getText('할 일이 없습니다.', 'No todos.'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = _filteredTodos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: todo['completed'],
                            onChanged: (_) => _toggleTodo(todo['id']),
                          ),
                          title: Text(
                            todo['title'],
                            style: TextStyle(
                              decoration: todo['completed']
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo['completed'] ? Colors.grey : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(todo['priority']),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTodo(todo['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
      child: Text(label),
    );
  }
}
