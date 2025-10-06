import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  String _currentLanguage = 'ko';

  String get currentLanguage => _currentLanguage;

  // 서비스 초기화 (앱 시작 시 main.dart에서 한번만 호출)
  static Future<LanguageProvider> initialize() async {
    final provider = LanguageProvider();
    provider._prefs = await SharedPreferences.getInstance();
    provider._currentLanguage = provider._prefs.getString('language') ?? 'ko';
    return provider;
  }

  // 언어 설정 변경
  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _prefs.setString('language', languageCode);
    notifyListeners(); // 변경사항을 모든 구독자(화면)에게 알림
  }

  // 현재 언어에 맞는 텍스트 반환
  String getText(String ko, String en) {
    return _currentLanguage == 'ko' ? ko : en;
  }
}
