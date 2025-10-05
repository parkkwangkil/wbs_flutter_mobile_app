import 'package:flutter/material.dart';

class PaymentService {
  // 구독 플랜
  static const List<Map<String, dynamic>> subscriptionPlans = [
    {
      'id': 'basic',
      'name': '베이직',
      'price': 9900,
      'period': '월',
      'features': ['기본 프로젝트 관리', '5개 프로젝트', '기본 지원'],
    },
    {
      'id': 'pro',
      'name': '프로',
      'price': 19900,
      'period': '월',
      'features': ['고급 프로젝트 관리', '무제한 프로젝트', '우선 지원', '고급 분석'],
    },
    {
      'id': 'enterprise',
      'name': '엔터프라이즈',
      'price': 49900,
      'period': '월',
      'features': ['팀 협업', '무제한 사용자', '전용 지원', '커스터마이징'],
    },
  ];

  // 결제 처리
  static Future<bool> processPayment(String planId, String paymentMethod) async {
    // 결제 처리 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));
    
    // 결제 성공 시뮬레이션 (90% 성공률)
    return DateTime.now().millisecondsSinceEpoch % 10 != 0;
  }

  // 구독 상태 확인
  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    // 구독 상태 시뮬레이션
    return {
      'isActive': true,
      'plan': 'pro',
      'expiresAt': DateTime.now().add(const Duration(days: 30)),
      'autoRenew': true,
    };
  }

  // 결제 내역
  static Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    return [
      {
        'id': 'payment_001',
        'amount': 19900,
        'plan': '프로',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'status': '완료',
      },
      {
        'id': 'payment_002',
        'amount': 19900,
        'plan': '프로',
        'date': DateTime.now().subtract(const Duration(days: 31)),
        'status': '완료',
      },
    ];
  }

  // 환불 처리
  static Future<bool> processRefund(String paymentId) async {
    // 환불 처리 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
