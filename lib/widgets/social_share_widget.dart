import 'package:flutter/material.dart';
import '../services/social_service.dart';

class SocialShareWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final String type; // 'project' or 'event'

  const SocialShareWidget({
    super.key,
    required this.item,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.share),
      onSelected: (value) => _handleShare(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'copy',
          child: ListTile(
            leading: Icon(Icons.copy),
            title: Text('링크 복사'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'email',
          child: ListTile(
            leading: Icon(Icons.email),
            title: Text('이메일로 공유'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'team',
          child: ListTile(
            leading: Icon(Icons.group),
            title: Text('팀원에게 공유'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<void> _handleShare(BuildContext context, String action) async {
    try {
      bool success = false;
      
      switch (action) {
        case 'copy':
          // 링크 복사 시뮬레이션
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('링크가 복사되었습니다')),
          );
          success = true;
          break;
          
        case 'email':
          // 이메일 공유 시뮬레이션
          if (type == 'project') {
            success = await SocialService.shareProject(item);
          } else {
            success = await SocialService.shareEvent(item);
          }
          break;
          
        case 'team':
          // 팀원에게 공유 시뮬레이션
          success = await SocialService.inviteTeamMember(
            'team@example.com',
            item['id'] ?? '',
          );
          break;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${type == 'project' ? '프로젝트' : '이벤트'}가 공유되었습니다')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('공유 실패: $e')),
      );
    }
  }
}
