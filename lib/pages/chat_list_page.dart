import 'package:flutter/material.dart';
import '../services/local_database.dart';
import 'chat_room_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Map<String, dynamic>> _chatRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rooms = await LocalDatabase.getChatRooms();
      setState(() {
        _chatRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chat rooms: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createChatRoom() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 메모 폴더 만들기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '메모 폴더 이름',
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('생성'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final newRoom = {
        'id': 'room_${DateTime.now().millisecondsSinceEpoch}',
        'name': nameController.text,
        'description': descriptionController.text,
        'members': ['admin'], // 기본적으로 admin이 포함
        'created_at': DateTime.now().toIso8601String(),
        'last_message': null,
        'last_message_time': null,
      };

      await LocalDatabase.addChatRoom(newRoom);
      _loadChatRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인 메모'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChatRooms,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatRooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '메모 폴더가 없습니다',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '새 메모 폴더를 만들어보세요!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = _chatRooms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            room['name'][0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          room['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (room['description'] != null && room['description'].isNotEmpty)
                              Text(
                                room['description'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            if (room['last_message'] != null)
                              Text(
                                room['last_message'],
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (room['last_message_time'] != null)
                              Text(
                                _formatTime(room['last_message_time']),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '메모',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomPage(
                                roomId: room['id'],
                                roomName: room['name'],
                              ),
                            ),
                          ).then((_) => _loadChatRooms());
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChatRoom,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final time = DateTime.parse(timeStr);
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
    } catch (e) {
      return '';
    }
  }
}
