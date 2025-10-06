import 'package:flutter/material.dart';

// 이 서비스는 Google Mobile Ads (AdMob) 관련 로직을 캡슐화합니다.
// 현재는 광고가 비활성화된 상태이며, 실제 광고를 표시하려면
// pubspec.yaml에서 google_mobile_ads 주석을 해제하고, 각 메소드의 TODO를 구현해야 합니다.

class AdMobService {
  // --- 초기화 ---
  // 앱 시작 시 main.dart에서 호출해야 합니다.
  static Future<void> initialize() async {
    // TODO: MobileAds.instance.initialize() 호출
    // 실제 초기화 코드가 필요합니다.
    print('AdMob Service: Initialized (No-Op)');
  }

  // --- 배너 광고 ---
  // 화면의 특정 부분에 표시되는 배너 광고를 생성합니다.
  static Widget buildBannerAd() {
    // TODO: 실제 BannerAd를 생성하고 AdWidget을 반환해야 합니다.
    // 예: 
    // final bannerAd = BannerAd(...);
    // bannerAd.load();
    // return AdWidget(ad: bannerAd);

    // 현재는 광고가 비활성화되어 있으므로 빈 위젯을 반환합니다.
    return const SizedBox.shrink();
  }

  // --- 전면 광고 ---
  // 전체 화면을 덮는 광고를 표시합니다.
  static Future<void> showInterstitialAd() async {
    // TODO: InterstitialAd.load(...) 및 ad.show() 로직 구현
    print('AdMob Service: showInterstitialAd (No-Op)');
    // 광고가 닫힐 때까지 기다리는 가짜 딜레이 (필요시 사용)
    // await Future.delayed(Duration(seconds: 1));
  }

  // --- 보상형 광고 ---
  // 사용자가 광고를 끝까지 시청하면 보상을 받는 광고를 표시합니다.
  static Future<bool> showRewardedAd() async {
    // TODO: RewardedAd.load(...) 및 ad.show() 로직 구현
    // 보상 지급 여부를 결정하는 콜백을 처리해야 합니다.
    print('AdMob Service: showRewardedAd (No-Op)');
    // 항상 보상 획득에 실패한 것으로 처리합니다.
    return false;
  }
}
