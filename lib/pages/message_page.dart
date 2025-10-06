import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'chat_room_page.dart'; // 실제 채팅방 화면

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  // 가짜 메시지 목록 데이터
  final List<Map<String, dynamic>> chatRooms = const [
    {
      'userName': 'DevOps',
      'lastMessage': '알겠습니다. API 문서 업데이트 후 다시 공유드릴게요.',
      'timestamp': '오후 3:45',
      'unreadCount': 0,
    },
    {
      'userName': 'Designer',
      'lastMessage': '로그인 페이지 시안 최종본 전달드립니다.',
      'timestamp': '오후 1:20',
      'unreadCount': 0,
    },
    {
      'userName': 'User1',
      'lastMessage': '네, 확인했습니다!',
      'timestamp': '오전 11:10',
      'unreadCount': 0,
    },
    {
      'userName': '전체 공지 채널',
      'lastMessage': '금주 금요일은 단축 근무입니다.',
      'timestamp': '어제',
      'unreadCount': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('메시지', 'Messages')),
      ),
      body: ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final room = chatRooms[index];
          final unreadCount = room['unreadCount'] as int;

          return ListTile(
            leading: CircleAvatar(
              child: Text(room['userName'].substring(0, 1)),
            ),
            title: Text(
              room['userName'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              room['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(room['timestamp'], style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatRoomPage(userName: room['userName']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
