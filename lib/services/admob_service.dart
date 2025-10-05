import 'package:flutter/material.dart';

class AdMobService {
  // 광고 ID (테스트용)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // 배너 광고 표시
  static Widget buildBannerAd() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.grey),
      ),
      child: const Center(
        child: Text(
          '광고 영역',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 전면 광고 표시
  static Future<void> showInterstitialAd() async {
    // 전면 광고 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));
    print('전면 광고 표시됨');
  }

  // 리워드 광고 표시
  static Future<bool> showRewardedAd() async {
    // 리워드 광고 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));
    print('리워드 광고 시청 완료');
    return true;
  }

  // 광고 수익 통계
  static Map<String, dynamic> getAdRevenue() {
    return {
      'today': 1250,
      'week': 8750,
      'month': 35000,
      'total': 125000,
    };
  }
}
