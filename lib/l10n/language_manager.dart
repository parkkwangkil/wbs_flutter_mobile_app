import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static const String _languageKey = 'selected_language';
  static final ValueNotifier<Locale> _localeNotifier = ValueNotifier(const Locale('ko', 'KR'));
  
  static ValueNotifier<Locale> get localeNotifier => _localeNotifier;
  static Locale get currentLocale => _localeNotifier.value;
  
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'ko';
    _localeNotifier.value = Locale(languageCode, languageCode == 'ko' ? 'KR' : 'US');
  }
  
  static Future<void> setLanguage(Locale locale) async {
    _localeNotifier.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }
  
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      default:
        return '한국어';
    }
  }
  
  static List<Locale> get supportedLocales => [
    const Locale('ko', 'KR'),
    const Locale('en', 'US'),
  ];
}
