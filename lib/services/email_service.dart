// lib/services/email_service.dart

// 실제 구현 시에는 mailer, sendgrid_mailer 등의 라이브러리를 사용합니다.
class EmailService {
  // 이메일 발송
  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    print('--- 이메일 발송 시도 ---');
    print('수신: $to');
    print('제목: $subject');
    print('---------------------');
    print(body);
    print('---------------------');

    // 가짜 네트워크 딜레이
    await Future.delayed(const Duration(seconds: 2));

    // TODO: 실제 mailer 또는 외부 이메일 API 연동 코드 구현

    // 90% 확률로 성공을 시뮬레이션
    final success = DateTime.now().millisecond % 10 != 0;
    
    if (success) {
      print('이메일 발송 성공');
      return true;
    } else {
      print('이메일 발송 실패');
      return false;
    }
  }
}
