import 'package:flutter/material.dart';

class MessageProvider with ChangeNotifier {
  // 실제 앱에서는 채팅방 ID 별로 메시지를 관리해야 합니다.
  // Map<String, List<Map<String, dynamic>>> _messagesByRoom = {};
  
  // 여기서는 단일 채팅방을 예시로 듭니다.
  final List<Map<String, dynamic>> _messages = [
    {'sender': 'other', 'text': '안녕하세요, 시안 관련하여 문의드립니다.'},
    {'sender': 'me', 'text': '네, 말씀하세요.'},
  ];

  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  Future<void> fetchMessages(String roomId) async {
    // TODO: ApiService.getMessages(roomId)를 호출하여 서버로부터 메시지를 가져옵니다.
    // 지금은 로컬 데이터를 사용합니다.
    notifyListeners();
  }

  Future<void> sendMessage(String roomId, String text) async {
    if (text.trim().isEmpty) return;
    
    final newMessage = {'sender': 'me', 'text': text.trim()};
    _messages.add(newMessage);
    notifyListeners();
    
    // TODO: ApiService.sendMessage(roomId, text)를 호출하여 서버에 메시지를 전송합니다.

    // 가짜 상대방 응답 (테스트용)
    await Future.delayed(const Duration(seconds: 1));
    final botResponse = {'sender': 'other', 'text': '확인했습니다.'};
    _messages.add(botResponse);
    notifyListeners();
  }
}
