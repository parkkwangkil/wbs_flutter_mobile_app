// 실제 앱에서는 in_app_purchase 같은 라이브러리를 사용해야 합니다.
class PaymentService {
  // --- 구독 상품 정보 (서버 또는 로컬에서 관리) ---
  static final List<Map<String, dynamic>> subscriptionPlans = [
    {
      'id': 'pro',
      'name': '프로 플랜',
      'price': 19900,
      'period': '월',
      'features': [
        '무제한 프로젝트 생성',
        '무제한 팀원 초대',
        '고급 통계 및 리포트',
        '이메일 기술 지원',
      ],
    },
    {
      'id': 'business',
      'name': '비즈니스 플랜',
      'price': 499000,
      'period': '년',
      'features': [
        '프로 플랜의 모든 기능',
        '전담 매니저 배정',
        '보안 및 감사 로그',
        '전화 기술 지원',
      ],
    },
  ];

  // --- 핵심 메소드 ---

  // 결제를 처리하는 시뮬레이션 메소드
  static Future<bool> processPayment(String planId, String paymentMethod) async {
    final plan = subscriptionPlans.firstWhere((p) => p['id'] == planId);
    print('결제 시도: ${plan['name']} 플랜 ($paymentMethod)');
    await Future.delayed(const Duration(seconds: 3)); // 가짜 결제 처리 시간

    // 실제로는 IAP 라이브러리의 구매 요청 결과를 반환해야 합니다.
    // 여기서는 80% 확률로 성공, 20% 확률로 실패를 시뮬레이션합니다.
    return Future.value(DateTime.now().second % 5 != 0);
  }

  // 결제 내역을 가져오는 시뮬레이션 메소드
  static Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    await Future.delayed(const Duration(seconds: 1)); // 가짜 네트워크 딜레이
    return [
      {
        'id': 'pay_001',
        'plan': '프로 플랜',
        'date': '2024-01-15 10:30:00',
        'amount': 19900,
      },
      {
        'id': 'pay_002',
        'plan': '프로 플랜',
        'date': '2023-12-15 10:28:00',
        'amount': 19900,
      },
    ];
  }
}
