import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _baseUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  static const String _serviceId = 'your_service_id';
  static const String _templateId = 'your_template_id';
  static const String _publicKey = 'your_public_key';

  // 이메일 전송
  static Future<Map<String, dynamic>> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? from,
    List<String>? cc,
    List<String>? bcc,
    List<Map<String, dynamic>>? attachments,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': to,
            'from_email': from ?? 'noreply@wbsapp.com',
            'subject': subject,
            'message': body,
            'cc': cc?.join(','),
            'bcc': bcc?.join(','),
          },
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '이메일이 성공적으로 전송되었습니다.',
          'response': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': '이메일 전송에 실패했습니다.',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '이메일 전송 중 오류가 발생했습니다.',
        'error': e.toString(),
      };
    }
  }

  // 프로젝트 알림 이메일
  static Future<Map<String, dynamic>> sendProjectNotification({
    required String to,
    required String projectName,
    required String action,
    required String message,
    String? projectUrl,
  }) async {
    final subject = '프로젝트 알림: $projectName';
    final body = '''
안녕하세요!

프로젝트 "$projectName"에 대한 알림입니다.

작업: $action
메시지: $message
${projectUrl != null ? '링크: $projectUrl' : ''}

감사합니다.
WBS 프로젝트 관리 시스템
    ''';

    return await sendEmail(
      to: to,
      subject: subject,
      body: body,
    );
  }

  // 이벤트 알림 이메일
  static Future<Map<String, dynamic>> sendEventNotification({
    required String to,
    required String eventName,
    required DateTime eventDate,
    required String location,
    required String message,
  }) async {
    final subject = '이벤트 알림: $eventName';
    final body = '''
안녕하세요!

이벤트 "$eventName"에 대한 알림입니다.

일시: ${eventDate.toString().split(' ')[0]} ${eventDate.toString().split(' ')[1]}
장소: $location
메시지: $message

감사합니다.
WBS 프로젝트 관리 시스템
    ''';

    return await sendEmail(
      to: to,
      subject: subject,
      body: body,
    );
  }

  // 팀원 초대 이메일
  static Future<Map<String, dynamic>> sendTeamInvitation({
    required String to,
    required String teamName,
    required String inviterName,
    required String invitationUrl,
  }) async {
    final subject = '팀 초대: $teamName';
    final body = '''
안녕하세요!

$inviterName님이 "$teamName" 팀에 초대했습니다.

초대 링크: $invitationUrl

팀에 참여하려면 위 링크를 클릭하세요.

감사합니다.
WBS 프로젝트 관리 시스템
    ''';

    return await sendEmail(
      to: to,
      subject: subject,
      body: body,
    );
  }

  // 일일 요약 이메일
  static Future<Map<String, dynamic>> sendDailySummary({
    required String to,
    required List<Map<String, dynamic>> projects,
    required List<Map<String, dynamic>> events,
    required DateTime date,
  }) async {
    final subject = '일일 요약 - ${date.toString().split(' ')[0]}';
    
    String projectSummary = '';
    if (projects.isNotEmpty) {
      projectSummary = '\n프로젝트:\n';
      for (final project in projects) {
        projectSummary += '- ${project['name']}: ${project['status']}\n';
      }
    }

    String eventSummary = '';
    if (events.isNotEmpty) {
      eventSummary = '\n이벤트:\n';
      for (final event in events) {
        eventSummary += '- ${event['title']}: ${event['start_date']}\n';
      }
    }

    final body = '''
안녕하세요!

${date.toString().split(' ')[0]} 일일 요약입니다.

$projectSummary
$eventSummary

감사합니다.
WBS 프로젝트 관리 시스템
    ''';

    return await sendEmail(
      to: to,
      subject: subject,
      body: body,
    );
  }

  // 주간 요약 이메일
  static Future<Map<String, dynamic>> sendWeeklySummary({
    required String to,
    required List<Map<String, dynamic>> completedProjects,
    required List<Map<String, dynamic>> upcomingEvents,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) async {
    final subject = '주간 요약 - ${weekStart.toString().split(' ')[0]} ~ ${weekEnd.toString().split(' ')[0]}';
    
    String completedSummary = '';
    if (completedProjects.isNotEmpty) {
      completedSummary = '\n완료된 프로젝트:\n';
      for (final project in completedProjects) {
        completedSummary += '- ${project['name']}\n';
      }
    }

    String upcomingSummary = '';
    if (upcomingEvents.isNotEmpty) {
      upcomingSummary = '\n예정된 이벤트:\n';
      for (final event in upcomingEvents) {
        upcomingSummary += '- ${event['title']}: ${event['start_date']}\n';
      }
    }

    final body = '''
안녕하세요!

${weekStart.toString().split(' ')[0]} ~ ${weekEnd.toString().split(' ')[0]} 주간 요약입니다.

$completedSummary
$upcomingSummary

감사합니다.
WBS 프로젝트 관리 시스템
    ''';

    return await sendEmail(
      to: to,
      subject: subject,
      body: body,
    );
  }

  // 알림 설정 이메일
  static Future<Map<String, dynamic>> sendNotificationSettings({
    required String to,
    required Map<String, bool> settings,
  }) async {
    final subject = '알림 설정 변경 확인';
    
    String settingsText = '';
    settings.forEach((key, value) {
      settingsText += '- $key: ${value ? '활성화' : '비활성화'}\n';
    });

    final body = '''
안녕하세요!

알림 설정이 변경되었습니다.

$settingsText

감사합니다.
WBS 프로젝트 관리 시스템
    ''';

    return await sendEmail(
      to: to,
      subject: subject,
      body: body,
    );
  }
}
