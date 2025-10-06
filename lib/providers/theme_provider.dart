import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // 서비스 초기화 (앱 시작 시 main.dart에서 한번만 호출)
  static Future<ThemeProvider> initialize() async {
    final provider = ThemeProvider();
    provider._prefs = await SharedPreferences.getInstance();
    provider._isDarkMode = provider._prefs.getBool('isDarkMode') ?? false;
    return provider;
  }

  // 테마 토글
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners(); // 변경사항을 모든 구독자(화면)에게 알림
  }

  // 라이트 모드 테마 데이터
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
  );

  // 다크 모드 테마 데이터
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
