import 'package:flutter/material.dart';
import '../services/admob_service.dart';

class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: AdMobService.buildBannerAd(),
    );
  }
}

class AdInterstitialWidget extends StatelessWidget {
  final VoidCallback? onAdClosed;
  
  const AdInterstitialWidget({
    super.key,
    this.onAdClosed,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: AdMobService.showInterstitialAd(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return const Center(
            child: Text('광고를 불러올 수 없습니다.'),
          );
        }
        
        // 광고가 닫힌 후 콜백 실행
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onAdClosed?.call();
        });
        
        return const SizedBox.shrink();
      },
    );
  }
}

class AdRewardedWidget extends StatelessWidget {
  final Function(bool)? onRewardEarned;
  
  const AdRewardedWidget({
    super.key,
    this.onRewardEarned,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AdMobService.showRewardedAd(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return const Center(
            child: Text('광고를 불러올 수 없습니다.'),
          );
        }
        
        // 리워드 획득 결과 전달
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onRewardEarned?.call(snapshot.data ?? false);
        });
        
        return const SizedBox.shrink();
      },
    );
  }
}
