import 'package:flutter/material.dart';

class CommentProvider with ChangeNotifier {
  // 실제 앱에서는 게시물 ID 별로 댓글을 관리해야 합니다.
  // Map<String, List<Map<String, dynamic>>> _commentsByPost = {};

  // 여기서는 단일 항목에 대한 댓글 목록을 예시로 듭니다.
  final List<Map<String, dynamic>> _comments = [
    {
      'author': 'DevOps',
      'comment': '이 부분은 API 연동이 필요해 보입니다.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      'author': 'Designer',
      'comment': '관련 디자인 시안 첨부했습니다. 확인 부탁드립니다.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
  ];

  List<Map<String, dynamic>> get comments => List.unmodifiable(_comments);

  Future<void> fetchComments(String postId) async {
    // TODO: ApiService.getComments(postId)를 호출하여 서버로부터 댓글을 가져옵니다.
    notifyListeners();
  }

  Future<void> addComment(String postId, String commentText, String author) async {
    if (commentText.trim().isEmpty) return;

    final newComment = {
      'author': author,
      'comment': commentText.trim(),
      'timestamp': DateTime.now(),
    };
    
    _comments.add(newComment);
    notifyListeners();
    
    // TODO: ApiService.addComment(postId, commentText, author)를 호출하여 서버에 댓글을 등록합니다.
  }
}
